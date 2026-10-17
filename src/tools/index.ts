import fs from 'fs';
import path from 'path';
import { exec, spawn } from 'child_process';
import { promisify } from 'util';
import { GateGuard } from '../core/guardrail.js';
import { ToolResult } from '../types/index.js';
import { MediaTools } from './media_tools.js';

const execAsync = promisify(exec);

export class ToolRegistry {
  private workspaceRoot: string;
  private mediaTools: MediaTools;

  constructor(workspaceRoot: string) {
    this.workspaceRoot = path.resolve(workspaceRoot);
    this.mediaTools = new MediaTools(this.workspaceRoot);
  }

  public async readFile(callId: string, relativePath: string): Promise<ToolResult> {
    const fullPath = path.resolve(this.workspaceRoot, relativePath);
    const check = GateGuard.checkFileOperation('read', fullPath, this.workspaceRoot);
    if (!check.allowed) {
      return { callId, success: false, output: '', error: check.reason };
    }

    try {
      if (!fs.existsSync(fullPath)) {
        return { callId, success: false, output: '', error: `File not found: ${relativePath}` };
      }
      const content = fs.readFileSync(fullPath, 'utf8');
      return { callId, success: true, output: content };
    } catch (err: any) {
      return { callId, success: false, output: '', error: err.message };
    }
  }

  public async writeFile(callId: string, relativePath: string, content: string): Promise<ToolResult> {
    const fullPath = path.resolve(this.workspaceRoot, relativePath);
    const check = GateGuard.checkFileOperation('write', fullPath, this.workspaceRoot);
    if (!check.allowed) {
      return { callId, success: false, output: '', error: check.reason };
    }

    try {
      fs.mkdirSync(path.dirname(fullPath), { recursive: true });
      fs.writeFileSync(fullPath, content, 'utf8');
      return { callId, success: true, output: `Successfully wrote ${content.length} characters to ${relativePath}` };
    } catch (err: any) {
      return { callId, success: false, output: '', error: err.message };
    }
  }

  public async editFile(
    callId: string,
    relativePath: string,
    targetSnippet: string,
    replacement: string
  ): Promise<ToolResult> {
    const fullPath = path.resolve(this.workspaceRoot, relativePath);
    const check = GateGuard.checkFileOperation('write', fullPath, this.workspaceRoot);
    if (!check.allowed) {
      return { callId, success: false, output: '', error: check.reason };
    }

    try {
      if (!fs.existsSync(fullPath)) {
        return { callId, success: false, output: '', error: `File not found: ${relativePath}` };
      }
      const existing = fs.readFileSync(fullPath, 'utf8');
      if (!existing.includes(targetSnippet)) {
        return { callId, success: false, output: '', error: 'Target snippet not found in file.' };
      }
      const updated = existing.replace(targetSnippet, replacement);
      fs.writeFileSync(fullPath, updated, 'utf8');
      return { callId, success: true, output: `Successfully edited ${relativePath}` };
    } catch (err: any) {
      return { callId, success: false, output: '', error: err.message };
    }
  }

  public async listFiles(callId: string, subDir = '.'): Promise<ToolResult> {
    const targetDir = path.resolve(this.workspaceRoot, subDir);
    try {
      if (!fs.existsSync(targetDir)) {
        return { callId, success: false, output: '', error: `Directory not found: ${subDir}` };
      }
      const entries = fs.readdirSync(targetDir, { withFileTypes: true });
      const summary = entries
        .map(e => `${e.isDirectory() ? '[DIR]' : '[FILE]'} ${e.name}`)
        .join('\n');
      return { callId, success: true, output: summary || '(Empty directory)' };
    } catch (err: any) {
      return { callId, success: false, output: '', error: err.message };
    }
  }

  public async runTerminalCommand(callId: string, command: string, timeoutMs = 30000): Promise<ToolResult> {
    const check = GateGuard.checkTerminalCommand(command);
    if (!check.allowed) {
      return {
        callId,
        success: false,
        output: '',
        error: `BLOCKED BY GATEGUARD: ${check.reason}`,
      };
    }

    try {
      const { stdout, stderr } = await execAsync(command, {
        cwd: this.workspaceRoot,
        timeout: timeoutMs,
        maxBuffer: 10 * 1024 * 1024,
      });
      const output = [stdout, stderr ? `[STDERR]\n${stderr}` : ''].filter(Boolean).join('\n');
      return { callId, success: true, output: output || '(Command completed with no output)' };
    } catch (err: any) {
      return {
        callId,
        success: false,
        output: err.stdout || '',
        error: `Exit Code ${err.code || 1}: ${err.stderr || err.message}`,
      };
    }
  }

  public async captureSimulatorScreenshot(callId: string, outputFilename = 'simulator_preview.png'): Promise<ToolResult> {
    const targetPath = path.resolve(this.workspaceRoot, '.buta', 'artifacts', outputFilename);
    fs.mkdirSync(path.dirname(targetPath), { recursive: true });

    try {
      // Try iOS xcrun simctl first (standard macOS Flutter setup)
      await execAsync(`xcrun simctl io booted screenshot "${targetPath}"`, { timeout: 10000 });
      return { callId, success: true, output: `Captured iOS simulator screenshot at ${targetPath}` };
    } catch {
      // Fallback to Android ADB
      try {
        await execAsync(`adb exec-out screencap -p > "${targetPath}"`, { timeout: 10000 });
        return { callId, success: true, output: `Captured Android simulator screenshot at ${targetPath}` };
      } catch (err: any) {
        return { callId, success: false, output: '', error: `Failed to capture screenshot from booted simulator: ${err.message}` };
      }
    }
  }

  public getToolDefinitions(): import('../types/index.js').ToolDefinition[] {
    return [
      {
        type: 'function',
        function: {
          name: 'read_file',
          description: 'Read the contents of a file in the workspace',
          parameters: {
            type: 'object',
            properties: {
              path: { type: 'string', description: 'Relative path to the file' },
            },
            required: ['path'],
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'write_file',
          description: 'Create or overwrite a file in the workspace with new content',
          parameters: {
            type: 'object',
            properties: {
              path: { type: 'string', description: 'Relative path to the file' },
              content: { type: 'string', description: 'The code or text content to write' },
            },
            required: ['path', 'content'],
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'edit_file',
          description: 'Replace an exact target snippet of code within an existing file',
          parameters: {
            type: 'object',
            properties: {
              path: { type: 'string', description: 'Relative path to the file' },
              targetSnippet: { type: 'string', description: 'Exact code snippet to replace' },
              replacement: { type: 'string', description: 'New replacement code' },
            },
            required: ['path', 'targetSnippet', 'replacement'],
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'list_files',
          description: 'List directories and files in a workspace subdirectory',
          parameters: {
            type: 'object',
            properties: {
              directory: { type: 'string', description: 'Subdirectory path (default ".")' },
            },
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'run_terminal_command',
          description: 'Execute shell commands (e.g. flutter test, dart analyze, npm test, git status)',
          parameters: {
            type: 'object',
            properties: {
              command: { type: 'string', description: 'The exact shell command to run' },
            },
            required: ['command'],
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'capture_simulator_screenshot',
          description: 'Capture screenshot from booted iOS or Android simulator to verify visual output',
          parameters: {
            type: 'object',
            properties: {
              filename: { type: 'string', description: 'Target filename (default: simulator_preview.png)' },
            },
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'generate_image',
          description: 'Create high-resolution vector SVG graphics, app icons, badges, UI mocks, or architecture diagrams',
          parameters: {
            type: 'object',
            properties: {
              prompt: { type: 'string', description: 'Visual description of the desired graphic or image' },
              filename: { type: 'string', description: 'Base filename without extension (default auto-generated)' },
              style: {
                type: 'string',
                enum: ['modern_vector', 'app_icon', 'badge', 'ui_mock', 'diagram'],
                description: 'Aesthetic visual style preset',
              },
              customSvg: { type: 'string', description: 'Optional explicit SVG XML string if handcrafted by agent' },
            },
            required: ['prompt'],
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'generate_animation',
          description: 'Generate production Flutter AnimationController/CustomPainter widgets and hardware-accelerated CSS animations',
          parameters: {
            type: 'object',
            properties: {
              prompt: { type: 'string', description: 'Description of the motion, glow, pulse, or particle physics' },
              animationType: {
                type: 'string',
                enum: ['flutter_motion', 'css_keyframe', 'svg_morph'],
                description: 'Format of animation (Flutter widget vs CSS keyframes)',
              },
              filename: { type: 'string', description: 'Base filename without extension' },
              durationMs: { type: 'number', description: 'Animation loop duration in milliseconds (default: 2000)' },
            },
            required: ['prompt'],
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'generate_video_storyboard',
          description: 'Produce an 18-second kinetic launch video storyboard with voiceover script, timeline JSON, HTML5 web player, and FFmpeg render script',
          parameters: {
            type: 'object',
            properties: {
              title: { type: 'string', description: 'Title of the launch video or cinematic explainer' },
              concept: { type: 'string', description: 'Core product narrative, hook, problem, and call to action' },
              filename: { type: 'string', description: 'Base filename for the storyboard package' },
            },
            required: ['title', 'concept'],
          },
        },
      },
    ];
  }

  public async executeTool(call: import('../types/index.js').ToolCall): Promise<ToolResult> {
    const args = call.args || {};
    switch (call.name) {
      case 'read_file':
        return this.readFile(call.id, (args.path as string) || (args.relativePath as string) || '');
      case 'write_file':
        return this.writeFile(
          call.id,
          (args.path as string) || (args.relativePath as string) || '',
          (args.content as string) || ''
        );
      case 'edit_file':
        return this.editFile(
          call.id,
          (args.path as string) || (args.relativePath as string) || '',
          (args.targetSnippet as string) || '',
          (args.replacement as string) || ''
        );
      case 'list_files':
        return this.listFiles(call.id, (args.directory as string) || (args.subDir as string) || '.');
      case 'run_terminal_command':
        return this.runTerminalCommand(call.id, (args.command as string) || '');
      case 'capture_simulator_screenshot':
        return this.captureSimulatorScreenshot(call.id, (args.filename as string) || 'simulator_preview.png');
      case 'generate_image':
        return this.mediaTools.generateImage(call.id, args as any);
      case 'generate_animation':
        return this.mediaTools.generateAnimation(call.id, args as any);
      case 'generate_video_storyboard':
        return this.mediaTools.generateVideoStoryboard(call.id, args as any);
      default:
        return {
          callId: call.id,
          success: false,
          output: '',
          error: `Unknown tool: ${call.name}`,
        };
    }
  }
}


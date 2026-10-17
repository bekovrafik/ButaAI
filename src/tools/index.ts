import fs from 'fs';
import path from 'path';
import { exec, spawn } from 'child_process';
import { promisify } from 'util';
import { GateGuard } from '../core/guardrail.js';
import { ToolResult } from '../types/index.js';

const execAsync = promisify(exec);

export class ToolRegistry {
  private workspaceRoot: string;

  constructor(workspaceRoot: string) {
    this.workspaceRoot = path.resolve(workspaceRoot);
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
}

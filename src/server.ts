import http from 'http';
import fs from 'fs';
import path from 'path';
import { spawn, execSync } from 'child_process';
import { WebSocketServer, WebSocket } from 'ws';
import { ButaEngine } from './core/engine.js';
import { SwarmHubService } from './swarm_hub.js';
import { AgentEvent } from './types/index.js';

const PORT = process.env.BUTA_PORT ? parseInt(process.env.BUTA_PORT, 10) : 3030;
const engine = new ButaEngine(process.cwd());
const swarmHub = new SwarmHubService(process.cwd());

const server = http.createServer(async (req, res) => {
  // Enable CORS for Flutter web cockpit (localhost:8080 or file://)
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const url = new URL(req.url || '/', `http://${req.headers.host}`);

  // Health and Status API
  if (url.pathname === '/api/status' && req.method === 'GET') {
    const isOnline = await engine.getProvider().isLocalEngineAvailable();
    const availableModels = await engine.getProvider().getAvailableModels();
    const targetModel = await engine.getProvider().resolveTargetModel();
    const memory = engine.getMemory();

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(
      JSON.stringify({
        status: 'online',
        engineOnline: isOnline,
        targetModel,
        availableModels,
        projectState: memory.getProjectState(),
        instincts: memory.getInstincts(),
        decisions: memory.getDecisions(),
        tools: engine.getTools().getToolDefinitions().map(t => t.function.name),
      })
    );
    return;
  }

  // Static Artifact Server (SVGs, HTML Previews, Video Storyboards, Images)
  if (url.pathname.startsWith('/artifacts/') && (req.method === 'GET' || req.method === 'HEAD')) {
    const relPath = decodeURIComponent(url.pathname.replace(/^\/artifacts\//, ''));
    const safePath = path.resolve(process.cwd(), '.buta', 'artifacts', relPath);
    const artifactsRoot = path.resolve(process.cwd(), '.buta', 'artifacts');

    if (!safePath.startsWith(artifactsRoot) || !fs.existsSync(safePath) || fs.statSync(safePath).isDirectory()) {
      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Artifact not found' }));
      return;
    }

    const ext = path.extname(safePath).toLowerCase();
    const mimeTypes: Record<string, string> = {
      '.svg': 'image/svg+xml',
      '.html': 'text/html; charset=utf-8',
      '.htm': 'text/html; charset=utf-8',
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.json': 'application/json',
      '.js': 'application/javascript',
      '.css': 'text/css',
      '.dart': 'text/plain; charset=utf-8',
      '.md': 'text/markdown; charset=utf-8',
      '.txt': 'text/plain; charset=utf-8',
      '.mp4': 'video/mp4',
      '.sh': 'text/x-shellscript',
    };

    const contentType = mimeTypes[ext] || 'application/octet-stream';
    res.writeHead(200, {
      'Content-Type': contentType,
      'Cache-Control': 'no-cache',
    });
    fs.createReadStream(safePath).pipe(res);
    return;
  }

  // Media Library API: List all generated SVGs, animations, and video storyboards
  if (url.pathname === '/api/media/list' && req.method === 'GET') {
    const artifactsDir = path.resolve(process.cwd(), '.buta', 'artifacts');
    const imagesDir = path.join(artifactsDir, 'images');
    const animationsDir = path.join(artifactsDir, 'animations');
    const videosDir = path.join(artifactsDir, 'videos');

    const result = {
      images: [] as Array<{ filename: string; url: string; previewUrl: string; size: number }>,
      animations: [] as Array<{ filename: string; url: string; type: string; size: number }>,
      videos: [] as Array<{ filename: string; playerUrl: string; timelineUrl: string; title: string }>,
    };

    try {
      if (fs.existsSync(imagesDir)) {
        for (const file of fs.readdirSync(imagesDir)) {
          if (file.endsWith('.svg')) {
            const stat = fs.statSync(path.join(imagesDir, file));
            const base = file.replace(/\.svg$/, '');
            result.images.push({
              filename: file,
              url: `/artifacts/images/${file}`,
              previewUrl: `/artifacts/images/${base}_preview.html`,
              size: stat.size,
            });
          }
        }
      }

      if (fs.existsSync(animationsDir)) {
        for (const file of fs.readdirSync(animationsDir)) {
          if (file.endsWith('.html') || file.endsWith('.dart')) {
            const stat = fs.statSync(path.join(animationsDir, file));
            result.animations.push({
              filename: file,
              url: `/artifacts/animations/${file}`,
              type: file.endsWith('.html') ? 'web_css' : 'flutter_widget',
              size: stat.size,
            });
          }
        }
      }

      if (fs.existsSync(videosDir)) {
        for (const file of fs.readdirSync(videosDir)) {
          if (file.endsWith('.html')) {
            const base = file.replace(/\.html$/, '').replace(/_player$/, '');
            let title = base;
            const jsonCandidates = [
              path.join(videosDir, `${base}.json`),
              path.join(videosDir, `${base}_timeline.json`),
            ];
            for (const cand of jsonCandidates) {
              if (fs.existsSync(cand)) {
                try {
                  const meta = JSON.parse(fs.readFileSync(cand, 'utf8'));
                  title = meta.title || base;
                  break;
                } catch (_) {}
              }
            }
            result.videos.push({
              filename: file,
              playerUrl: `/artifacts/videos/${file}`,
              timelineUrl: `/artifacts/videos/${base}.json`,
              title,
            });
          }
        }
      }

      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(result));
    } catch (err: any) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
    return;
  }

  // 1-Click Multimodal Media Generation API
  if (url.pathname === '/api/media/generate' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => (body += chunk));
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');
        const mediaType = payload.type || 'image'; // image | animation | video

        broadcastEvent({
          type: 'tool_call',
          agent: 'CreativeDirector',
          role: 'product_architect',
          data: { tool: `generate_${mediaType}`, log: `Creating on-device procedural ${mediaType}...` },
          timestamp: new Date().toISOString(),
        });

        let toolRes;
        if (mediaType === 'image') {
          toolRes = await engine.getTools().executeTool({
            id: `call_${Date.now()}`,
            name: 'generate_image',
            args: {
              prompt: payload.prompt || 'Modern AI company app icon',
              style: payload.style || 'modern_vector',
              filename: payload.filename,
              customSvg: payload.customSvg,
            },
          });
        } else if (mediaType === 'animation') {
          toolRes = await engine.getTools().executeTool({
            id: `call_${Date.now()}`,
            name: 'generate_animation',
            args: {
              prompt: payload.prompt || 'Glowing pulse radar wave',
              animationType: payload.animationType || 'flutter_motion',
              filename: payload.filename,
              durationMs: payload.durationMs || 2000,
            },
          });
        } else if (mediaType === 'video') {
          toolRes = await engine.getTools().executeTool({
            id: `call_${Date.now()}`,
            name: 'generate_video_storyboard',
            args: {
              title: payload.title || 'ButaAI 18s Kinetic Product Launch',
              concept: payload.concept || 'Local Apple Silicon Metal AI Software Squad',
              filename: payload.filename,
            },
          });
        } else {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: `Unsupported media type: ${mediaType}` }));
          return;
        }

        broadcastEvent({
          type: 'phase_change',
          agent: 'CreativeDirector',
          role: 'product_architect',
          data: { phase: 'MEDIA_GENERATION_COMPLETED', output: toolRes.output },
          timestamp: new Date().toISOString(),
        });

        res.writeHead(toolRes.success ? 200 : 500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(toolRes));
      } catch (err: any) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // List & Read Artifacts
  if (url.pathname === '/api/artifacts' && req.method === 'GET') {
    const artifactsDir = path.resolve(process.cwd(), '.buta', 'artifacts');
    try {
      if (!fs.existsSync(artifactsDir)) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ files: [] }));
        return;
      }
      const files = fs.readdirSync(artifactsDir);
      const fileData: Record<string, string> = {};
      for (const f of files) {
        if (f.endsWith('.md') || f.endsWith('.json') || f.endsWith('.txt')) {
          fileData[f] = fs.readFileSync(path.join(artifactsDir, f), 'utf8');
        }
      }
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ files, contents: fileData }));
    } catch (err: any) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
    return;
  }

  // Export / Download Project ZIP
  if (url.pathname === '/api/download-zip' && req.method === 'GET') {
    const artifactsDir = path.resolve(process.cwd(), '.buta', 'artifacts');
    const zipPath = path.resolve(process.cwd(), '.buta', 'buta_project.zip');
    try {
      if (!fs.existsSync(artifactsDir)) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'No artifacts to export' }));
        return;
      }
      execSync(`cd "${artifactsDir}" && zip -q -r "${zipPath}" . -x "*.DS_Store"`);
      if (fs.existsSync(zipPath)) {
        const stat = fs.statSync(zipPath);
        res.writeHead(200, {
          'Content-Type': 'application/zip',
          'Content-Length': stat.size,
          'Content-Disposition': 'attachment; filename="buta_project.zip"',
        });
        const readStream = fs.createReadStream(zipPath);
        readStream.pipe(res);
        return;
      }
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Failed to create zip file' }));
    } catch (err: any) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
    return;
  }

  // ButaAI Swarm Hub API: Status & Community Network Stats
  if (url.pathname === '/api/swarm/status' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(
      JSON.stringify({
        ...swarmHub.getNodeStatus(),
        stats: swarmHub.getStats(),
      })
    );
    return;
  }

  // Toggle Swarm Collective Participation
  if (url.pathname === '/api/swarm/toggle' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => (body += chunk));
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const updated = swarmHub.toggleParticipation(payload.participating ?? true);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(updated));
      } catch (err: any) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // Sync Local Engine with Global Master Swarm Model
  if (url.pathname === '/api/swarm/sync' && req.method === 'POST') {
    broadcastEvent({
      type: 'tool_call',
      agent: 'SwarmCoordinator',
      role: 'orchestrator',
      data: { tool: 'swarm_sync', log: 'Syncing local weights with ButaAI Collective Master Swarm...' },
      timestamp: new Date().toISOString(),
    });

    const result = await swarmHub.syncWithMaster();
    broadcastEvent({
      type: 'phase_change',
      agent: 'SwarmCoordinator',
      role: 'orchestrator',
      data: { phase: 'SWARM_SYNC_COMPLETED', ...result },
      timestamp: new Date().toISOString(),
    });

    res.writeHead(result.success ? 200 : 500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(result));
    return;
  }

  // Contribute Local LoRA Delta to Community Swarm
  if (url.pathname === '/api/swarm/contribute' && req.method === 'POST') {
    const result = await swarmHub.contributeLocalAdapter();
    res.writeHead(result.success ? 200 : 400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(result));
    return;
  }

  // Download Master Adapter
  if (url.pathname === '/api/swarm/download-master' && req.method === 'GET') {
    const filePath = swarmHub.getMasterDownloadPath();
    if (!filePath || !fs.existsSync(filePath)) {
      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Global master adapter not available' }));
      return;
    }

    res.writeHead(200, {
      'Content-Type': 'application/octet-stream',
      'Content-Disposition': 'attachment; filename="global_master_adapter.safetensors"',
    });
    fs.createReadStream(filePath).pipe(res);
    return;
  }

  // 1-Click Retrain on Apple Silicon Metal
  if (url.pathname === '/api/train' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => (body += chunk));
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const iters = parseInt(payload.iters, 10) || 10;

        broadcastEvent({
          type: 'phase_change',
          agent: 'Trainer',
          role: 'developer',
          data: { phase: 'TRAINING_STARTED', iters, message: `Starting LoRA training (${iters} iters) on Apple Silicon Metal...` },
          timestamp: new Date().toISOString(),
        });

        const pythonPath = path.resolve(process.cwd(), '.venv', 'bin', 'python');
        const trainScript = path.resolve(process.cwd(), 'training', 'train.py');
        const child = spawn(pythonPath, [trainScript, iters.toString()], { cwd: process.cwd() });

        child.stdout.on('data', data => {
          const text = data.toString();
          broadcastEvent({
            type: 'tool_call',
            agent: 'Trainer',
            role: 'developer',
            data: { tool: 'mlx_metal_lora', log: text.trim() },
            timestamp: new Date().toISOString(),
          });
        });

        child.stderr.on('data', data => {
          const text = data.toString();
          broadcastEvent({
            type: 'tool_call',
            agent: 'Trainer',
            role: 'developer',
            data: { tool: 'mlx_metal_lora', log: text.trim() },
            timestamp: new Date().toISOString(),
          });
        });

        child.on('close', code => {
          if (code === 0) {
            broadcastEvent({
              type: 'phase_change',
              agent: 'Trainer',
              role: 'developer',
              data: { phase: 'TRAINING_COMPLETED', success: true, message: 'Apple Silicon Metal training complete! LoRA weights updated.' },
              timestamp: new Date().toISOString(),
            });
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ status: 'success', code, message: 'LoRA weights successfully updated on Metal' }));
          } else {
            broadcastEvent({
              type: 'error',
              agent: 'Trainer',
              role: 'developer',
              data: { error: `Training process exited with code ${code}` },
              timestamp: new Date().toISOString(),
            });
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: `Training failed with exit code ${code}` }));
          }
        });
      } catch (err: any) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // Trigger Autonomous Cycle
  if (url.pathname === '/api/cycle' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => (body += chunk));
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');
        const objective = payload.objective || payload.task;
        if (!objective) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Missing objective or task in request body' }));
          return;
        }

        if (payload.async === true) {
          // Asynchronous start with 202
          res.writeHead(202, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: 'started', objective }));

          engine.runAutonomousCycle({
            objective,
            framework: payload.framework || 'flutter',
            onEvent: (event: AgentEvent) => broadcastEvent(event),
          }).catch(err => {
            broadcastEvent({
              type: 'error',
              agent: 'Orchestrator',
              role: 'ceo',
              data: { error: err.message },
              timestamp: new Date().toISOString(),
            });
          });
          return;
        }

        // Synchronous cycle execution returning complete deliverables
        const result = await engine.runAutonomousCycle({
          objective,
          framework: payload.framework || 'flutter',
          onEvent: (event: AgentEvent) => broadcastEvent(event),
        });

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(
          JSON.stringify({
            status: 'success',
            task: objective,
            objective,
            strategy: result.strategy,
            prd: result.prd,
            architecture: result.architecture,
            implementationSummary: result.implementationSummary,
            review: result.review,
            qaReport: result.qaReport,
            codeFiles: result.codeFiles || {},
            toolExecutions: result.toolExecutions || [],
            artifactsPath: result.artifactsPath,
          })
        );
      } catch (err: any) {
        broadcastEvent({
          type: 'error',
          agent: 'Orchestrator',
          role: 'ceo',
          data: { error: err.message },
          timestamp: new Date().toISOString(),
        });
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // Chat with Agents (with tool execution support)
  if (url.pathname === '/api/chat' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => (body += chunk));
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');
        const prompt = payload.prompt;
        const role = payload.role || 'developer';

        if (!prompt) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Missing prompt' }));
          return;
        }

        let agent: any = engine.developer;
        if (role === 'ceo') agent = engine.ceo;
        else if (role === 'product_architect') agent = engine.product;
        else if (role === 'system_architect') agent = engine.architect;
        else if (role === 'code_reviewer') agent = engine.reviewer;
        else if (role === 'qa_tester') agent = engine.qa;

        const response = await agent.execute(prompt, (event: AgentEvent) => {
          broadcastEvent(event);
        });

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ response }));
      } catch (err: any) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // 404
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not found' }));
});

// WebSocket Server for Real-Time Cockpit Streaming
const wss = new WebSocketServer({ server });
const clients = new Set<WebSocket>();

wss.on('connection', ws => {
  clients.add(ws);
  ws.send(
    JSON.stringify({
      type: 'connection_established',
      message: 'Connected to ButaAI Local Gateway Server',
      timestamp: new Date().toISOString(),
    })
  );

  ws.on('close', () => {
    clients.delete(ws);
  });
});

function broadcastEvent(event: AgentEvent) {
  const message = JSON.stringify(event);
  for (const client of clients) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  }
}

server.listen(PORT, () => {
  console.log(`\n⚡ [ButaAI Gateway Server] Live on http://localhost:${PORT}`);
  console.log(`📡 WebSocket Streaming ready on ws://localhost:${PORT}`);
  console.log(`🧠 Local Model Backend: ${process.env.OLLAMA_HOST || 'http://localhost:11434'}\n`);
});

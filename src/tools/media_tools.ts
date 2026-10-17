import fs from 'fs';
import path from 'path';
import { ToolResult } from '../types/index.js';

export interface ImageGenOptions {
  prompt: string;
  filename?: string;
  format?: 'svg' | 'html';
  style?: 'modern_vector' | 'app_icon' | 'badge' | 'ui_mock' | 'diagram';
  customSvg?: string;
}

export interface AnimationGenOptions {
  prompt: string;
  animationType?: 'flutter_motion' | 'css_keyframe' | 'svg_morph';
  filename?: string;
  durationMs?: number;
}

export interface VideoScene {
  sceneNumber: number;
  title: string;
  durationSec: number;
  visualDescription: string;
  kineticMotion: string;
  voiceoverScript: string;
}

export interface VideoGenOptions {
  title: string;
  concept: string;
  scenes?: VideoScene[];
  filename?: string;
}

export class MediaTools {
  private workspaceRoot: string;
  private artifactsDir: string;

  constructor(workspaceRoot: string) {
    this.workspaceRoot = path.resolve(workspaceRoot);
    this.artifactsDir = path.resolve(this.workspaceRoot, '.buta', 'artifacts');
  }

  private ensureDir(dirPath: string): void {
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true });
    }
  }

  /**
   * Generates crisp vector SVG images, UI mocks, app icons, or architecture diagrams
   */
  public async generateImage(callId: string, options: ImageGenOptions): Promise<ToolResult> {
    try {
      const imagesDir = path.join(this.artifactsDir, 'images');
      this.ensureDir(imagesDir);

      const baseName = (options.filename || `asset_${Date.now()}`).replace(/\.[^/.]+$/, '');
      const svgPath = path.join(imagesDir, `${baseName}.svg`);
      const htmlPath = path.join(imagesDir, `${baseName}.html`);

      const svgContent = options.customSvg || this.buildProceduralSvg(options.prompt, options.style || 'modern_vector');
      fs.writeFileSync(svgPath, svgContent, 'utf8');

      // Create an interactive HTML preview container
      const previewHtml = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>ButaAI Media • ${baseName}</title>
  <style>
    body {
      margin: 0;
      background: #F8FAFC;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      color: #0F172A;
    }
    .card {
      background: #FFFFFF;
      padding: 32px;
      border-radius: 24px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.06);
      border: 1px solid #E2E8F0;
      display: flex;
      flex-direction: column;
      align-items: center;
      max-width: 640px;
    }
    .svg-wrapper {
      margin-bottom: 24px;
      max-width: 100%;
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 4px 16px rgba(99,102,241,0.08);
    }
    h2 { margin: 0 0 8px 0; font-size: 20px; font-weight: 700; color: #1E1B4B; }
    p { margin: 0 0 16px 0; font-size: 13px; color: #64748B; text-align: center; }
    .badge {
      font-size: 11px;
      font-weight: 600;
      background: #EEF2FF;
      color: #4F46E5;
      padding: 4px 10px;
      border-radius: 6px;
      margin-bottom: 12px;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">ButaAI Generative Vector Engine</div>
    <h2>${baseName}</h2>
    <p>${options.prompt}</p>
    <div class="svg-wrapper">
      ${svgContent}
    </div>
  </div>
</body>
</html>`;
      fs.writeFileSync(htmlPath, previewHtml, 'utf8');

      const relativeSvg = path.relative(this.workspaceRoot, svgPath);
      const relativeHtml = path.relative(this.workspaceRoot, htmlPath);

      return {
        callId,
        success: true,
        output: `🎨 [ButaAI Media Engine] Generated vector asset successfully!\n` +
          `• SVG Vector: ${relativeSvg} (${svgContent.length} chars)\n` +
          `• Web Preview: ${relativeHtml}\n` +
          `• Preview URL: http://localhost:3030/artifacts/images/${baseName}.html\n` +
          `• Markdown Link: ![${baseName}](http://localhost:3030/artifacts/images/${baseName}.svg)`
      };
    } catch (err: any) {
      return { callId, success: false, output: '', error: `Image generation failed: ${err.message}` };
    }
  }

  /**
   * Generates interactive CSS or Flutter CustomPainter / AnimatedBuilder animations
   */
  public async generateAnimation(callId: string, options: AnimationGenOptions): Promise<ToolResult> {
    try {
      const animDir = path.join(this.artifactsDir, 'animations');
      this.ensureDir(animDir);

      const baseName = (options.filename || `animation_${Date.now()}`).replace(/\.[^/.]+$/, '');
      const type = options.animationType || 'flutter_motion';
      const duration = options.durationMs || 1200;

      // 1. Generate Flutter Code
      const flutterCode = this.buildFlutterAnimationWidget(baseName, options.prompt, duration);
      const flutterPath = path.join(animDir, `${baseName}.dart`);
      fs.writeFileSync(flutterPath, flutterCode, 'utf8');

      // 2. Generate Interactive HTML/CSS Preview
      const htmlCode = this.buildCssAnimationHtml(baseName, options.prompt, duration);
      const htmlPath = path.join(animDir, `${baseName}.html`);
      fs.writeFileSync(htmlPath, htmlCode, 'utf8');

      const relFlutter = path.relative(this.workspaceRoot, flutterPath);
      const relHtml = path.relative(this.workspaceRoot, htmlPath);

      return {
        callId,
        success: true,
        output: `✨ [ButaAI Animation Engine] Generated production animation!\n` +
          `• Type: ${type} (${duration}ms loop)\n` +
          `• Flutter Widget: ${relFlutter} (${flutterCode.length} chars)\n` +
          `• Web Preview: ${relHtml}\n` +
          `• Live Player: http://localhost:3030/artifacts/animations/${baseName}.html\n` +
          `• Usage: Import \`${path.basename(flutterPath)}\` into your Flutter lib directory.`
      };
    } catch (err: any) {
      return { callId, success: false, output: '', error: `Animation generation failed: ${err.message}` };
    }
  }

  /**
   * Generates an 18-second kinetic launch video storyboard & interactive canvas player
   */
  public async generateVideoStoryboard(callId: string, options: VideoGenOptions): Promise<ToolResult> {
    try {
      const videoDir = path.join(this.artifactsDir, 'videos');
      this.ensureDir(videoDir);

      const baseName = (options.filename || `launch_video_${Date.now()}`).replace(/\.[^/.]+$/, '');
      const title = options.title || 'Product Launch Storyboard';
      const concept = options.concept || 'Autonomous Mobile Application';

      const scenes: VideoScene[] = options.scenes && options.scenes.length > 0 ? options.scenes : [
        {
          sceneNumber: 1,
          title: 'The Hook',
          durationSec: 3,
          visualDescription: 'Extreme close-up on mobile glass card with kinetic pulse ring',
          kineticMotion: 'Camera zooms in with spring ease (scale 0.8 -> 1.05), specular lighting sheen',
          voiceoverScript: 'What if software could design, build, and test itself directly on your device?'
        },
        {
          sceneNumber: 2,
          title: 'The Bottleneck',
          durationSec: 4,
          visualDescription: 'Cloud latency icons with red warning alerts and expensive token billing meters',
          kineticMotion: 'Fast cut, glitch transition, cards scatter and dissolve into smoke',
          voiceoverScript: 'Cloud LLMs are slow, cost a fortune per token, and risk your private data.'
        },
        {
          sceneNumber: 3,
          title: 'The Reveal',
          durationSec: 5,
          visualDescription: 'Porcelain Double-Bezel cockpit illuminates with Apple Silicon Metal badge',
          kineticMotion: 'Smooth camera rotation, volumetric glow expands from center, 6 specialist badges lock in',
          voiceoverScript: 'Meet ButaAI: 6 autonomous engineering specialists executing 100% on Apple Silicon Metal GPU.'
        },
        {
          sceneNumber: 4,
          title: 'The Proof',
          durationSec: 3,
          visualDescription: 'Real-time terminal execution: Riverpod 3.x tests passing + simulator screen rendering',
          kineticMotion: 'Code lines type in at 60 FPS, green verification checkmark expands with spring bounce',
          voiceoverScript: 'Zero cloud dependencies. Instant verification. Enterprise-grade Clean Architecture.'
        },
        {
          sceneNumber: 5,
          title: 'The CTA',
          durationSec: 3,
          visualDescription: 'Centered logo reveal with Star on GitHub badge & 1-Click Launch button',
          kineticMotion: 'Radial burst, golden particle cascade, subtle 3D hover float',
          voiceoverScript: 'Fork ButaAI on GitHub today and join the on-device intelligence revolution.'
        }
      ];

      // 1. Save JSON Storyboard Specification
      const jsonPath = path.join(videoDir, `${baseName}.json`);
      fs.writeFileSync(jsonPath, JSON.stringify({ title, concept, scenes }, null, 2), 'utf8');

      // 2. Generate Interactive Canvas Video Player (Plays in browser)
      const playerHtml = this.buildVideoPlayerHtml(title, concept, scenes);
      const playerPath = path.join(videoDir, `${baseName}.html`);
      fs.writeFileSync(playerPath, playerHtml, 'utf8');

      // 3. Generate FFmpeg Command Script
      const shPath = path.join(videoDir, `${baseName}_render.sh`);
      const shScript = `#!/usr/bin/env bash
# ButaAI Automated FFmpeg Video Renderer
# Generates 1080x1080 60FPS video from storyboard frames
OUTPUT_MP4="${baseName}.mp4"
echo "🎬 Rendering 18-second video storyboard: $OUTPUT_MP4..."
ffmpeg -y -f lavfi -i color=c=0x0F172A:s=1080x1080:d=18 -filter_complex \
  "[0:v]drawtext=text='${title.replace(/'/g, "\\'")}':fontcolor=white:fontsize=56:x=(w-text_w)/2:y=(h-text_h)/2-60:enable='between(t,0,3)',\
   drawtext=text='100% On-Device Metal GPU':fontcolor=0x6366F1:fontsize=36:x=(w-text_w)/2:y=(h-text_h)/2+40:enable='between(t,7,12)',\
   drawtext=text='Star on GitHub • ButaAI':fontcolor=0x10B981:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,15,18)'" \
  -c:v libx264 -pix_fmt yuv420p "$OUTPUT_MP4"
echo "✅ Render complete: $OUTPUT_MP4"
`;
      fs.writeFileSync(shPath, shScript, 'utf8');
      try { fs.chmodSync(shPath, 0o755); } catch (_) {}

      const relJson = path.relative(this.workspaceRoot, jsonPath);
      const relHtml = path.relative(this.workspaceRoot, playerPath);
      const relSh = path.relative(this.workspaceRoot, shPath);

      return {
        callId,
        success: true,
        output: `🎬 [ButaAI Video Engine] Created 18-Second Launch Video Storyboard!\n` +
          `• Title: "${title}" (${scenes.length} Scenes, 18.0s Total)\n` +
          `• Storyboard JSON: ${relJson}\n` +
          `• Interactive Player: ${relHtml}\n` +
          `• Live Player URL: http://localhost:3030/artifacts/videos/${baseName}.html\n` +
          `• FFmpeg Render Script: ${relSh}\n` +
          `• Voiceover & Timing breakdown generated and synced.`
      };
    } catch (err: any) {
      return { callId, success: false, output: '', error: `Video storyboard generation failed: ${err.message}` };
    }
  }

  // --- Procedural SVG Helper ---
  private buildProceduralSvg(prompt: string, style: string): string {
    const isDark = prompt.toLowerCase().includes('dark') || prompt.toLowerCase().includes('night');
    const isGym = prompt.toLowerCase().includes('gym') || prompt.toLowerCase().includes('fitness') || prompt.toLowerCase().includes('workout');
    const isCode = prompt.toLowerCase().includes('code') || prompt.toLowerCase().includes('architect') || prompt.toLowerCase().includes('metal');

    const primaryColor = isGym ? '#10B981' : (isCode ? '#6366F1' : '#3B82F6');
    const accentColor = isGym ? '#065F46' : '#4338CA';
    const bgColor = isDark ? '#0F172A' : '#F8FAFC';
    const cardBg = isDark ? '#1E293B' : '#FFFFFF';
    const textColor = isDark ? '#F1F5F9' : '#0F172A';

    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500" width="500" height="500">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="${bgColor}" />
      <stop offset="100%" stop-color="${isDark ? '#020617' : '#E2E8F0'}" />
    </linearGradient>
    <linearGradient id="primaryGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="${primaryColor}" />
      <stop offset="100%" stop-color="${accentColor}" />
    </linearGradient>
    <filter id="cardShadow" x="-10%" y="-10%" width="130%" height="130%">
      <feDropShadow dx="0" dy="12" stdDeviation="16" flood-color="#000000" flood-opacity="0.08" />
    </filter>
  </defs>

  <!-- Background -->
  <rect width="500" height="500" rx="36" fill="url(#bgGrad)" />

  <!-- Outer Double-Bezel Card -->
  <rect x="50" y="50" width="400" height="400" rx="32" fill="${cardBg}" stroke="#CBD5E1" stroke-width="1.5" filter="url(#cardShadow)" />
  
  <!-- Specular Refraction Ring -->
  <circle cx="250" cy="200" r="85" fill="none" stroke="url(#primaryGrad)" stroke-width="6" opacity="0.15" />
  <circle cx="250" cy="200" r="75" fill="url(#primaryGrad)" />
  
  <!-- Center Glyph / Icon -->
  <path d="M 230 175 L 270 200 L 230 225 Z" fill="#FFFFFF" opacity="0.95" />
  <circle cx="250" cy="200" r="45" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-dasharray="8 6" opacity="0.7" />

  <!-- Typography & Metric Badges -->
  <text x="250" y="320" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="22" font-weight="bold" fill="${textColor}" text-anchor="middle">
    ${prompt.length > 28 ? prompt.substring(0, 26) + '...' : prompt}
  </text>
  <text x="250" y="350" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="13" font-weight="600" fill="#64748B" text-anchor="middle">
    ⚡ 100% On-Device Metal GPU • ButaAI
  </text>

  <!-- Status Capsule -->
  <rect x="180" y="375" width="140" height="28" rx="14" fill="${primaryColor}" opacity="0.15" />
  <text x="250" y="394" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="11" font-weight="bold" fill="${primaryColor}" text-anchor="middle">
    VERIFIED & READY
  </text>
</svg>`;
  }

  // --- Flutter Animation Widget Generator ---
  private buildFlutterAnimationWidget(name: string, prompt: string, durationMs: number): string {
    const className = name.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join('') + 'Widget';
    return `import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Generated by ButaAI Multimodal Engine
/// Prompt: "${prompt}"
/// Duration: ${durationMs}ms loop
class ${className} extends StatefulWidget {
  final double size;
  const ${className}({super.key, this.size = 200.0});

  @override
  State<${className}> createState() => _${className}State();
}

class _${className}State extends State<${className}>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: ${durationMs}),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.size * 0.22),
                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.18 * _controller.value),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(widget.size * 0.6, widget.size * 0.6),
                  painter: _KineticRingPainter(_controller.value),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _KineticRingPainter extends CustomPainter {
  final double progress;
  _KineticRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    final bgPaint = Paint()
      ..color = const Color(0xFFEEF2FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, radius, bgPaint);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: const [Color(0xFF6366F1), Color(0xFF10B981), Color(0xFF6366F1)],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.5 * progress,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KineticRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
`;
  }

  // --- Interactive CSS Animation HTML Generator ---
  private buildCssAnimationHtml(name: string, prompt: string, durationMs: number): string {
    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>ButaAI Animation • ${name}</title>
  <style>
    body {
      margin: 0;
      background: #0F172A;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      color: #F8FAFC;
    }
    .stage {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 24px;
    }
    .card {
      width: 240px;
      height: 240px;
      background: rgba(30, 41, 59, 0.7);
      backdrop-filter: blur(16px);
      border-radius: 28px;
      border: 1.5px solid rgba(99, 102, 241, 0.3);
      display: flex;
      align-items: center;
      justify-content: center;
      animation: floatMotion ${durationMs}ms cubic-bezier(0.4, 0, 0.2, 1) infinite alternate;
      box-shadow: 0 16px 40px rgba(99, 102, 241, 0.2);
    }
    .orb {
      width: 100px;
      height: 100px;
      border-radius: 50%;
      background: linear-gradient(135deg, #6366F1, #10B981);
      animation: pulsePulse ${durationMs * 0.75}ms ease-in-out infinite alternate;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 32px;
    }
    @keyframes floatMotion {
      0% { transform: translateY(0px) rotate(-1.5deg) scale(0.96); }
      100% { transform: translateY(-16px) rotate(1.5deg) scale(1.04); }
    }
    @keyframes pulsePulse {
      0% { transform: scale(0.88); filter: drop-shadow(0 0 12px rgba(99, 102, 241, 0.4)); }
      100% { transform: scale(1.12); filter: drop-shadow(0 0 28px rgba(16, 185, 129, 0.7)); }
    }
    h3 { margin: 0; font-size: 18px; font-weight: 700; }
    p { margin: 0; font-size: 12px; color: #94A3B8; text-align: center; }
  </style>
</head>
<body>
  <div class="stage">
    <div class="card">
      <div class="orb">⚡</div>
    </div>
    <h3>${name}</h3>
    <p>${prompt}</p>
  </div>
</body>
</html>`;
  }

  // --- Interactive HTML5 Video Storyboard Player ---
  private buildVideoPlayerHtml(title: string, concept: string, scenes: VideoScene[]): string {
    const scenesJson = JSON.stringify(scenes);
    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>ButaAI Video Player • ${title}</title>
  <style>
    body {
      margin: 0;
      background: #020617;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      color: #F8FAFC;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      padding: 20px;
      box-sizing: border-box;
    }
    .player-container {
      width: 100%;
      max-width: 680px;
      background: #0F172A;
      border-radius: 20px;
      border: 1px solid #1E293B;
      overflow: hidden;
      box-shadow: 0 20px 50px rgba(0,0,0,0.5);
    }
    .screen {
      position: relative;
      width: 100%;
      height: 380px;
      background: radial-gradient(circle at center, #1E1B4B 0%, #020617 100%);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 24px;
      box-sizing: border-box;
      text-align: center;
    }
    .scene-badge {
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 1px;
      color: #10B981;
      background: rgba(16,185,129,0.12);
      padding: 4px 12px;
      border-radius: 20px;
      margin-bottom: 14px;
    }
    .scene-title {
      font-size: 26px;
      font-weight: 800;
      color: #FFFFFF;
      margin-bottom: 12px;
      letter-spacing: -0.5px;
    }
    .scene-desc {
      font-size: 14px;
      color: #94A3B8;
      max-width: 480px;
      line-height: 1.5;
      margin-bottom: 20px;
    }
    .voiceover-box {
      background: rgba(255,255,255,0.06);
      border-left: 3px solid #6366F1;
      padding: 10px 16px;
      border-radius: 6px;
      font-size: 13px;
      color: #E2E8F0;
      font-style: italic;
    }
    .controls {
      display: flex;
      align-items: center;
      padding: 16px 20px;
      background: #090D1A;
      gap: 16px;
    }
    button {
      background: #6366F1;
      color: white;
      border: none;
      padding: 8px 18px;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      font-size: 13px;
    }
    button:hover { background: #4F46E5; }
    .progress-bar {
      flex: 1;
      height: 6px;
      background: #1E293B;
      border-radius: 3px;
      overflow: hidden;
      position: relative;
    }
    .progress-fill {
      width: 0%;
      height: 100%;
      background: linear-gradient(90deg, #6366F1, #10B981);
      transition: width 0.1s linear;
    }
    .time-indicator { font-size: 12px; color: #64748B; font-variant-numeric: tabular-nums; }
  </style>
</head>
<body>
  <div class="player-container">
    <div class="screen" id="screen">
      <div class="scene-badge" id="badge">SCENE 1 • THE HOOK</div>
      <div class="scene-title" id="title">${title}</div>
      <div class="scene-desc" id="desc">${concept}</div>
      <div class="voiceover-box" id="vo">Loading timeline...</div>
    </div>
    <div class="controls">
      <button id="playBtn" onclick="togglePlay()">▶ Play 18s Storyboard</button>
      <div class="progress-bar">
        <div class="progress-fill" id="fill"></div>
      </div>
      <div class="time-indicator" id="timer">00:00 / 00:18</div>
    </div>
  </div>

  <script>
    const scenes = ${scenesJson};
    let isPlaying = false;
    let currentSec = 0;
    let timerId = null;

    function renderScene(sec) {
      let accumulated = 0;
      let activeScene = scenes[0];
      for (const s of scenes) {
        if (sec >= accumulated && sec < accumulated + s.durationSec) {
          activeScene = s;
          break;
        }
        accumulated += s.durationSec;
      }

      document.getElementById('badge').textContent = 'SCENE ' + activeScene.sceneNumber + ' • ' + activeScene.title.toUpperCase();
      document.getElementById('title').textContent = activeScene.title;
      document.getElementById('desc').textContent = activeScene.visualDescription;
      document.getElementById('vo').textContent = '“' + activeScene.voiceoverScript + '”';

      const pct = Math.min(100, (sec / 18) * 100);
      document.getElementById('fill').style.width = pct + '%';
      const formatted = sec < 10 ? '0' + sec : sec;
      document.getElementById('timer').textContent = '00:' + formatted + ' / 00:18';
    }

    function togglePlay() {
      const btn = document.getElementById('playBtn');
      if (isPlaying) {
        clearInterval(timerId);
        isPlaying = false;
        btn.textContent = '▶ Play';
      } else {
        isPlaying = true;
        btn.textContent = '❚❚ Pause';
        if (currentSec >= 18) currentSec = 0;
        timerId = setInterval(() => {
          currentSec++;
          if (currentSec > 18) {
            clearInterval(timerId);
            isPlaying = false;
            btn.textContent = '↺ Replay';
            return;
          }
          renderScene(currentSec);
        }, 1000);
      }
    }

    renderScene(0);
  </script>
</body>
</html>`;
  }
}

import { ModelTier } from '../types/index.js';

export interface GenerateOptions {
  tier?: ModelTier;
  systemPrompt?: string;
  temperature?: number;
  maxTokens?: number;
  streamCallback?: (chunk: string) => void;
}

export interface LLMResponse {
  content: string;
  modelUsed: string;
  tokensEstimated?: number;
}

export class ModelProvider {
  private ollamaHost: string;
  private defaultModel: string;

  constructor() {
    this.ollamaHost = process.env.OLLAMA_HOST || 'http://localhost:11434';
    this.defaultModel = process.env.BUTA_MODEL || 'buta-ai';
  }

  /**
   * Checks if local Ollama daemon is reachable
   */
  public async isLocalEngineAvailable(): Promise<boolean> {
    try {
      const response = await fetch(`${this.ollamaHost}/api/tags`, {
        signal: AbortSignal.timeout(2000),
      });
      return response.ok;
    } catch {
      return false;
    }
  }

  /**
   * Lists available local models
   */
  public async getAvailableModels(): Promise<string[]> {
    try {
      const res = await fetch(`${this.ollamaHost}/api/tags`);
      if (!res.ok) return [];
      const data: any = await res.json();
      return (data.models || []).map((m: any) => m.name);
    } catch {
      return [];
    }
  }

  /**
   * Generates completion using local ButaAI model via Ollama (Zero API Keys)
   */
  public async generate(prompt: string, options: GenerateOptions = {}): Promise<LLMResponse> {
    const isOnline = await this.isLocalEngineAvailable();

    if (!isOnline) {
      return {
        content: `[ButaAI Engine Notice]: Local AI server is starting or not detected on ${this.ollamaHost}.\nRun 'ollama serve' in a terminal to launch the offline Apple Silicon Metal engine.`,
        modelUsed: 'offline-standby',
      };
    }

    const available = await this.getAvailableModels();
    // Prefer buta-ai if created, otherwise fallback to any installed coder model
    let targetModel = this.defaultModel;
    if (!available.some(m => m.includes('buta-ai'))) {
      const fallback = available.find(m => m.includes('coder') || m.includes('llama') || m.includes('qwen'));
      if (fallback) {
        targetModel = fallback;
      }
    }

    try {
      const payload: Record<string, unknown> = {
        model: targetModel,
        prompt: prompt,
        stream: false,
        options: {
          temperature: options.temperature ?? 0.2,
        },
      };

      if (options.systemPrompt) {
        payload.system = options.systemPrompt;
      }

      const response = await fetch(`${this.ollamaHost}/api/generate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const result: any = await response.json();
      return {
        content: result.response || '',
        modelUsed: targetModel,
        tokensEstimated: result.eval_count,
      };
    } catch (err: any) {
      return {
        content: `[ButaAI Local Engine Error]: ${err.message}`,
        modelUsed: targetModel,
      };
    }
  }
}

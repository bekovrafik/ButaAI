import { GoogleGenAI } from '@google/genai';
import { ModelTier } from '../types/index.js';

export interface GenerateOptions {
  tier?: ModelTier;
  systemPrompt?: string;
  temperature?: number;
  maxTokens?: number;
}

export interface LLMResponse {
  content: string;
  modelUsed: string;
  tokensEstimated?: number;
}

export class ModelProvider {
  private geminiClient?: GoogleGenAI;
  private defaultTier: ModelTier = 'flash';

  constructor() {
    const geminiKey = process.env.GEMINI_API_KEY;
    if (geminiKey) {
      this.geminiClient = new GoogleGenAI({ apiKey: geminiKey });
    }
  }

  public setTier(tier: ModelTier) {
    this.defaultTier = tier;
  }

  /**
   * Resolves the concrete model name based on requested tier
   */
  private resolveModelName(tier: ModelTier): string {
    switch (tier) {
      case 'flash':
        return 'gemini-2.5-flash';
      case 'pro':
        return 'gemini-2.5-pro';
      case 'opus':
        return 'claude-3-7-sonnet'; // fallback / external adapter
      case 'local':
        return 'qwen2.5-coder:32b';
      default:
        return 'gemini-2.5-flash';
    }
  }

  /**
   * Generates completion using the appropriate provider
   */
  public async generate(prompt: string, options: GenerateOptions = {}): Promise<LLMResponse> {
    const tier = options.tier || this.defaultTier;
    const model = this.resolveModelName(tier);

    // If Gemini client is configured
    if (this.geminiClient && (tier === 'flash' || tier === 'pro')) {
      try {
        const fullPrompt = options.systemPrompt 
          ? `${options.systemPrompt}\n\nTask:\n${prompt}`
          : prompt;

        const response = await this.geminiClient.models.generateContent({
          model,
          contents: fullPrompt,
        });

        return {
          content: response.text || '',
          modelUsed: model,
        };
      } catch (err: any) {
        // Fallback or return descriptive error
        return {
          content: `[ModelProvider Error]: ${err.message}`,
          modelUsed: model,
        };
      }
    }

    // Deterministic simulation / offline fallback for development without API keys
    return {
      content: `[Offline/Mock Mode: ${model}]\nReceived prompt of ${prompt.length} chars. Ready to execute when GEMINI_API_KEY is supplied.`,
      modelUsed: `mock-${model}`,
    };
  }
}

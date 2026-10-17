import { ModelTier, ChatMessage, ToolDefinition, ToolCall } from '../types/index.js';

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
  toolCalls?: ToolCall[];
}

export interface ChatResponse {
  message: ChatMessage;
  toolCalls?: ToolCall[];
  modelUsed: string;
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
   * Resolves the target model (preferring buta-ai, then coder/qwen/llama)
   */
  public async resolveTargetModel(): Promise<string> {
    const available = await this.getAvailableModels();
    if (available.some(m => m.includes('buta-ai'))) {
      return 'buta-ai';
    }
    const fallback = available.find(m => m.includes('coder') || m.includes('qwen') || m.includes('llama'));
    return fallback || this.defaultModel;
  }

  /**
   * Multi-turn chat with native tool-calling support
   */
  public async chat(
    messages: ChatMessage[],
    tools?: ToolDefinition[],
    options: GenerateOptions = {}
  ): Promise<ChatResponse> {
    const isOnline = await this.isLocalEngineAvailable();
    if (!isOnline) {
      return {
        message: {
          role: 'assistant',
          content: `[ButaAI Local Engine Offline]: Local Ollama daemon is unreachable at ${this.ollamaHost}. Run 'ollama serve' in your terminal.`,
        },
        modelUsed: 'offline-standby',
      };
    }

    const targetModel = await this.resolveTargetModel();

    const payload: Record<string, unknown> = {
      model: targetModel,
      messages: messages.map(m => {
        const item: any = { role: m.role, content: m.content ?? '' };
        if (m.tool_calls) item.tool_calls = m.tool_calls;
        return item;
      }),
      stream: false,
      options: {
        temperature: options.temperature ?? 0.2,
      },
    };

    if (tools && tools.length > 0) {
      payload.tools = tools;
    }

    try {
      const response = await fetch(`${this.ollamaHost}/api/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const result: any = await response.json();
      const assistantMsg = result.message || {};
      const rawContent: string = assistantMsg.content || '';

      // 1. Extract native Ollama tool calls
      const toolCalls: ToolCall[] = [];
      if (assistantMsg.tool_calls && Array.isArray(assistantMsg.tool_calls)) {
        for (const tc of assistantMsg.tool_calls) {
          const fn = tc.function || tc;
          let args = fn.arguments;
          if (typeof args === 'string') {
            try {
              args = JSON.parse(args);
            } catch {
              args = { raw: args };
            }
          }
          toolCalls.push({
            id: tc.id || `call_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
            name: fn.name,
            args: (args as Record<string, unknown>) || {},
          });
        }
      }

      // 2. Fallback parser: if tool_calls wasn't populated but content contains a JSON tool call
      if (toolCalls.length === 0 && rawContent.trim().startsWith('{') && rawContent.includes('"name"') && (rawContent.includes('"arguments"') || rawContent.includes('"parameters"'))) {
        try {
          const parsed = JSON.parse(rawContent.trim());
          if (parsed.name && (parsed.arguments || parsed.parameters)) {
            toolCalls.push({
              id: `call_${Date.now()}`,
              name: parsed.name,
              args: parsed.arguments || parsed.parameters || {},
            });
          }
        } catch {
          // Content is not standalone JSON
        }
      }

      return {
        message: {
          role: 'assistant',
          content: rawContent,
          tool_calls: assistantMsg.tool_calls,
        },
        toolCalls: toolCalls.length > 0 ? toolCalls : undefined,
        modelUsed: targetModel,
      };
    } catch (err: any) {
      return {
        message: {
          role: 'assistant',
          content: `[ButaAI Local Engine Error]: ${err.message}`,
        },
        modelUsed: targetModel,
      };
    }
  }

  /**
   * Single-shot completion generator
   */
  public async generate(prompt: string, options: GenerateOptions = {}): Promise<LLMResponse> {
    const messages: ChatMessage[] = [];
    if (options.systemPrompt) {
      messages.push({ role: 'system', content: options.systemPrompt });
    }
    messages.push({ role: 'user', content: prompt });

    const chatRes = await this.chat(messages, undefined, options);
    return {
      content: chatRes.message.content || '',
      modelUsed: chatRes.modelUsed,
      toolCalls: chatRes.toolCalls,
    };
  }
}

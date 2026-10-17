export type ModelTier = 'flash' | 'pro' | 'opus' | 'local';

export type AgentRole = 
  | 'ceo'
  | 'researcher'
  | 'product_architect'
  | 'designer'
  | 'system_architect'
  | 'planner'
  | 'developer'
  | 'code_reviewer'
  | 'qa_tester'
  | 'release_engineer'
  | 'motion_director'
  | 'swarm_strategist'
  | 'growth_lead';

export type TaskStatus = 
  | 'PENDING'
  | 'IN_PROGRESS'
  | 'TESTING'
  | 'REVIEWING'
  | 'VERIFYING'
  | 'BLOCKED'
  | 'COMPLETED'
  | 'FAILED';

export interface AgentDefinition {
  name: string;
  role: AgentRole;
  description: string;
  systemPrompt: string;
  allowedTools: string[];
  preferredModel: ModelTier;
}

export interface ToolCall {
  id: string;
  name: string;
  args: Record<string, unknown>;
}

export interface ToolResult {
  callId: string;
  success: boolean;
  output: string;
  error?: string;
}

export interface ProjectState {
  name: string;
  version: string;
  framework: 'flutter' | 'react' | 'next' | 'node' | 'vanilla';
  currentPhase: 'IDEATION' | 'SPECIFICATION' | 'TDD_CYCLE' | 'VERIFICATION' | 'RELEASE_READY';
  activeGoal?: string;
  completedTasks: string[];
  pendingTasks: string[];
  blockers: string[];
}

export interface MemorySnapshot {
  timestamp: string;
  summary: string;
  projectDecisions: Array<{ id: string; decision: string; rationale: string; date: string }>;
  learnedInstincts: Array<{ trigger: string; lesson: string; confidence: number }>;
}

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant' | 'tool';
  content?: string;
  name?: string;
  tool_calls?: Array<{
    id?: string;
    type?: string;
    function: {
      name: string;
      arguments: Record<string, unknown> | string;
    };
  }>;
}

export interface ToolDefinition {
  type: 'function';
  function: {
    name: string;
    description: string;
    parameters: {
      type: 'object';
      properties: Record<string, unknown>;
      required?: string[];
    };
  };
}

export interface AgentEvent {
  type: 'agent_start' | 'agent_thought' | 'tool_call' | 'tool_result' | 'agent_finish' | 'phase_change' | 'error';
  agent: string;
  role: AgentRole;
  data: any;
  timestamp: string;
}

export interface PermissionCheck {
  allowed: boolean;
  requiresApproval: boolean;
  reason?: string;
}

export interface CycleResult {
  objective: string;
  strategy: string;
  prd: string;
  architecture: string;
  implementationSummary: string;
  review: string;
  qaReport: string;
  artifactsPath: string;
  codeFiles?: Record<string, string>;
  toolExecutions?: Array<{ tool: string; args?: any; success: boolean; output?: string }>;
}



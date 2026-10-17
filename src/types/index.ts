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
  | 'release_engineer';

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

export interface PermissionCheck {
  allowed: boolean;
  requiresApproval: boolean;
  reason?: string;
}

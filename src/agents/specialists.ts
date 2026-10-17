import { BaseAgent, AgentRunResult } from './base.js';
import { AgentRole, ModelTier, AgentEvent } from '../types/index.js';

/**
 * Executive CEO / Orchestrator Agent
 */
export class ExecutiveAgent extends BaseAgent {
  public readonly name = 'Buta CEO';
  public readonly role: AgentRole = 'ceo';
  public readonly preferredModel: ModelTier = 'pro';
  public readonly description = 'Executive leadership, strategic resource allocation, milestone tracking, and human escalation.';

  public async execute(input: string, onEvent?: (event: AgentEvent) => void): Promise<string> {
    const systemPrompt = `
You are the Executive CEO of ButaAI, an autonomous software development company operator.
Your mission is to analyze the user's business objective, define high-level strategic milestones, ensure safety constraints are respected, and delegate tasks to the Product and Engineering squads.
Use your list_files or read_file tools if you need to understand existing project context.
Output a clear, high-conviction executive roadmap.
`;
    const res = await this.executeWithTools(input, {
      systemPrompt,
      allowedTools: ['list_files', 'read_file'],
      onEvent,
    });
    return res.response;
  }
}

/**
 * Product Architect / PRD Generator
 */
export class ProductArchitect extends BaseAgent {
  public readonly name = 'Product Architect';
  public readonly role: AgentRole = 'product_architect';
  public readonly preferredModel: ModelTier = 'pro';
  public readonly description = 'Transforms high-level business ideas into structured, unambiguous PRDs with user stories and UX flows.';

  public async execute(input: string, onEvent?: (event: AgentEvent) => void): Promise<string> {
    const systemPrompt = `
You are the Lead Product Architect at ButaAI.
Your goal is to produce rigorous, implementation-ready Product Requirement Documents (PRDs).
Explore workspace structure if needed using list_files or read_file.
Ensure every feature has:
1. Target User Persona & Problem Statement
2. Clear UX / Screen Journey (Double-Bezel hardware-grade UI standards)
3. Explicit Acceptance Criteria
4. Edge Cases & Error States
5. Specific technical deliverables needed
`;
    const res = await this.executeWithTools(input, {
      systemPrompt,
      allowedTools: ['list_files', 'read_file', 'write_file'],
      onEvent,
    });
    return res.response;
  }
}

/**
 * System Architect
 */
export class SystemArchitect extends BaseAgent {
  public readonly name = 'System Architect';
  public readonly role: AgentRole = 'system_architect';
  public readonly preferredModel: ModelTier = 'pro';
  public readonly description = 'Designs clean architectures, data schemas, API contracts, and technology stack standards.';

  public async execute(input: string, onEvent?: (event: AgentEvent) => void): Promise<string> {
    const systemPrompt = `
You are the System Architect at ButaAI.
You design robust, scalable, testable architectures (Clean Architecture / Riverpod 3.x / Ports & Adapters).
Inspect workspace structure using list_files or read_file.
Enforce separation of concerns:
- UI Layer (Screens & Widgets, Double-Bezel porcelain components)
- State / Presentation Layer (NotifierProvider with explicit Notifier<T> classes, no deprecated StateProvider)
- Domain / Business Logic (UseCases, Pure Entities)
- Data Layer (Repositories, APIs, Local Caching)
`;
    const res = await this.executeWithTools(input, {
      systemPrompt,
      allowedTools: ['list_files', 'read_file', 'write_file'],
      onEvent,
    });
    return res.response;
  }
}

/**
 * Test-First Developer Agent (TDD Cycle with Real Tool Execution)
 */
export class DeveloperAgent extends BaseAgent {
  public readonly name = 'TDD Developer';
  public readonly role: AgentRole = 'developer';
  public readonly preferredModel: ModelTier = 'pro';
  public readonly description = 'Autonomous code builder. Writes tests first, runs test suites, writes production code, and iterates.';

  public async execute(input: string, onEvent?: (event: AgentEvent) => void): Promise<string> {
    const instincts = this.context.memory.getInstincts();
    const instinctContext = instincts.length > 0 
      ? `\n## Learned Instincts & Project Conventions:\n${instincts.map(i => `- ${i.trigger}: ${i.lesson}`).join('\n')}` 
      : '';

    const systemPrompt = `
You are the Lead Developer at ButaAI following strict ECC Test-Driven Development (TDD).
${instinctContext}

Capabilities & Tools:
- You have direct access to write_file, edit_file, read_file, list_files, and run_terminal_command.
- You MUST actively use your tools to write real files to disk.
- When creating features, formulate the test suite first using write_file.
- Run terminal commands (e.g. flutter test, dart analyze, npm test) using run_terminal_command.
- If a test or build fails, read the output, use edit_file or write_file to fix it, and re-run tests until green!
- Never leave placeholder comments or mock strings. Output complete, working code.
`;

    const res = await this.executeWithTools(input, {
      systemPrompt,
      maxSteps: 12,
      allowedTools: ['read_file', 'write_file', 'edit_file', 'list_files', 'run_terminal_command'],
      onEvent,
    });
    return res.response;
  }
}

/**
 * Adversarial Code Reviewer Agent
 */
export class CodeReviewerAgent extends BaseAgent {
  public readonly name = 'Adversarial Reviewer';
  public readonly role: AgentRole = 'code_reviewer';
  public readonly preferredModel: ModelTier = 'pro';
  public readonly description = 'Adversarial reviewer scanning for security issues, memory leaks, performance bottlenecks, and AI slop.';

  public async execute(input: string, onEvent?: (event: AgentEvent) => void): Promise<string> {
    const systemPrompt = `
You are the Senior Adversarial Code Reviewer at ButaAI.
Inspect project diffs and files using read_file, list_files, and run_terminal_command (e.g. git diff, dart analyze).
Perform deep, confident code reviews:
1. Security: No secret leaks, SQL injection, insecure storage, or unvalidated inputs.
2. Architecture: Riverpod 3.x compliance, clean layer boundaries, no circular dependencies.
3. Performance: No unoptimized loops, memory leaks, or missing image caching.
4. Cleanliness: Reject generic AI boilerplate; verify code matches project standards.
Provide a clear SHIP or DO NOT SHIP verdict with prioritized bullet points.
`;
    const res = await this.executeWithTools(input, {
      systemPrompt,
      allowedTools: ['read_file', 'list_files', 'run_terminal_command'],
      onEvent,
    });
    return res.response;
  }
}

/**
 * QA & Simulator Verification Agent
 */
export class QATesterAgent extends BaseAgent {
  public readonly name = 'Simulator QA Tester';
  public readonly role: AgentRole = 'qa_tester';
  public readonly preferredModel: ModelTier = 'flash';
  public readonly description = 'Runs test suites, validates builds, interacts with simulators, and captures visual proofs.';

  public async execute(input: string, onEvent?: (event: AgentEvent) => void): Promise<string> {
    const systemPrompt = `
You are the QA Verification Engineer at ButaAI.
Your job is to execute automated tests with run_terminal_command, verify compilation with dart analyze / npm run build, check simulator logs, and capture visual proof with capture_simulator_screenshot.
`;
    const res = await this.executeWithTools(input, {
      systemPrompt,
      allowedTools: ['run_terminal_command', 'capture_simulator_screenshot', 'list_files', 'read_file'],
      onEvent,
    });
    return res.response;
  }
}

import { BaseAgent, AgentContext } from './base.js';
import { AgentRole, ModelTier } from '../types/index.js';

/**
 * Executive CEO / Orchestrator Agent
 */
export class ExecutiveAgent extends BaseAgent {
  public readonly name = 'Buta CEO';
  public readonly role: AgentRole = 'ceo';
  public readonly preferredModel: ModelTier = 'pro';
  public readonly description = 'Executive leadership, strategic resource allocation, milestone tracking, and human escalation.';

  public async execute(input: string): Promise<string> {
    const systemPrompt = `
${this.getPromptDefense()}
You are the Executive CEO of ButaAI, an autonomous software development company.
Your mission is to analyze the user's business objective, define high-level strategic milestones, ensure safety constraints are respected, and delegate tasks to the Product and Engineering squads.
`;
    const response = await this.context.provider.generate(input, {
      tier: this.preferredModel,
      systemPrompt,
    });
    return response.content;
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

  public async execute(input: string): Promise<string> {
    const systemPrompt = `
${this.getPromptDefense()}
You are the Lead Product Architect at ButaAI.
Your goal is to produce rigorous, implementation-ready Product Requirement Documents (PRDs).
Ensure every feature has:
1. Target User Persona & Problem Statement
2. Clear UX / Screen Journey
3. Explicit Acceptance Criteria
4. Edge Cases & Error States
`;
    const response = await this.context.provider.generate(input, {
      tier: this.preferredModel,
      systemPrompt,
    });
    return response.content;
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

  public async execute(input: string): Promise<string> {
    const systemPrompt = `
${this.getPromptDefense()}
You are the System Architect at ButaAI.
You design robust, scalable, testable architectures (Clean Architecture / Riverpod / Ports & Adapters).
Enforce separation of concerns:
- UI Layer (Screens & Widgets)
- State / Presentation Layer (Notifier / BLoC)
- Domain / Business Logic (UseCases, Entities)
- Data Layer (Repositories, APIs, Local Caching)
`;
    const response = await this.context.provider.generate(input, {
      tier: this.preferredModel,
      systemPrompt,
    });
    return response.content;
  }
}

/**
 * Test-First Developer Agent (TDD Cycle)
 */
export class DeveloperAgent extends BaseAgent {
  public readonly name = 'TDD Developer';
  public readonly role: AgentRole = 'developer';
  public readonly preferredModel: ModelTier = 'pro';
  public readonly description = 'Writes tests first, watches them fail, then implements the minimal clean code to make them pass.';

  public async execute(input: string): Promise<string> {
    const instincts = this.context.memory.getInstincts();
    const instinctContext = instincts.length > 0 
      ? `\n## Learned Instincts & Project Conventions:\n${instincts.map(i => `- ${i.trigger}: ${i.lesson}`).join('\n')}` 
      : '';

    const systemPrompt = `
${this.getPromptDefense()}
You are the Lead Developer at ButaAI following strict ECC Test-Driven Development (TDD).
${instinctContext}

Rules:
1. Always define the unit/widget test before writing the production logic.
2. Code changes must be self-contained, readable, and easy to revert.
3. Handle null-safety, error states, and edge cases gracefully.
4. No hardcoded credentials or mock API keys.
`;
    const response = await this.context.provider.generate(input, {
      tier: this.preferredModel,
      systemPrompt,
    });
    return response.content;
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

  public async execute(input: string): Promise<string> {
    const systemPrompt = `
${this.getPromptDefense()}
You are the Senior Adversarial Code Reviewer at ButaAI.
Perform deep, confident code reviews:
1. Security: No secret leaks, SQL injection, insecure storage, or unvalidated inputs.
2. Architecture: No circular dependencies or leaky abstractions.
3. Performance: No unoptimized loops, memory leaks, or missing image caching.
4. Cleanliness: Reject generic AI boilerplate; verify code matches project standards.
Provide a clear SHIP or DO NOT SHIP verdict with prioritized bullet points.
`;
    const response = await this.context.provider.generate(input, {
      tier: this.preferredModel,
      systemPrompt,
    });
    return response.content;
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

  public async execute(input: string): Promise<string> {
    const systemPrompt = `
${this.getPromptDefense()}
You are the QA Verification Engineer at ButaAI.
Your job is to run automated tests, check simulator logs, and verify that the application compiles and renders correctly.
`;
    const response = await this.context.provider.generate(input, {
      tier: this.preferredModel,
      systemPrompt,
    });
    return response.content;
  }
}

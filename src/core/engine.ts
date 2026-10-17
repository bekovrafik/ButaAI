import fs from 'fs';
import path from 'path';
import chalk from 'chalk';
import ora from 'ora';
import { ContextKeeper } from '../memory/context-keeper.js';
import { ToolRegistry } from '../tools/index.js';
import { ModelProvider } from '../providers/provider-factory.js';
import { 
  ExecutiveAgent, 
  ProductArchitect, 
  SystemArchitect, 
  DeveloperAgent, 
  CodeReviewerAgent, 
  QATesterAgent 
} from '../agents/specialists.js';
import { AgentEvent, CycleResult } from '../types/index.js';

export interface CompanyCycleOptions {
  objective: string;
  framework?: 'flutter' | 'react' | 'node';
  autoApprove?: boolean;
  onEvent?: (event: AgentEvent) => void;
}

export class ButaEngine {
  private workspaceRoot: string;
  private memory: ContextKeeper;
  private tools: ToolRegistry;
  private provider: ModelProvider;

  // Specialists
  public ceo: ExecutiveAgent;
  public product: ProductArchitect;
  public architect: SystemArchitect;
  public developer: DeveloperAgent;
  public reviewer: CodeReviewerAgent;
  public qa: QATesterAgent;

  constructor(workspaceRoot = process.cwd()) {
    this.workspaceRoot = path.resolve(workspaceRoot);
    this.memory = new ContextKeeper(this.workspaceRoot);
    this.tools = new ToolRegistry(this.workspaceRoot);
    this.provider = new ModelProvider();

    const agentContext = {
      provider: this.provider,
      tools: this.tools,
      memory: this.memory,
    };

    this.ceo = new ExecutiveAgent(agentContext);
    this.product = new ProductArchitect(agentContext);
    this.architect = new SystemArchitect(agentContext);
    this.developer = new DeveloperAgent(agentContext);
    this.reviewer = new CodeReviewerAgent(agentContext);
    this.qa = new QATesterAgent(agentContext);
  }

  public getTools(): ToolRegistry {
    return this.tools;
  }

  public getProvider(): ModelProvider {
    return this.provider;
  }

  public getMemory(): ContextKeeper {
    return this.memory;
  }

  /**
   * Executes an end-to-end Autonomous Software Cycle using local ButaAI with real tool calls
   */
  public async runAutonomousCycle(options: CompanyCycleOptions): Promise<CycleResult> {
    const toolExecutions: Array<{ tool: string; args?: any; success: boolean; output?: string }> = [];
    const onEvent = (event: AgentEvent) => {
      if (event.type === 'tool_result') {
        toolExecutions.push({
          tool: event.data?.tool || event.data?.name || 'tool',
          args: event.data?.args,
          success: event.data?.success ?? true,
          output: typeof event.data?.output === 'string' ? event.data.output.slice(0, 500) : '',
        });
      }
      options.onEvent?.(event);
    };

    const emitPhase = (phase: string) => {
      onEvent({
        type: 'phase_change',
        agent: 'Orchestrator',
        role: 'ceo',
        data: { phase, objective: options.objective },
        timestamp: new Date().toISOString(),
      });
    };

    console.log(chalk.bold.cyan('\n🚀 [ButaAI] Launching Autonomous Software Cycle...'));
    console.log(chalk.gray(`Objective: "${options.objective}"`));
    console.log(chalk.gray(`Workspace: ${this.workspaceRoot}\n`));

    // Update state
    const state = this.memory.getProjectState();
    state.activeGoal = options.objective;
    state.currentPhase = 'SPECIFICATION';
    this.memory.saveProjectState(state);

    // 1. Executive Strategy
    emitPhase('EXECUTIVE_STRATEGY');
    const spinner = ora('Executive Layer: Aligning on business strategy...').start();
    const strategy = await this.ceo.execute(options.objective, onEvent);
    await this.tools.writeFile('call-strat', '.buta/artifacts/STRATEGY.md', strategy);
    spinner.succeed(chalk.green('Executive Layer: Strategy defined.'));

    // 2. Product Specification (PRD)
    emitPhase('PRODUCT_SPECIFICATION');
    spinner.start('Product Squad: Synthesizing PRD and user journeys...');
    const prd = await this.product.execute(
      `Generate comprehensive PRD for: ${options.objective}\nStrategy:\n${strategy}`,
      onEvent
    );
    await this.tools.writeFile('call-prd', '.buta/artifacts/PRD.md', prd);
    spinner.succeed(chalk.green('Product Squad: PRD published to .buta/artifacts/PRD.md'));

    // 3. System Architecture
    emitPhase('SYSTEM_ARCHITECTURE');
    spinner.start('Engineering Squad: Architectural specification & schema design...');
    const arch = await this.architect.execute(
      `Design robust architecture and schemas for PRD:\n${prd}`,
      onEvent
    );
    await this.tools.writeFile('call-arch', '.buta/artifacts/ARCHITECTURE.md', arch);
    this.memory.recordDecision(
      `Architecture for: ${options.objective.slice(0, 30)}...`,
      'New feature initiation',
      'Adopted Clean Architecture with test-first contracts and Riverpod 3.x',
      'Enables modular development and automated testing'
    );
    spinner.succeed(chalk.green('Engineering Squad: Architecture published to .buta/artifacts/ARCHITECTURE.md'));

    // 4. Test-Driven Development (TDD) Loop with Real Tool Execution
    emitPhase('TDD_IMPLEMENTATION');
    spinner.start('Engineering Squad: Running TDD loop (Writing tests & code via tools)...');
    state.currentPhase = 'TDD_CYCLE';
    this.memory.saveProjectState(state);
    
    const devPrompt = `
Objective: ${options.objective}
Architecture Specification:
${arch}

Your assignment:
1. Use write_file to create unit/widget tests covering the core logic.
2. Use run_terminal_command to test or verify syntax (e.g. dart analyze or flutter test or npm test).
3. Use write_file / edit_file to implement the production code until clean.
4. Summarize all files written and tested.
`;
    const devSummary = await this.developer.execute(devPrompt, onEvent);
    await this.tools.writeFile('call-dev', '.buta/artifacts/IMPLEMENTATION.md', devSummary);
    spinner.succeed(chalk.green('Engineering Squad: TDD implementation completed.'));

    // 5. Adversarial Code Review
    emitPhase('CODE_REVIEW');
    spinner.start('Quality Gate: Running adversarial code & security review...');
    const reviewPrompt = `
Review the implementation and architecture for: ${options.objective}
Developer Summary:
${devSummary}
Inspect files using read_file or run_terminal_command if needed.
Provide a SHIP or DO NOT SHIP verdict.
`;
    const review = await this.reviewer.execute(reviewPrompt, onEvent);
    await this.tools.writeFile('call-review', '.buta/artifacts/CODE_REVIEW.md', review);
    spinner.succeed(chalk.green('Quality Gate: Adversarial review completed.'));

    // 6. QA Tester & Simulator Verification
    emitPhase('QA_VERIFICATION');
    spinner.start('QA Squad: Executing verification tests & capturing simulator proof...');
    const qaPrompt = `
Verify the project for objective: ${options.objective}.
Run static analysis and tests using run_terminal_command.
Capture simulator screenshot using capture_simulator_screenshot if simulator is active.
`;
    const qaReport = await this.qa.execute(qaPrompt, onEvent);
    await this.tools.writeFile('call-qa', '.buta/artifacts/QA_REPORT.md', qaReport);
    spinner.succeed(chalk.green('QA Squad: Verification report generated.'));

    // 7. Verification & Memory Snapshot
    emitPhase('COMPLETED');
    spinner.start('Memory Engine: Capturing session state and recording instincts...');
    state.currentPhase = 'VERIFICATION';
    state.completedTasks.push(options.objective);
    this.memory.saveProjectState(state);
    this.memory.createSnapshot(`Completed cycle for: ${options.objective}`);
    spinner.succeed(chalk.green('Memory Engine: Session snapshot preserved.'));

    console.log(chalk.bold.green('\n✅ [ButaAI] Cycle execution completed successfully!'));
    console.log(chalk.white('Artifacts ready in: ') + chalk.yellow('.buta/artifacts/\n'));

    const artifactsDir = path.resolve(this.workspaceRoot, '.buta', 'artifacts');
    const codeFiles: Record<string, string> = {};
    if (fs.existsSync(artifactsDir)) {
      const files = fs.readdirSync(artifactsDir);
      for (const f of files) {
        if (f.endsWith('.md') || f.endsWith('.dart') || f.endsWith('.ts') || f.endsWith('.json')) {
          codeFiles[f] = fs.readFileSync(path.join(artifactsDir, f), 'utf8');
        }
      }
    }

    return {
      objective: options.objective,
      strategy,
      prd,
      architecture: arch,
      implementationSummary: devSummary,
      review,
      qaReport,
      artifactsPath: artifactsDir,
      codeFiles,
      toolExecutions,
    };
  }
}

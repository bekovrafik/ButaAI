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

export interface CompanyCycleOptions {
  objective: string;
  framework?: 'flutter' | 'react' | 'node';
  autoApprove?: boolean;
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

  /**
   * Executes an end-to-end Autonomous Software Cycle
   */
  public async runAutonomousCycle(options: CompanyCycleOptions): Promise<void> {
    console.log(chalk.bold.cyan('\n🚀 [ButaAI] Launching Autonomous Software Cycle...'));
    console.log(chalk.gray(`Objective: "${options.objective}"`));
    console.log(chalk.gray(`Workspace: ${this.workspaceRoot}\n`));

    // Update state
    const state = this.memory.getProjectState();
    state.activeGoal = options.objective;
    state.currentPhase = 'SPECIFICATION';
    this.memory.saveProjectState(state);

    // 1. Executive Strategy
    const spinner = ora('Executive Layer: Aligning on business strategy...').start();
    const strategy = await this.ceo.execute(options.objective);
    spinner.succeed(chalk.green('Executive Layer: Strategy defined.'));

    // 2. Product Specification (PRD)
    spinner.start('Product Squad: Synthesizing PRD and user journeys...');
    const prd = await this.product.execute(`Generate PRD for: ${options.objective}\nStrategy:\n${strategy}`);
    await this.tools.writeFile('call-prd', '.buta/artifacts/PRD.md', prd);
    spinner.succeed(chalk.green('Product Squad: PRD published to .buta/artifacts/PRD.md'));

    // 3. System Architecture
    spinner.start('Engineering Squad: Architectural specification & schema design...');
    const arch = await this.architect.execute(`Design architecture for PRD:\n${prd}`);
    await this.tools.writeFile('call-arch', '.buta/artifacts/ARCHITECTURE.md', arch);
    this.memory.recordDecision(
      `Architecture for: ${options.objective.slice(0, 30)}...`,
      'New feature initiation',
      'Adopted layered architecture with test-first contracts',
      'Enables modular development and automated testing'
    );
    spinner.succeed(chalk.green('Engineering Squad: Architecture published to .buta/artifacts/ARCHITECTURE.md'));

    // 4. Test-Driven Development (TDD)
    spinner.start('Engineering Squad: Running TDD loop (Tests ➔ Implementation)...');
    state.currentPhase = 'TDD_CYCLE';
    this.memory.saveProjectState(state);
    const codePlan = await this.developer.execute(`Formulate TDD implementation plan for:\n${arch}`);
    await this.tools.writeFile('call-plan', '.buta/artifacts/TDD_PLAN.md', codePlan);
    spinner.succeed(chalk.green('Engineering Squad: TDD plan constructed.'));

    // 5. Adversarial Code Review
    spinner.start('Quality Gate: Running adversarial code & security review...');
    const review = await this.reviewer.execute(`Review architecture and TDD plan for security and quality:\n${codePlan}`);
    await this.tools.writeFile('call-review', '.buta/artifacts/CODE_REVIEW.md', review);
    spinner.succeed(chalk.green('Quality Gate: Adversarial review completed.'));

    // 6. Verification & Memory Snapshot
    spinner.start('Memory Engine: Capturing session state and recording instincts...');
    state.currentPhase = 'VERIFICATION';
    state.completedTasks.push(options.objective);
    this.memory.saveProjectState(state);
    this.memory.createSnapshot(`Completed cycle for: ${options.objective}`);
    spinner.succeed(chalk.green('Memory Engine: Session snapshot preserved.'));

    console.log(chalk.bold.green('\n✅ [ButaAI] Cycle execution completed successfully!'));
    console.log(chalk.white('Artifacts ready in: ') + chalk.yellow('.buta/artifacts/\n'));
  }

  public getMemory(): ContextKeeper {
    return this.memory;
  }
}

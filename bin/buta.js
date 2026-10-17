#!/usr/bin/env node
"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const commander_1 = require("commander");
const chalk_1 = __importDefault(require("chalk"));
const dotenv_1 = __importDefault(require("dotenv"));
const engine_js_1 = require("../src/core/engine.js");
const context_keeper_js_1 = require("../src/memory/context-keeper.js");
dotenv_1.default.config();
const program = new commander_1.Command();
program
    .name('buta')
    .description('ButaAI: Autonomous AI Software Company Operator (ECC-powered)')
    .version('1.0.0');
// Command: run
program
    .command('run')
    .description('Run an autonomous end-to-end development cycle for an objective')
    .argument('<objective>', 'The product or feature objective')
    .option('-f, --framework <type>', 'Target framework (flutter, react, node)', 'flutter')
    .action(async (objective, options) => {
    const engine = new engine_js_1.ButaEngine();
    await engine.runAutonomousCycle({
        objective,
        framework: options.framework,
    });
});
// Command: plan
program
    .command('plan')
    .description('Generate PRD and architecture plan for an objective')
    .argument('<objective>', 'The feature or product idea')
    .action(async (objective) => {
    console.log(chalk_1.default.cyan(`\n[ButaAI] Planning: "${objective}"\n`));
    const engine = new engine_js_1.ButaEngine();
    const prd = await engine.product.execute(objective);
    console.log(chalk_1.default.bold.yellow('\n--- Product Requirement Document (PRD) ---'));
    console.log(prd);
});
// Command: review
program
    .command('review')
    .description('Run adversarial code & security review on project changes')
    .action(async () => {
    console.log(chalk_1.default.cyan('\n[ButaAI] Running Adversarial Code Review...\n'));
    const engine = new engine_js_1.ButaEngine();
    const diff = await engine['tools'].runTerminalCommand('review-diff', 'git diff HEAD~1');
    const result = await engine.reviewer.execute(diff.output || 'No recent diff found. Reviewing project layout.');
    console.log(chalk_1.default.bold.yellow('\n--- Code Review Report ---'));
    console.log(result);
});
// Command: status
program
    .command('status')
    .description('Display project memory, phase, ADRs, and learned instincts')
    .action(() => {
    const memory = new context_keeper_js_1.ContextKeeper(process.cwd());
    const state = memory.getProjectState();
    const instincts = memory.getInstincts();
    const decisions = memory.getDecisions();
    console.log(chalk_1.default.bold.cyan('\n================ ButaAI Project Status ================\n'));
    console.log(`${chalk_1.default.bold('Project:')}      ${state.name} (v${state.version})`);
    console.log(`${chalk_1.default.bold('Framework:')}    ${state.framework}`);
    console.log(`${chalk_1.default.bold('Phase:')}        ${chalk_1.default.yellow(state.currentPhase)}`);
    console.log(`${chalk_1.default.bold('Active Goal:')}  ${state.activeGoal || '(None)'}`);
    console.log(chalk_1.default.bold.cyan('\n--- Learned Instincts (' + instincts.length + ') ---'));
    if (instincts.length === 0) {
        console.log(chalk_1.default.gray('No instincts recorded yet.'));
    }
    else {
        for (const inst of instincts) {
            console.log(`• ${chalk_1.default.green(inst.trigger)} ➔ ${inst.lesson} (${Math.round(inst.confidence * 100)}% conf)`);
        }
    }
    console.log(chalk_1.default.bold.cyan('\n--- Architectural Decisions (' + decisions.length + ') ---'));
    if (decisions.length === 0) {
        console.log(chalk_1.default.gray('No ADRs recorded yet.'));
    }
    else {
        for (const d of decisions) {
            console.log(`[${d.id}] ${chalk_1.default.bold(d.title)} (${d.date}): ${d.decision}`);
        }
    }
    console.log(chalk_1.default.bold.cyan('\n=======================================================\n'));
});
// Command: instinct
program
    .command('instinct')
    .description('Teach ButaAI a permanent engineering rule or pattern')
    .argument('<trigger>', 'The trigger condition or technology (e.g., "Flutter Riverpod")')
    .argument('<lesson>', 'The lesson to remember (e.g., "Use NotifierProvider instead of StateProvider in 3.x")')
    .action((trigger, lesson) => {
    const memory = new context_keeper_js_1.ContextKeeper(process.cwd());
    const recorded = memory.recordInstinct(trigger, lesson);
    console.log(chalk_1.default.green(`\n✔ Instinct permanently recorded: [${recorded.trigger}] ➔ "${recorded.lesson}"\n`));
});
program.parse(process.argv);
//# sourceMappingURL=buta.js.map
import fs from 'fs';
import path from 'path';
import { MemorySnapshot, ProjectState } from '../types/index.js';

export interface Instinct {
  id: string;
  trigger: string;
  lesson: string;
  confidence: number;
  tags: string[];
}

export interface ADR {
  id: string;
  title: string;
  status: 'PROPOSED' | 'ACCEPTED' | 'REJECTED' | 'SUPERSEDED';
  context: string;
  decision: string;
  consequences: string;
  date: string;
}

export class ContextKeeper {
  private baseDir: string;
  private stateFile: string;
  private instinctsFile: string;
  private adrFile: string;

  constructor(workspaceRoot: string) {
    this.baseDir = path.join(workspaceRoot, '.buta', 'memory');
    this.stateFile = path.join(this.baseDir, 'state.json');
    this.instinctsFile = path.join(this.baseDir, 'instincts.json');
    this.adrFile = path.join(this.baseDir, 'decisions.json');
    this.ensureStorage();
  }

  private ensureStorage() {
    if (!fs.existsSync(this.baseDir)) {
      fs.mkdirSync(this.baseDir, { recursive: true });
    }
  }

  public getProjectState(): ProjectState {
    if (fs.existsSync(this.stateFile)) {
      try {
        return JSON.parse(fs.readFileSync(this.stateFile, 'utf8'));
      } catch {
        // Fallback default
      }
    }
    return {
      name: 'Uninitialized Project',
      version: '0.1.0',
      framework: 'flutter',
      currentPhase: 'IDEATION',
      completedTasks: [],
      pendingTasks: [],
      blockers: [],
    };
  }

  public saveProjectState(state: ProjectState): void {
    fs.writeFileSync(this.stateFile, JSON.stringify(state, null, 2), 'utf8');
  }

  public recordInstinct(trigger: string, lesson: string, tags: string[] = []): Instinct {
    const instincts = this.getInstincts();
    const existing = instincts.find(i => i.trigger.toLowerCase() === trigger.toLowerCase());

    if (existing) {
      existing.lesson = lesson;
      existing.confidence = Math.min(1.0, existing.confidence + 0.1);
      existing.tags = Array.from(new Set([...existing.tags, ...tags]));
      this.saveInstincts(instincts);
      return existing;
    }

    const newInstinct: Instinct = {
      id: `instinct-${Date.now()}`,
      trigger,
      lesson,
      confidence: 0.7,
      tags,
    };
    instincts.push(newInstinct);
    this.saveInstincts(instincts);
    return newInstinct;
  }

  public getInstincts(): Instinct[] {
    if (fs.existsSync(this.instinctsFile)) {
      try {
        return JSON.parse(fs.readFileSync(this.instinctsFile, 'utf8'));
      } catch {
        return [];
      }
    }
    return [];
  }

  private saveInstincts(instincts: Instinct[]): void {
    fs.writeFileSync(this.instinctsFile, JSON.stringify(instincts, null, 2), 'utf8');
  }

  public recordDecision(title: string, context: string, decision: string, consequences: string): ADR {
    const adrs = this.getDecisions();
    const newAdr: ADR = {
      id: `ADR-${(adrs.length + 1).toString().padStart(3, '0')}`,
      title,
      status: 'ACCEPTED',
      context,
      decision,
      consequences,
      date: new Date().toISOString().split('T')[0],
    };
    adrs.push(newAdr);
    fs.writeFileSync(this.adrFile, JSON.stringify(adrs, null, 2), 'utf8');
    return newAdr;
  }

  public getDecisions(): ADR[] {
    if (fs.existsSync(this.adrFile)) {
      try {
        return JSON.parse(fs.readFileSync(this.adrFile, 'utf8'));
      } catch {
        return [];
      }
    }
    return [];
  }

  public createSnapshot(summary: string): MemorySnapshot {
    const snapshot: MemorySnapshot = {
      timestamp: new Date().toISOString(),
      summary,
      projectDecisions: this.getDecisions().map(d => ({
        id: d.id,
        decision: d.decision,
        rationale: d.context,
        date: d.date,
      })),
      learnedInstincts: this.getInstincts().map(i => ({
        trigger: i.trigger,
        lesson: i.lesson,
        confidence: i.confidence,
      })),
    };

    const snapshotDir = path.join(this.baseDir, 'snapshots');
    if (!fs.existsSync(snapshotDir)) {
      fs.mkdirSync(snapshotDir, { recursive: true });
    }
    const snapFile = path.join(snapshotDir, `snapshot-${Date.now()}.json`);
    fs.writeFileSync(snapFile, JSON.stringify(snapshot, null, 2), 'utf8');
    return snapshot;
  }
}

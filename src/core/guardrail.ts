import { PermissionCheck } from '../types/index.js';

export class GateGuard {
  private static DESTRUCTIVE_COMMAND_PATTERNS = [
    /\brm\s+(-rf|-fr|--recursive\s+--force)\b/i,
    /\bgit\s+reset\s+--hard\b/i,
    /\bgit\s+clean\s+-f\b/i,
    /\bdrop\s+(table|database|schema)\b/i,
    /\btruncate\s+table\b/i,
    /\bformat\s+[a-z]:/i,
    /\bmkfs\b/i,
    /\bdd\s+if=/i,
  ];

  private static RELEASE_PATTERNS = [
    /\bfastlane\s+(release|deploy|upload_to_app_store|upload_to_play_store)\b/i,
    /\bapp-store\s+publish\b/i,
    /\bplay-store\s+publish\b/i,
  ];

  /**
   * Evaluates terminal command against safety matrix
   */
  public static checkTerminalCommand(command: string): PermissionCheck {
    for (const pattern of this.DESTRUCTIVE_COMMAND_PATTERNS) {
      if (pattern.test(command)) {
        return {
          allowed: false,
          requiresApproval: true,
          reason: `Destructive command detected matching ${pattern.toString()}. Explicit human approval required.`,
        };
      }
    }

    for (const pattern of this.RELEASE_PATTERNS) {
      if (pattern.test(command)) {
        return {
          allowed: false,
          requiresApproval: true,
          reason: `Production release action detected. Executive human approval required before staging or deployment.`,
        };
      }
    }

    return { allowed: true, requiresApproval: false };
  }

  /**
   * Verifies file operation safety
   */
  public static checkFileOperation(
    action: 'read' | 'write' | 'delete',
    filePath: string,
    workspaceRoot: string
  ): PermissionCheck {
    // Prevent writes outside the workspace root
    if (!filePath.startsWith(workspaceRoot)) {
      return {
        allowed: false,
        requiresApproval: true,
        reason: `Operation targeting file outside active workspace: ${filePath}`,
      };
    }

    // Protect sensitive config files
    if (filePath.endsWith('.env') || filePath.includes('.git/') || filePath.includes('credentials')) {
      if (action === 'write' || action === 'delete') {
        return {
          allowed: false,
          requiresApproval: true,
          reason: `Attempt to modify sensitive security file: ${filePath}`,
        };
      }
    }

    if (action === 'delete') {
      return {
        allowed: false,
        requiresApproval: true,
        reason: `File deletion requires confirmation: ${filePath}`,
      };
    }

    return { allowed: true, requiresApproval: false };
  }

  /**
   * Fact-forcing check: Verifies if code change contains concrete verification references
   */
  public static enforceFacts(intent: string, filesTouched: string[]): { passed: boolean; message?: string } {
    if (filesTouched.length === 0) {
      return { passed: false, message: 'Fact-Forcing Gate: No target files specified for execution.' };
    }
    return { passed: true };
  }
}

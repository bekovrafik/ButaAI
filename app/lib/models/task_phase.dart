enum TaskPhase {
  idle,
  planning,
  testDrivenDesign,
  implementation,
  adversarialReview,
  simulatorVerification,
  memoryRetention;

  String get displayName {
    switch (this) {
      case TaskPhase.idle:
        return 'Standby';
      case TaskPhase.planning:
        return '1. PRD & Plan';
      case TaskPhase.testDrivenDesign:
        return '2. TDD Tests';
      case TaskPhase.implementation:
        return '3. Code Diff';
      case TaskPhase.adversarialReview:
        return '4. Code Review';
      case TaskPhase.simulatorVerification:
        return '5. Sim Verify';
      case TaskPhase.memoryRetention:
        return '6. Remember';
    }
  }

  String get description {
    switch (this) {
      case TaskPhase.idle:
        return 'Ready for next executive objective';
      case TaskPhase.planning:
        return 'Product Architect formulating PRD & user journeys';
      case TaskPhase.testDrivenDesign:
        return 'Writing failing unit and widget tests before implementation';
      case TaskPhase.implementation:
        return 'Writing minimal, clean code to turn test suites green';
      case TaskPhase.adversarialReview:
        return 'AgentShield & Reviewer scanning for bugs, leaks, and AI slop';
      case TaskPhase.simulatorVerification:
        return 'Verifying on simulator runtime with screenshot capture';
      case TaskPhase.memoryRetention:
        return 'Recording learned instincts and ADR into persistent vault';
    }
  }
}

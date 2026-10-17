class LearnedInstinct {
  final String id;
  final String trigger;
  final String rule;
  final double confidence;
  final DateTime learnedAt;

  LearnedInstinct({
    required this.id,
    required this.trigger,
    required this.rule,
    required this.confidence,
    required this.learnedAt,
  });

  factory LearnedInstinct.fromJson(Map<String, dynamic> json) {
    return LearnedInstinct(
      id: json['id'] as String? ?? 'ins-${DateTime.now().millisecondsSinceEpoch}',
      trigger: json['trigger'] as String? ?? '',
      rule: json['rule'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      learnedAt: json['learnedAt'] != null 
          ? DateTime.tryParse(json['learnedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trigger': trigger,
      'rule': rule,
      'confidence': confidence,
      'learnedAt': learnedAt.toIso8601String(),
    };
  }
}

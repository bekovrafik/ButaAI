import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent_message.dart';

class ButaLocalService {
  final String host;
  final String modelName;

  ButaLocalService({
    this.host = 'http://localhost:11434',
    this.modelName = 'buta-ai',
  });

  /// Check if local Apple Silicon Ollama engine is reachable
  Future<bool> isEngineOnline() async {
    try {
      final response = await http
          .get(Uri.parse('$host/api/tags'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Get list of installed local models
  Future<List<String>> getInstalledModels() async {
    try {
      final response = await http
          .get(Uri.parse('$host/api/tags'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final models = (data['models'] as List<dynamic>? ?? []);
        return models.map((m) => m['name'] as String).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Generate completion from local buta-ai model (Zero Cloud Keys)
  Future<String> generate({
    required String prompt,
    required AgentRole role,
    double temperature = 0.2,
  }) async {
    final systemPrompt = _getSystemPromptForRole(role);

    try {
      final response = await http.post(
        Uri.parse('$host/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': modelName,
          'prompt': prompt,
          'system': systemPrompt,
          'stream': false,
          'options': {
            'temperature': temperature,
            'num_ctx': 32768,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['response'] as String? ?? '').trim();
      } else {
        return '[ButaAI Engine HTTP ${response.statusCode}]: Failed to generate response.';
      }
    } catch (e) {
      return '[ButaAI Local Engine Offline]: Please ensure Ollama is running (`brew services start ollama` or `ollama serve`). Details: $e';
    }
  }

  /// Streaming generator for real-time typewriter effect
  Stream<String> generateStream({
    required String prompt,
    required AgentRole role,
    double temperature = 0.2,
  }) async* {
    final systemPrompt = _getSystemPromptForRole(role);
    final request = http.Request('POST', Uri.parse('$host/api/generate'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': modelName,
        'prompt': prompt,
        'system': systemPrompt,
        'stream': true,
        'options': {
          'temperature': temperature,
          'num_ctx': 32768,
        },
      });

    try {
      final streamedResponse = await request.send();
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          try {
            final json = jsonDecode(line) as Map<String, dynamic>;
            final text = json['response'] as String? ?? '';
            if (text.isNotEmpty) {
              yield text;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      yield '\n[Engine connection error: $e]';
    }
  }

  String _getSystemPromptForRole(AgentRole role) {
    switch (role) {
      case AgentRole.ceo:
        return 'You are the Executive CEO AI of Butalabs. You oversee product strategy, risk mitigation, and coordinate all specialist agents to achieve business goals according to ECC standards.';
      case AgentRole.productArchitect:
        return 'You are the Product Architect AI. You write rigorous Product Requirement Documents (PRDs), user journeys, and unambiguous acceptance criteria with edge cases.';
      case AgentRole.systemArchitect:
        return 'You are the System Architect AI. You design Clean Architecture boundaries, state management (Riverpod/BLoC), repositories, and document Architectural Decision Records (ADRs).';
      case AgentRole.developer:
        return 'You are the TDD Developer AI. You write failing tests first (test-driven development), then write minimal, surgical code to make all test suites pass.';
      case AgentRole.codeReviewer:
        return 'You are the Adversarial Reviewer AI & AgentShield. You rigorously inspect code diffs for security bugs, memory leaks, performance traps, and AI slop.';
      case AgentRole.qaSimulator:
        return 'You are the QA Simulator Runner AI. You verify mobile & web user experiences on simulators (simctl / adb), checking interactive flows and UI layout.';
      default:
        return 'You are ButaAI, the autonomous local AI software company operator by Butalabs.';
    }
  }
}

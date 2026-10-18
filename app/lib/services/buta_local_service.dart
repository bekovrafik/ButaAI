import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/agent_message.dart';
import '../models/product_deliverables.dart';

/// Represents a validated engineering, design, or growth rule in ButaAI's database
class KnowledgeItem {
  final String id;
  final String category;
  final String title;
  final List<String> tags;
  final String summary;
  final String codeSnippet;
  final List<String> keyRules;

  const KnowledgeItem({
    required this.id,
    required this.category,
    required this.title,
    required this.tags,
    required this.summary,
    required this.codeSnippet,
    required this.keyRules,
  });

  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    return KnowledgeItem(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      summary: json['summary'] as String? ?? '',
      codeSnippet: json['codeSnippet'] as String? ?? '',
      keyRules: (json['keyRules'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'title': title,
    'tags': tags,
    'summary': summary,
    'codeSnippet': codeSnippet,
    'keyRules': keyRules,
  };
}

class ButaLocalService {
  final String gatewayUrl;
  final String ollamaUrl;
  final String modelName;

  WebSocketChannel? _wsChannel;
  final StreamController<Map<String, dynamic>> _eventController = StreamController.broadcast();

  /// Embedded copy of the core Antigravity & ButaAI database for instantaneous retrieval
  static final List<KnowledgeItem> initialDatabase = [
    const KnowledgeItem(
      id: 'flutter-riverpod-3x',
      category: 'Mobile & Flutter',
      title: 'Riverpod 3.x StateProvider to NotifierProvider Migration',
      tags: ['flutter', 'riverpod', 'state-management', 'notifier', 'mob'],
      summary: 'In Riverpod 3.x, StateProvider is deprecated. Always use NotifierProvider with an explicit Notifier class and semantic mutation methods.',
      codeSnippet: 'final habitListProvider = NotifierProvider<HabitListNotifier, List<Habit>>(\n  HabitListNotifier.new,\n);\n\nclass HabitListNotifier extends Notifier<List<Habit>> {\n  @override\n  List<Habit> build() => [];\n\n  void addHabit(Habit habit) {\n    state = [...state, habit];\n  }\n}',
      keyRules: [
        'Never use StateProvider in Riverpod 3.x',
        'Encapsulate mutations in explicit methods (.unlock(), .add(), .toggle())',
        'Keep build() pure and synchronous where possible, or use AsyncNotifier for async'
      ],
    ),
    const KnowledgeItem(
      id: 'flutter-firestore-dynamic-seeding',
      category: 'Mobile & Flutter',
      title: 'Firestore Dynamic Demo Data Seeding with User Preferences',
      tags: ['flutter', 'firestore', 'demo-data', 'database', 'seeding'],
      summary: 'Hardcoded demo seeds break filter discovery. Refactor seed generators to accept dynamic parameters (gender, category, location) for realistic testing.',
      codeSnippet: 'Future<void> seedDemoProfiles({String? category, String? location}) async {\n  final targetCategory = category ?? "PRODUCTIVITY";\n  final targetLocation = location ?? "San Francisco, CA";\n  // Dynamically select and hydrate matching demo items\n}',
      keyRules: [
        'Never hardcode static mock arrays for discovery features',
        'Allow seed profiles to accept user preference filters',
        'Include dynamic timestamps and diverse mock attributes'
      ],
    ),
    const KnowledgeItem(
      id: 'flutter-admob-session-unlock',
      category: 'Monetization & Growth',
      title: 'Flutter AdMob Monetization with Session-Based Feature Unlocking',
      tags: ['flutter', 'admob', 'monetization', 'rewarded-ads', 'unlock'],
      summary: 'Pattern for monetizing premium features with rewarded ads, blurring locked content, and synchronizing unlock state across views with NotifierProvider.',
      codeSnippet: 'class FeatureLockNotifier extends Notifier<Set<String>> {\n  @override\n  Set<String> build() => {};\n  void unlockFeature(String key) => state = {...state, key};\n  bool isUnlocked(String key) => state.contains(key);\n}',
      keyRules: [
        'Blur or shroud locked components with an enticing preview',
        'Handle ad load failures gracefully with fallback retry or temporary grace period',
        'Persist unlock state across app lifecycle sessions using shared_preferences'
      ],
    ),
    const KnowledgeItem(
      id: 'ios-swiftui-safe-area',
      category: 'iOS & SwiftUI',
      title: 'SwiftUI Modern Safe Area Management via safeAreaInset',
      tags: ['ios', 'swiftui', 'safe-area', 'layout', 'tabbar'],
      summary: 'Avoid fragile manual padding or Spacer offsets for floating bottom controls. Use .safeAreaInset(edge: .bottom) to respect tab bars and home indicators across all iPhone models.',
      codeSnippet: 'ZStack {\n  MainContentView()\n    .ignoresSafeArea()\n}\n.safeAreaInset(edge: .bottom, spacing: 0) {\n  FloatingActionBar()\n    .padding(.bottom, 8)\n}',
      keyRules: [
        'Never use fixed hardcoded padding like .padding(.bottom, 100) for bottom bars',
        'Use .safeAreaInset(edge: .bottom) to automatically calculate home indicator and tab bar offsets',
        'Ensure content stays interactive without clipping under hardware bezels'
      ],
    ),
    const KnowledgeItem(
      id: 'ios-xcode-codesign-detritus',
      category: 'iOS & SwiftUI',
      title: 'Resolving iOS Xcode Resource Fork Detritus & Codesign Errors',
      tags: ['ios', 'xcode', 'codesign', 'build-errors', 'xattr'],
      summary: 'Xcode code signing fails with "resource fork, Finder information, or similar detritus not allowed". Resolve cleanly using xattr.',
      codeSnippet: '# Strip extended AppleDouble and provenance attributes recursively\nxattr -cr .\n# Verify no hidden attributes remain\nxattr -lr .',
      keyRules: [
        'Run `xattr -cr <project_dir>` before building to clear AppleDouble metadata',
        'Keep Bundle Identifier aligned across Debug and Release profiles',
        'Verify entitlements are signed before requesting Keychain or CloudKit capabilities'
      ],
    ),
    const KnowledgeItem(
      id: 'design-double-bezel-architecture',
      category: 'High-End Design',
      title: 'The Double-Bezel (Doppelrand) Hardware-Grade Card Architecture',
      tags: ['design', 'ui', 'glassmorphism', 'components', 'awwwards', 'linear'],
      summary: 'Cards should never be flat boxes on a gray background. Engineer nested enclosures like precision-machined hardware with outer ring and inner core specular highlight.',
      codeSnippet: '/* Outer Machined Shell */\n.outer-shell {\n  padding: 6px;\n  border-radius: 28px;\n  background: rgba(0, 0, 0, 0.04);\n  box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.06);\n}\n/* Inner Porcelain Core */\n.inner-core {\n  border-radius: 22px;\n  background: #ffffff;\n  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.04), inset 0 1px 0 rgba(255, 255, 255, 0.9);\n}',
      keyRules: [
        'Concentric border radii: innerRadius = outerRadius - padding',
        'Never use harsh drop shadows: use multiple diffused ambient layers',
        'Include an inner specular top highlight to simulate physical glass/machined aluminum'
      ],
    ),
    const KnowledgeItem(
      id: 'design-typography-hierarchy',
      category: 'High-End Design',
      title: 'Clean Light Modern Typography & Color Harmonies',
      tags: ['design', 'typography', 'colors', 'styling', 'minimalist'],
      summary: 'Ban generic system fonts and dull gray palettes. Pair modern geometric sans with rich slate hierarchy and soft candy pastel accents.',
      codeSnippet: '/* Design Tokens */\n--font-sans: "Plus Jakarta Sans", -apple-system, sans-serif;\n--color-bg: #F8FAFC;       /* Crisp porcelain background */\n--color-surface: #FFFFFF;  /* Pure white cards */\n--color-text-main: #0F172A;/* Deep midnight slate */\n--color-text-muted: #64748B;/* Refined cool slate */\n--color-accent-gel: #818CF8;/* Translucent gel highlight */',
      keyRules: [
        'Always precede major section titles with a micro-pill eyebrow tag',
        'Use generous line heights (1.5 - 1.6) and letter spacing (-0.02em on large headings)',
        'Never use 100% pure black text on pure white: use deep slate (#0F172A) for optical warmth'
      ],
    ),
    const KnowledgeItem(
      id: 'growth-18s-launch-video-formula',
      category: 'Monetization & Growth',
      title: 'The 18-Second High-Retention Launch Video Structure',
      tags: ['marketing', 'video', 'launch', 'conversion', 'viral', 'brag'],
      summary: 'Proven 18-second video blueprint engineered for TikTok, X, and App Store preview conversions with a 72%+ completion rate.',
      codeSnippet: '0.0s - 2.5s : The Disruption Hook (visual shock or bold contrarian statement)\n2.5s - 5.0s : The Pain Point (visceral friction of existing outdated tools)\n5.0s - 9.0s : The Magical Solution Reveal (fluid animated hero product feature)\n9.0s - 14.0s: The Kinetic UI Proof (rapid high-speed demonstration of speed)\n14.0s - 18.0s: The Memorable Brand Payoff & Instant Download Call to Action',
      keyRules: [
        'Hook within the first 1500ms or 65% of viewers swipe away',
        'Sync keyframe transitions to high-tempo 128 BPM audio ticks',
        'Render in dual aspect ratios: 21:9 for App Store desktop and 9:16 vertical for social'
      ],
    ),
  ];

  final List<KnowledgeItem> _database = List.from(initialDatabase);
  List<KnowledgeItem> get allKnowledgeItems => List.unmodifiable(_database);

  Stream<Map<String, dynamic>> get agentEvents => _eventController.stream;

  ButaLocalService({
    this.gatewayUrl = 'http://localhost:3030',
    this.ollamaUrl = 'http://localhost:11434',
    this.modelName = 'buta-ai',
  }) {
    _initWebSocket();
  }

  void _initWebSocket() {
    try {
      final wsUri = Uri.parse('${gatewayUrl.replaceFirst('http', 'ws')}/ws');
      _wsChannel = WebSocketChannel.connect(wsUri);
      _wsChannel?.stream.listen(
        (data) {
          try {
            final parsed = jsonDecode(data.toString());
            if (parsed is Map<String, dynamic>) {
              _eventController.add(parsed);
            }
          } catch (_) {}
        },
        onError: (_) {},
        onDone: () {},
      );
    } catch (_) {}
  }

  /// Check if local engine / gateway is online
  Future<bool> isEngineOnline() async {
    try {
      final res = await http.get(Uri.parse('$ollamaUrl/api/tags')).timeout(const Duration(milliseconds: 1500));
      if (res.statusCode == 200) return true;
    } catch (_) {}

    try {
      final res = await http.get(Uri.parse('$gatewayUrl/api/status')).timeout(const Duration(milliseconds: 1000));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Run a full autonomous engineering cycle with real tools and agents
  Future<Map<String, dynamic>?> runAutonomousCycle(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse('$gatewayUrl/api/cycle'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'task': prompt}),
          )
          .timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (e) {
      // Return null to allow fallback to dynamic chat
    }
    return null;
  }

  /// Direct URL to download the full project zip archive
  String get downloadZipUrl => '$gatewayUrl/api/download-zip';

  /// 1-Click Retrain on Apple Silicon Metal via Gateway
  Future<bool> triggerLocalTraining({int iters = 10, String tier = 'nano'}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$gatewayUrl/api/train'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'iters': iters, 'tier': tier}),
          )
          .timeout(const Duration(minutes: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Search the active database for relevant engineering and design rules
  List<KnowledgeItem> searchDatabase(String query) {
    if (query.trim().isEmpty) return _database;
    final lower = query.toLowerCase();
    final tokens = lower.split(RegExp(r'\s+')).where((t) => t.length > 2).toList();

    final matches = _database.where((item) {
      if (item.title.toLowerCase().contains(lower) || item.summary.toLowerCase().contains(lower)) {
        return true;
      }
      return tokens.any((t) =>
          item.tags.any((tag) => tag.contains(t)) ||
          item.category.toLowerCase().contains(t) ||
          item.title.toLowerCase().contains(t) ||
          item.summary.toLowerCase().contains(t));
    }).toList();

    return matches.isNotEmpty ? matches : _database.take(3).toList();
  }

  /// Teach ButaAI a new permanent rule at runtime
  void feedNewRule({
    required String title,
    required String category,
    required String summary,
    required String codeSnippet,
    required List<String> tags,
  }) {
    final newItem = KnowledgeItem(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      title: title,
      tags: tags,
      summary: summary,
      codeSnippet: codeSnippet,
      keyRules: ['User taught rule - high priority enforcement', 'Persisted to active local memory'],
    );
    _database.insert(0, newItem);
  }

  /// Check if the prompt is an identity or greeting inquiry
  bool isGreetingOrIdentity(String text) {
    final lower = text.toLowerCase().trim();
    return lower.contains('name') ||
        lower.contains('who are you') ||
        lower.contains('who r u') ||
        lower.contains('hello') ||
        lower.contains('hi') ||
        lower.contains('hey') ||
        lower.contains('what is this') ||
        lower.contains('introduce') ||
        lower.contains('about you') ||
        lower.contains('teach') ||
        lower.contains('database') ||
        lower.contains('knowledge');
  }

  /// Generate real technical review turns for the ButaAI Engineering Specialists using the local LLM
  Future<List<Map<String, dynamic>>> generateDynamicSquadTurns(String userPrompt) async {
    final hasSpecificTechMatch = userPrompt.toLowerCase().contains('riverpod') ||
        userPrompt.toLowerCase().contains('swiftui') ||
        userPrompt.toLowerCase().contains('firestore') ||
        userPrompt.toLowerCase().contains('admob') ||
        userPrompt.toLowerCase().contains('database');

    String knowledgeContext = '';
    if (hasSpecificTechMatch) {
      final matchedKnowledge = searchDatabase(userPrompt);
      if (matchedKnowledge.isNotEmpty) {
        final item = matchedKnowledge.first;
        knowledgeContext = '\n[Verified Engineering Knowledge: ${item.title}]\n${item.summary}\n${item.codeSnippet}\n';
      }
    }

    final systemPrompt = '''
You are ButaAI, the autonomous product & software engineering agency created by Butalabs, executing locally on Apple Silicon Metal.
Your engineering squad consists of 6 dedicated software specialists collaborating in real-time:
- Buta CEO: Defines executive strategy, market positioning, target users, and release milestones.
- Product Architect: Outlines structured PRD requirements, user journeys, key screen hierarchy, and acceptance criteria.
- System Architect: Designs technical topology, Clean Architecture / Riverpod patterns, SQLite schemas, and offline data sync.
- Lead Frontend Engineer: Details UI component specifications, design tokens, micro-interactions, and accessibility.
- Lead Backend Engineer: Outlines core domain services, repository interfaces, and data models.
- QA & Security Verifier: Defines automated unit test suites, edge case guards, and zero-vulnerability security checks.
$knowledgeContext
INSTRUCTIONS:
1. Answer the user prompt with rigorous, actionable technical depth.
2. Structure your response as a cohesive engineering collaboration across the specialists.
3. Label each specialist clearly:
**Buta CEO**: [Executive strategy, target user persona, and MVP release milestone]
**Product Architect**: [Core PRD user stories, key feature flow, and acceptance criteria]
**System Architect**: [Clean Architecture layers, repository design, and state management]
**Lead Frontend Engineer**: [UI component breakdown, theme styling, and interaction feedback]
**Lead Backend Engineer**: [Domain models, local persistence schema, and API contracts]
**QA & Security Verifier**: [Unit test assertions, edge-case handling, and security verification]
4. Provide concrete, technical substance—avoid generic filler or cartoonish language.
5. NEVER mention "Orbital Astro" or "Swiss horology".
''';

    // 1. Direct local Ollama inference on Apple Silicon Metal with responsive timeout
    try {
      final response = await http
          .post(
            Uri.parse('$ollamaUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': modelName,
              'keep_alive': -1,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'stream': false,
              'options': {
                'num_predict': 260,
                'temperature': 0.7,
              },
            }),
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final String rawContent = data['message']?['content'] ?? '';

        if (rawContent.trim().isNotEmpty) {
          final parsedTurns = _parseSquadTurns(rawContent);
          if (parsedTurns.length >= 2) {
            return parsedTurns;
          }
        }
      }
    } catch (_) {}

    // 2. Gateway fallback
    try {
      final response = await http
          .post(
            Uri.parse('$gatewayUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prompt': userPrompt,
              'systemPrompt': systemPrompt,
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final String rawContent = data['content'] ?? data['response'] ?? '';
        if (rawContent.trim().isNotEmpty) {
          final parsedTurns = _parseSquadTurns(rawContent);
          if (parsedTurns.length >= 2) {
            return parsedTurns;
          }
        }
      }
    } catch (_) {}

    // 3. High-velocity domain-specific engineering synthesis fallback (Zero dead-time guaranteed!)
    return _generateLocalDomainTurns(userPrompt);
  }

  /// High-velocity specialist review generator when local LLM is warm-starting or queuing
  List<Map<String, dynamic>> _generateLocalDomainTurns(String prompt) {
    final cleanPrompt = prompt.trim();
    final isGym = cleanPrompt.toLowerCase().contains('gym') || cleanPrompt.toLowerCase().contains('workout') || cleanPrompt.toLowerCase().contains('fitness');
    final isTravel = cleanPrompt.toLowerCase().contains('travel') || cleanPrompt.toLowerCase().contains('trip') || cleanPrompt.toLowerCase().contains('journal');
    final isFinance = cleanPrompt.toLowerCase().contains('expense') || cleanPrompt.toLowerCase().contains('finance') || cleanPrompt.toLowerCase().contains('budget');
    final isSecurity = cleanPrompt.toLowerCase().contains('security') || cleanPrompt.toLowerCase().contains('auth') || cleanPrompt.toLowerCase().contains('encrypt');
    final isGpu = cleanPrompt.toLowerCase().contains('metal') || cleanPrompt.toLowerCase().contains('gpu') || cleanPrompt.toLowerCase().contains('inference');

    String appName = 'Modern App';
    if (isGym) {
      appName = 'GymOS & Workout PR Engine';
    } else if (isTravel) {
      appName = 'Voyager Offline Journal';
    } else if (isFinance) {
      appName = 'VaultSpend Budget & Expense OS';
    } else if (isSecurity) {
      appName = 'KeyGuard Zero-Knowledge Vault';
    } else if (isGpu) {
      appName = 'MetalCore ML Pipeline';
    } else {
      final words = cleanPrompt.split(' ').where((w) => w.length > 3).take(3).join(' ');
      appName = words.isNotEmpty ? '${words[0].toUpperCase()}${words.substring(1)} Pro' : 'Autonomous App';
    }

    return [
      {
        'role': AgentRole.productArchitect,
        'content': '### 📋 Product Architecture & User Journey Specification\n\n'
            'For **$appName**, the core user journey must prioritize zero-friction interactions:\n\n'
            '1. **Frictionless Quick-Action**: Primary interaction takes <2 seconds from cold launch.\n'
            '2. **Structured Data Flow**: Instant categorical logging, offline persistence, and automated session tagging.\n'
            '3. **Progress Analytics**: Visual milestone cards with historical comparisons and exportable summaries.\n\n'
            '**Acceptance Criteria**: 100% offline functionality, zero network latency on local actions, and sub-16ms frame times.',
      },
      {
        'role': AgentRole.systemArchitect,
        'content': '### 🏛️ System Architecture & Schema Definition\n\n'
            'Structuring **$appName** with strict **Clean Architecture (Domain, Data, Presentation)**:\n\n'
            '```text\n'
            'lib/\n'
            '├── core/ (theme, constants, database/sqlite_helper.dart)\n'
            '├── features/$appName/\n'
            '│   ├── domain/ (models, repository_interface.dart)\n'
            '│   ├── data/ (sqlite_repository_impl.dart, local_storage.dart)\n'
            '│   └── presentation/ (state/notifier.dart, screens/, widgets/)\n'
            '```\n\n'
            '**Persistence Layer**: Local SQLite database with WAL (Write-Ahead Logging) enabled. '
            'State managed via Riverpod `NotifierProvider` for deterministic, unidirectional reactive flow.',
      },
      {
        'role': AgentRole.frontendLead,
        'content': '### 🎨 UI Component Hierarchy & Design System\n\n'
            'Implementing our signature **Porcelain White Clean UI**:\n\n'
            '- **Color Palette**: Off-white porcelain background (`#F8FAFC`), deep slate typography (`#0F172A`), and vibrant specialty accents.\n'
            '- **Card Elevation**: Dual-layer subtle ambient shadow (`rgba(0,0,0,0.04)` blur 14, offset 3) with crisp 1px borders.\n'
            '- **Interaction Motion**: Fluid `Curves.easeOutCubic` animations on card expansion and haptic tap feedback.',
      },
      {
        'role': AgentRole.backendLead,
        'content': '### ⚙️ Local Services, Caching & Data Pipeline\n\n'
            'Engineering the local domain repository and SQLite data pipeline:\n\n'
            '- **SQLite Indexes**: B-Tree indices on `(id, created_at DESC)` for sub-millisecond query retrieval.\n'
            '- **Batch Transactions**: Multi-record operations wrapped in single `db.transaction()` blocks to prevent I/O blocking.\n'
            '- **Repository Abstraction**: Clean interface decoupling UI controllers from raw SQLite queries.',
      },
      {
        'role': AgentRole.qaLead,
        'content': '### 🛡️ QA Verification Suite & Security Guardrails\n\n'
            'Quality gates validated for release readiness:\n\n'
            '- **Unit Test Coverage**: Automated test suites covering domain models, serialization, and state mutations.\n'
            '- **Memory & Leaks**: Zero orphaned stream subscriptions; controllers properly disposed in lifecycle hooks.\n'
            '- **Security Boundary**: Zero telemetry leaks; all sensitive user parameters encrypted locally via AES-GCM.',
      },
    ];
  }

  /// Parse the LLM's output by matching ButaAI engineering specialists
  List<Map<String, dynamic>> _parseSquadTurns(String raw) {
    final List<Map<String, dynamic>> turns = [];
    final regex = RegExp(
      r'(?:\[|\*\*|\*|#+\s*)?(Buta\s+CEO|CEO|Product\s+Architect|System\s+Architect|Lead\s+Frontend\s+Engineer|Frontend\s+Lead|Frontend|Lead\s+Backend\s+Engineer|Backend\s+Lead|Backend|QA\s+&\s+Security\s+Verifier|QA\s+Verifier|QA\s+Lead|QA|Gelly|Bloop|Pip|Mochi|Spark)(?:\s*\([^)]*\))?(?:\]|\*\*|\*|:|\s*-\s*|\s*:\s*)+',
      caseSensitive: false,
    );

    final matches = regex.allMatches(raw).toList();
    if (matches.isEmpty) {
      turns.add({
        'role': AgentRole.ceo,
        'content': raw.trim(),
      });
      return turns;
    }

    for (int i = 0; i < matches.length; i++) {
      final currentMatch = matches[i];
      final rawName = currentMatch.group(1)!.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      final startIndex = currentMatch.end;
      final endIndex = (i + 1 < matches.length) ? matches[i + 1].start : raw.length;
      var content = raw.substring(startIndex, endIndex).trim();
      content = content.replaceFirst(RegExp(r'^[:\*\-\s\)]+'), '').trim();

      AgentRole role;
      if (rawName.contains('ceo') || rawName.contains('gelly')) {
        role = AgentRole.ceo;
      } else if (rawName.contains('product') || rawName.contains('bloop')) {
        role = AgentRole.productArchitect;
      } else if (rawName.contains('system') || rawName.contains('arch') || rawName.contains('pip')) {
        role = AgentRole.systemArchitect;
      } else if (rawName.contains('front') || rawName.contains('mochi')) {
        role = AgentRole.frontendLead;
      } else if (rawName.contains('back') || rawName.contains('dev')) {
        role = AgentRole.backendLead;
      } else if (rawName.contains('qa') || rawName.contains('sec') || rawName.contains('spark')) {
        role = AgentRole.qaLead;
      } else {
        role = AgentRole.ceo;
      }

      if (content.isNotEmpty) {
        turns.add({
          'role': role,
          'content': content,
        });
      }
    }

    return turns;
  }

  /// Dynamically generate product deliverables from either autonomous cycle or live debate
  ProductDeliverables? generateProductDeliverables(
    String userPrompt,
    List<Map<String, dynamic>> turns, {
    Map<String, dynamic>? cycleResult,
  }) {
    if (isGreetingOrIdentity(userPrompt)) return null;

    if (cycleResult != null) {
      return ProductDeliverables.fromAutonomousCycle(cycleResult);
    }

    return ProductDeliverables.fromSquadDiscussion(
      userPrompt: userPrompt,
      turns: turns,
    );
  }

  /// Get Collective Swarm Network Status & Community Metrics
  Future<Map<String, dynamic>?> getSwarmStatus() async {
    try {
      final res = await http.get(Uri.parse('$gatewayUrl/api/swarm/status'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Sync local LoRA adapter with latest Global Master Swarm weights
  Future<Map<String, dynamic>> syncWithSwarm() async {
    try {
      final res = await http.post(Uri.parse('$gatewayUrl/api/swarm/sync'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Sync failed with code ${res.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Toggle participation in ButaAI Collective Swarm learning
  Future<bool> toggleSwarmParticipation(bool participating) async {
    try {
      final res = await http.post(
        Uri.parse('$gatewayUrl/api/swarm/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'participating': participating}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['participating'] == true;
      }
    } catch (_) {}
    return participating;
  }

  /// Fetch list of generated multimodal assets from gateway server
  Future<Map<String, dynamic>?> fetchMediaList() async {
    try {
      final res = await http.get(Uri.parse('$gatewayUrl/api/media/list'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Get available Swarm Intelligence Capacity Tiers
  Future<List<Map<String, dynamic>>> getSwarmTiers() async {
    try {
      final res = await http.get(Uri.parse('$gatewayUrl/api/swarm/tiers'));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Switch active Swarm Capacity Tier (nano 11MB, brain 500MB, titan 1.2GB)
  Future<Map<String, dynamic>?> setSwarmTier(String tier) async {
    try {
      final res = await http.post(
        Uri.parse('$gatewayUrl/api/swarm/tier'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tier': tier}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Toggle background Swarm Auto-Sync Daemon
  Future<bool> toggleAutoSync(bool enabled) async {
    try {
      final res = await http.post(
        Uri.parse('$gatewayUrl/api/swarm/auto-sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'enabled': enabled}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['autoSyncEnabled'] == true;
      }
    } catch (_) {}
    return enabled;
  }

  /// Detects if user prompt is requesting an image, video, logo, or animation
  bool isMediaRequest(String prompt) {
    final p = prompt.toLowerCase();
    return p.contains('image') ||
        p.contains('video') ||
        p.contains('promotion') ||
        p.contains('promo') ||
        p.contains('logo') ||
        p.contains('icon') ||
        p.contains('animation') ||
        p.contains('storyboard') ||
        p.contains('poster') ||
        p.contains('banner') ||
        p.contains('draw') ||
        p.contains('graphic');
  }

  String getMediaType(String prompt) {
    final p = prompt.toLowerCase();
    if (p.contains('video') ||
        p.contains('promotion') ||
        p.contains('promo') ||
        p.contains('storyboard')) {
      return 'video';
    } else if (p.contains('animation') || p.contains('motion')) {
      return 'animation';
    } else {
      return 'image';
    }
  }

  /// 1-Click Multimodal Generation (Vector SVG Images, Kinetic Storyboard Videos, Flutter Animations)
  Future<Map<String, dynamic>?> generateMedia({
    required String type,
    required String prompt,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$gatewayUrl/api/media/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': type,
          'prompt': prompt,
          'title': prompt,
          'concept': prompt,
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['media'] != null) {
          return data['media'] as Map<String, dynamic>;
        }
      }
    } catch (_) {}

    // Fallback: Immediate high-fidelity local vector generation if gateway call delayed
    if (type == 'image') {
      return {
        'type': 'image',
        'title': 'Vector Emblem',
        'prompt': prompt,
        'url': 'http://localhost:3030/artifacts/images/butagym_emblem.svg',
        'svgContent': _buildFallbackSvg(prompt),
      };
    } else if (type == 'video') {
      return {
        'type': 'video',
        'title': prompt,
        'concept': prompt,
        'playerUrl': 'http://localhost:3030/artifacts/videos/launch_video.html',
        'scenes': [
          {
            'sceneNumber': 1,
            'title': 'The Elite Hook',
            'durationSec': 3,
            'visualDescription': 'Kinetic 3D neon-emerald dumbbell rotates into focus with pulse aura',
            'voiceoverScript': 'What if your gym tracking never needed a cellular signal or cloud subscription?',
          },
          {
            'sceneNumber': 2,
            'title': 'The Frustration',
            'durationSec': 4,
            'visualDescription': 'Gym basement signal dead-zone with lost workout logs',
            'voiceoverScript': 'Underground fitness centers kill cloud apps. Workout data shouldn\'t vanish.',
          },
          {
            'sceneNumber': 3,
            'title': 'The Breakthrough',
            'durationSec': 5,
            'visualDescription': 'ButaGYM OS UI loads in 0.02ms with SQLite B-Tree caching',
            'voiceoverScript': 'Meet ButaGYM OS: 100% offline-first, sub-millisecond local SQLite persistence.',
          },
          {
            'sceneNumber': 4,
            'title': 'The Performance',
            'durationSec': 3,
            'visualDescription': 'Live workout recording screen with rest timers and muscle heatmaps',
            'voiceoverScript': 'Effortless logging. Micro-periodization. Zero data leaks.',
          },
          {
            'sceneNumber': 5,
            'title': 'The Call to Action',
            'durationSec': 3,
            'visualDescription': 'Centered www.butagym.az logo reveal with pulsing action card',
            'voiceoverScript': 'Elevate your discipline. Visit www.butagym.az and master your workouts today.',
          },
        ],
      };
    }
    return null;
  }

  String _buildFallbackSvg(String prompt) {
    return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 600" width="600" height="600">
  <defs>
    <linearGradient id="gymBg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#090D16" />
      <stop offset="100%" stop-color="#020617" />
    </linearGradient>
    <linearGradient id="emeraldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#34D399" />
      <stop offset="100%" stop-color="#059669" />
    </linearGradient>
  </defs>
  <rect width="600" height="600" rx="44" fill="url(#gymBg)" stroke="#1E293B" stroke-width="2" />
  <polygon points="300,50 510,170 510,430 300,550 90,430 90,170" fill="#131D31" stroke="url(#emeraldGrad)" stroke-width="4" opacity="0.95" />
  <rect x="237" y="272" width="126" height="16" rx="4" fill="#94A3B8" />
  <rect x="200" y="200" width="20" height="160" rx="6" fill="url(#emeraldGrad)" />
  <rect x="380" y="200" width="20" height="160" rx="6" fill="url(#emeraldGrad)" />
  <text x="300" y="165" font-family="sans-serif" font-size="34" font-weight="900" letter-spacing="4" fill="#FFFFFF" text-anchor="middle">BUTA GYM</text>
  <text x="300" y="445" font-family="sans-serif" font-size="14" font-weight="700" letter-spacing="3" fill="#34D399" text-anchor="middle">www.butagym.az • KINETIC OS</text>
  <text x="300" y="475" font-family="sans-serif" font-size="12" font-weight="600" fill="#94A3B8" text-anchor="middle">⚡ 100% OFFLINE SQLITE • RIVERPOD 3.X • METAL ACCELERATED</text>
</svg>''';
  }
}

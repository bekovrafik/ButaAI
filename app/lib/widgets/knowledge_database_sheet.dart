import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/buta_local_service.dart';
import '../theme/buta_theme.dart';

class KnowledgeDatabaseSheet extends StatefulWidget {
  final ButaLocalService localService;
  final VoidCallback onRuleAdded;

  const KnowledgeDatabaseSheet({
    super.key,
    required this.localService,
    required this.onRuleAdded,
  });

  @override
  State<KnowledgeDatabaseSheet> createState() => _KnowledgeDatabaseSheetState();
}

class _KnowledgeDatabaseSheetState extends State<KnowledgeDatabaseSheet> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isAddingRule = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(text: 'Custom Rule');
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _summaryController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = widget.localService.allKnowledgeItems;
    final categories = ['All', ...allItems.map((e) => e.category).toSet()];

    final filteredItems = allItems.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.summary.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: ButaColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: ButaColors.borderLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ButaColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🧠', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'ButaAI Knowledge Database',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ButaColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '● ACTIVE DB',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${allItems.length} Production Rules & Patterns Fed into buta-ai:latest',
                        style: const TextStyle(
                          fontSize: 13,
                          color: ButaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isAddingRule = !_isAddingRule),
                  icon: Icon(_isAddingRule ? Icons.close : Icons.add, size: 16),
                  label: Text(_isAddingRule ? 'Cancel' : 'Feed Rule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ButaColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),

          // Add Rule Form
          if (_isAddingRule) _buildAddRuleForm(),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search rules (Riverpod, Safe Area, Double-Bezel, Launch Video)...',
                hintStyle: const TextStyle(fontSize: 13, color: ButaColors.textMuted),
                prefixIcon: const Icon(Icons.search, size: 20, color: ButaColors.textMuted),
                filled: true,
                fillColor: ButaColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: ButaColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: ButaColors.borderLight),
                ),
              ),
            ),
          ),

          // Category Pills
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = categories[i];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : ButaColors.textSecondary,
                  ),
                  selectedColor: ButaColors.primary,
                  backgroundColor: ButaColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? ButaColors.primary : ButaColors.borderLight,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 16, color: ButaColors.borderLight),

          // Knowledge Items List
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No matching rules found in database.',
                      style: TextStyle(color: ButaColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, i) => _buildKnowledgeCard(filteredItems[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRuleForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ButaColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ButaColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feed ButaAI a New Rule',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Rule Title (e.g. Flutter Drift SQLite Offline Sync)',
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _summaryController,
            decoration: const InputDecoration(
              hintText: 'Summary & Core Invariant',
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _codeController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Code Snippet or Pattern Specification',
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _saveNewRule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save & Feed to ButaAI'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveNewRule() {
    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    if (title.isEmpty || summary.isEmpty) return;

    widget.localService.feedNewRule(
      title: title,
      category: _categoryController.text.trim(),
      summary: summary,
      codeSnippet: _codeController.text.trim(),
      tags: [title.toLowerCase(), 'custom-rule'],
    );

    widget.onRuleAdded();

    setState(() {
      _isAddingRule = false;
      _titleController.clear();
      _summaryController.clear();
      _codeController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ Taught ButaAI: "$title"'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  Widget _buildKnowledgeCard(KnowledgeItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ButaColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ButaColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge + Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: ButaColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ButaColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${item.id}',
                style: const TextStyle(fontSize: 11, color: ButaColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ButaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.summary,
            style: const TextStyle(
              fontSize: 13,
              color: ButaColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (item.keyRules.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.keyRules
                  .map(
                    (rule) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: ButaColors.primary, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              rule,
                              style: const TextStyle(fontSize: 12, color: ButaColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (item.codeSnippet.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Stack(
                children: [
                  Text(
                    item.codeSnippet,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      color: Color(0xFF1E293B),
                      height: 1.45,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: item.codeSnippet));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code snippet copied to clipboard!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Icon(Icons.copy, size: 14, color: ButaColors.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

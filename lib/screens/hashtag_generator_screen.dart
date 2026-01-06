import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hashtag_analysis.dart';
import '../services/hashtag_service.dart';

/// Hashtag Generator Screen for AI YouTube Boost v2.0
class HashtagGeneratorScreen extends StatefulWidget {
  const HashtagGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<HashtagGeneratorScreen> createState() => _HashtagGeneratorScreenState();
}

class _HashtagGeneratorScreenState extends State<HashtagGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hashtagService = HashtagService();
  
  String _selectedCategory = 'Gaming';
  HashtagAnalysis? _analysis;
  bool _isLoading = false;

  final List<String> _categories = [
    'Gaming', 'Entertainment', 'Music', 'Education', 'Technology',
    'Sports', 'Food', 'Travel', 'Comedy', 'News',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hashtag Generator'),
        actions: [
          if (_analysis != null)
            IconButton(
              icon: const Icon(Icons.copy_all),
              onPressed: _copyAllHashtags,
              tooltip: 'Copy All',
            ),
        ],
      ),
      body: _analysis == null ? _buildInputForm() : _buildAnalysisResults(),
    );
  }

  Widget _buildInputForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Video Title',
                hintText: 'Enter your video title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Video description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateHashtags,
                icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'Generating...' : 'Generate Hashtags'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.tag, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Hashtag Generator', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Generate optimized hashtags for maximum reach', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateHashtags() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final analysis = await _hashtagService.generateHashtagAnalysis(
        videoTitle: _titleController.text,
        category: _selectedCategory,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      setState(() {
        _analysis = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildAnalysisResults() {
    if (_analysis == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildScoreCard(),
        const SizedBox(height: 16),
        _buildHashtagsSection('Generated Hashtags', _analysis!.generatedHashtags),
        const SizedBox(height: 16),
        _buildHashtagsSection('Trending Hashtags', _analysis!.trendingHashtags),
        const SizedBox(height: 16),
        _buildRecommendationsCard(),
        const SizedBox(height: 16),
        _buildCopySection(),
      ],
    );
  }

  Widget _buildScoreCard() {
    final score = _analysis!.overallScore;
    final color = score >= 80 ? Colors.green : (score >= 60 ? Colors.orange : Colors.red);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Overall Score', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CircularProgressIndicator(value: score / 100, strokeWidth: 8, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation<Color>(color)),
            const SizedBox(height: 8),
            Text('${score.toStringAsFixed(0)}/100', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtagsSection(String title, List<HashtagItem> hashtags) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hashtags.map((tag) => _buildHashtagChip(tag)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtagChip(HashtagItem tag) {
    return ActionChip(
      avatar: Text(tag.trend.emoji),
      label: Text('#${tag.tag}'),
      onPressed: () => _showHashtagDetails(tag),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Recommendations', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ..._analysis!.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 18)),
                  Expanded(child: Text(rec)),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCopySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Copy Hashtags', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() => _analysis = null)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: SelectableText(_analysis!.getHashtagString()),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _copyAllHashtags,
                icon: const Icon(Icons.copy),
                label: const Text('Copy to Clipboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyAllHashtags() {
    if (_analysis != null) {
      Clipboard.setData(ClipboardData(text: _analysis!.getHashtagString()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hashtags copied to clipboard!')));
    }
  }

  void _showHashtagDetails(HashtagItem tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('#${tag.tag}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Score', '${tag.score.toStringAsFixed(0)}/100'),
            _buildDetailRow('Search Volume', tag.formattedSearchVolume),
            _buildDetailRow('Competition', tag.competitionLevelText),
            _buildDetailRow('Trend', '${tag.trend.emoji} ${tag.trend.displayName}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

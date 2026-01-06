import 'package:flutter/material.dart';
import '../models/video_prediction.dart';
import '../services/video_predictor_service.dart';
import 'package:fl_chart/fl_chart.dart';

/// Video Performance Predictor Screen for AI YouTube Boost v2.0
/// Predict video performance using AI algorithms
class VideoPredictorScreen extends StatefulWidget {
  const VideoPredictorScreen({Key? key}) : super(key: key);

  @override
  State<VideoPredictorScreen> createState() => _VideoPredictorScreenState();
}

class _VideoPredictorScreenState extends State<VideoPredictorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  final _predictorService = VideoPredictorService();
  
  String _selectedCategory = 'Gaming';
  PredictionTimeframe _selectedTimeframe = PredictionTimeframe.month;
  Duration _videoDuration = const Duration(minutes: 10);
  VideoPrediction? _prediction;
  bool _isLoading = false;

  final List<String> _categories = [
    'Gaming',
    'Entertainment',
    'Music',
    'Education',
    'Technology',
    'Sports',
    'Food',
    'Travel',
    'Comedy',
    'News',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Predictor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _prediction == null ? _buildInputForm() : _buildPredictionResults(),
      floatingActionButton: _prediction != null
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _prediction = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('New Prediction'),
            )
          : null,
    );
  }

  Widget _buildInputForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildTitleInput(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildTagsInput(),
            const SizedBox(height: 16),
            _buildDurationSelector(),
            const SizedBox(height: 16),
            _buildTimeframeSelector(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _predictPerformance,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.psychology),
                label: Text(_isLoading ? 'Analyzing...' : 'Predict Performance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
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
            Icon(Icons.auto_graph, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Performance Predictor',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get AI-powered predictions for your video performance',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Video Title',
        hintText: 'Enter your video title',
        prefixIcon: Icon(Icons.title),
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a video title';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }

  Widget _buildTagsInput() {
    return TextFormField(
      controller: _tagsController,
      decoration: const InputDecoration(
        labelText: 'Tags (comma-separated)',
        hintText: 'gaming, tutorial, tips',
        prefixIcon: Icon(Icons.tag),
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Duration: ${_videoDuration.inMinutes} minutes',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          value: _videoDuration.inMinutes.toDouble(),
          min: 1,
          max: 60,
          divisions: 59,
          label: '${_videoDuration.inMinutes} min',
          onChanged: (value) {
            setState(() {
              _videoDuration = Duration(minutes: value.toInt());
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prediction Timeframe',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: PredictionTimeframe.values.map((timeframe) {
            final isSelected = _selectedTimeframe == timeframe;
            return ChoiceChip(
              label: Text(timeframe.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedTimeframe = timeframe;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _predictPerformance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final prediction = await _predictorService.predictPerformance(
        videoTitle: _titleController.text,
        category: _selectedCategory,
        tags: tags,
        videoDuration: _videoDuration,
        timeframe: _selectedTimeframe,
      );

      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildPredictionResults() {
    if (_prediction == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPredictionSummaryCard(),
        const SizedBox(height: 16),
        _buildViralityCard(),
        const SizedBox(height: 16),
        _buildMetricsChart(),
        const SizedBox(height: 16),
        _buildFactorsCard(),
        const SizedBox(height: 16),
        _buildRecommendationsCard(),
      ],
    );
  }

  Widget _buildPredictionSummaryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.preview, color: Colors.blue, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Performance Prediction',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildPredictionMetricRow(
              'Predicted Views',
              _prediction!.formattedPredictedViews,
              Icons.visibility,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildPredictionMetricRow(
              'Predicted Likes',
              _formatNumber(_prediction!.predictedLikes),
              Icons.thumb_up,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildPredictionMetricRow(
              'Predicted Comments',
              _formatNumber(_prediction!.predictedComments),
              Icons.comment,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildPredictionMetricRow(
              'Success Probability',
              '${(_prediction!.successProbability * 100).toStringAsFixed(0)}%',
              Icons.show_chart,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionMetricRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildViralityCard() {
    final viralityScore = _prediction!.viralityScore;
    final color = viralityScore >= 70 ? Colors.red : (viralityScore >= 50 ? Colors.orange : Colors.grey);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Virality Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _prediction!.viralityLevel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: viralityScore / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 20,
            ),
            const SizedBox(height: 8),
            Text(
              '${viralityScore.toStringAsFixed(1)}/100',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barGroups: [
                    _makeGroupData(0, _prediction!.factors['titleScore'] ?? 0),
                    _makeGroupData(1, _prediction!.factors['categoryPopularity'] ?? 0),
                    _makeGroupData(2, _prediction!.factors['tagRelevance'] ?? 0),
                    _makeGroupData(3, _prediction!.factors['trendAlignment'] ?? 0),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Title', 'Category', 'Tags', 'Trends'];
                          if (value.toInt() < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y >= 70 ? Colors.green : (y >= 50 ? Colors.orange : Colors.red),
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildFactorsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis Factors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ..._prediction!.factors.entries.map((entry) {
              if (entry.value is double) {
                return _buildFactorRow(entry.key, entry.value);
              }
              return const SizedBox();
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(String label, double value) {
    final displayLabel = label.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayLabel),
              Text(
                '${value.toStringAsFixed(0)}/100',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              value >= 70 ? Colors.green : (value >= 50 ? Colors.orange : Colors.red),
            ),
          ),
        ],
      ),
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
                const Icon(Icons.tips_and_updates, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'AI Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._prediction!.recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(rec)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Performance Predictor'),
        content: const Text(
          'This AI-powered tool analyzes various factors including:\n\n'
          '• Title quality and optimization\n'
          '• Category popularity\n'
          '• Tag relevance and SEO\n'
          '• Video duration\n'
          '• Trend alignment\n'
          '• Competition level\n\n'
          'Results are estimates based on AI algorithms and historical data patterns.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

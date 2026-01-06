import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_data.dart';
import '../models/video_comparison.dart';
import '../services/video_comparison_service.dart';
import '../providers/app_provider.dart';
import '../widgets/video_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// Video Comparison Screen for AI YouTube Boost v2.0
/// Compare multiple videos side-by-side with AI insights
class VideoComparisonScreen extends StatefulWidget {
  const VideoComparisonScreen({Key? key}) : super(key: key);

  @override
  State<VideoComparisonScreen> createState() => _VideoComparisonScreenState();
}

class _VideoComparisonScreenState extends State<VideoComparisonScreen> {
  final VideoComparisonService _comparisonService = VideoComparisonService();
  final List<VideoData> _selectedVideos = [];
  VideoComparison? _comparison;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Comparison'),
        actions: [
          if (_selectedVideos.length >= 2)
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: _compareVideos,
              tooltip: 'Compare Videos',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSelectedVideosSection(),
          if (_isLoading) 
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_comparison != null)
            Expanded(child: _buildComparisonResults())
          else
            Expanded(child: _buildVideoSelector()),
        ],
      ),
    );
  }

  Widget _buildSelectedVideosSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected: ${_selectedVideos.length}/5',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedVideos.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedVideos.clear();
                      _comparison = null;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
            ],
          ),
          if (_selectedVideos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedVideos.length,
                itemBuilder: (context, index) {
                  final video = _selectedVideos[index];
                  return _buildSelectedVideoChip(video);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedVideoChip(VideoData video) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text('${_selectedVideos.indexOf(video) + 1}'),
        ),
        label: SizedBox(
          width: 150,
          child: Text(
            video.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () {
          setState(() {
            _selectedVideos.remove(video);
            _comparison = null;
          });
        },
      ),
    );
  }

  Widget _buildVideoSelector() {
    final appProvider = Provider.of<AppProvider>(context);
    final favorites = appProvider.favoriteVideos;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No favorite videos yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add videos to favorites to compare them',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final video = favorites[index];
        final isSelected = _selectedVideos.contains(video);
        
        return Card(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          child: ListTile(
            leading: isSelected 
              ? CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.check, color: Colors.white),
                )
              : CircleAvatar(
                  child: Text('${index + 1}'),
                ),
            title: Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${video.formattedViews} views • ${video.engagementRate.toStringAsFixed(1)}% engagement',
            ),
            trailing: IconButton(
              icon: Icon(isSelected ? Icons.remove_circle : Icons.add_circle),
              color: isSelected ? Colors.red : Theme.of(context).primaryColor,
              onPressed: () {
                setState(() {
                  if (isSelected) {
                    _selectedVideos.remove(video);
                  } else if (_selectedVideos.length < 5) {
                    _selectedVideos.add(video);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Maximum 5 videos can be compared')),
                    );
                  }
                  _comparison = null;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _compareVideos() async {
    if (_selectedVideos.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 videos to compare')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final comparison = await _comparisonService.compareVideos(_selectedVideos);
      setState(() {
        _comparison = comparison;
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

  Widget _buildComparisonResults() {
    if (_comparison == null) return const SizedBox();

    final winner = _comparison!.getWinner();
    final winnerVideo = _selectedVideos.firstWhere((v) => v.id == winner);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWinnerCard(winnerVideo),
        const SizedBox(height: 24),
        _buildRecommendationCard(),
        const SizedBox(height: 24),
        _buildDetailedComparison(),
      ],
    );
  }

  Widget _buildWinnerCard(VideoData winner) {
    final metrics = _comparison!.metrics[winner.id]!;
    
    return Card(
      color: Colors.amber.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Performer',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.amber.shade900,
                        ),
                      ),
                      Text(
                        winner.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem('Overall', '${metrics.overallScore.toStringAsFixed(0)}%'),
                _buildMetricItem('Grade', metrics.getGrade()),
                _buildMetricItem('Views', winner.formattedViews),
                _buildMetricItem('Engagement', '${winner.engagementRate.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blue),
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
            Text(
              _comparison!.recommendation ?? 'No recommendations available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _comparison!.confidenceScore,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _comparison!.confidenceScore > 0.7 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(_comparison!.confidenceScore * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._selectedVideos.map((video) => _buildVideoAnalysisCard(video)).toList(),
      ],
    );
  }

  Widget _buildVideoAnalysisCard(VideoData video) {
    final metrics = _comparison!.metrics[video.id];
    if (metrics == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getGradeColor(metrics.getGrade()),
          child: Text(
            metrics.getGrade(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          video.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Overall Score: ${metrics.overallScore.toStringAsFixed(1)}%'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildScoreBar('Views', metrics.viewsScore),
                _buildScoreBar('Engagement', metrics.engagementScore),
                _buildScoreBar('Retention', metrics.retentionScore),
                _buildScoreBar('Thumbnail', metrics.thumbnailScore),
                _buildScoreBar('Title', metrics.titleScore),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${score.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade == 'B') return Colors.blue;
    if (grade == 'C') return Colors.orange;
    return Colors.red;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../models/trending_topic.dart';

class TrendingAnalysisScreen extends StatefulWidget {
  const TrendingAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<TrendingAnalysisScreen> createState() => _TrendingAnalysisScreenState();
}

class _TrendingAnalysisScreenState extends State<TrendingAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      if (appProvider.trendingTopics.isEmpty) {
        appProvider.loadTrendingTopics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeProvider.isDarkMode
                ? [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: appProvider.isLoading && appProvider.trendingTopics.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : appProvider.trendingTopics.isEmpty
                        ? _buildEmptyState(context, appProvider)
                        : RefreshIndicator(
                            onRefresh: () => appProvider.loadTrendingTopics(),
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildOverviewCard(context, appProvider),
                                const SizedBox(height: 16),
                                _buildTopicsHeader(context),
                                const SizedBox(height: 12),
                                ...appProvider.trendingTopics
                                    .asMap()
                                    .entries
                                    .map((entry) => _buildTopicCard(
                                          context,
                                          entry.value,
                                          entry.key,
                                        ))
                                    .toList(),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Analysis',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Discover what\'s trending now',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppProvider appProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Trending Topics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Load trending topics to see analysis',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => appProvider.loadTrendingTopics(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Load Topics'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, AppProvider appProvider) {
    final topics = appProvider.trendingTopics;
    final avgGrowth = topics.isEmpty
        ? 0.0
        : topics.fold<double>(0, (sum, t) => sum + t.growthRate) / topics.length;
    final highOpportunity = topics.where((t) => t.opportunityLevel == 'Excellent').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Trending Topics',
                    '${topics.length}',
                    Icons.whatshot_rounded,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Avg Growth',
                    '${avgGrowth.toStringAsFixed(1)}%',
                    Icons.trending_up_rounded,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'High Opportunity',
                    '$highOpportunity',
                    Icons.stars_rounded,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Categories',
                    '${topics.map((t) => t.category).toSet().length}',
                    Icons.category_rounded,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.list_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Trending Topics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(BuildContext context, TrendingTopic topic, int index) {
    return Card(
      child: InkWell(
        onTap: () {
          _showTopicDetails(context, topic);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getOpportunityColor(topic.opportunityLevel)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getOpportunityColor(topic.opportunityLevel),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.keyword,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          topic.category,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getOpportunityColor(topic.opportunityLevel)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      topic.opportunityLevel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getOpportunityColor(topic.opportunityLevel),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildMetric(
                    context,
                    Icons.search_rounded,
                    topic.formattedSearchVolume,
                    'Searches',
                  ),
                  const SizedBox(width: 16),
                  _buildMetric(
                    context,
                    Icons.trending_up_rounded,
                    '${topic.growthRate.toStringAsFixed(0)}%',
                    'Growth',
                  ),
                  const SizedBox(width: 16),
                  _buildMetric(
                    context,
                    Icons.videocam_rounded,
                    '${topic.videoCount}',
                    'Videos',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.speed_rounded,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Competition: ${topic.competitionLevelText}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTrendColor(topic.trendStrength).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      topic.trendStrength,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getTrendColor(topic.trendStrength),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 300),
      delay: Duration(milliseconds: index * 50),
    ).slideX(
      begin: 0.2,
      duration: const Duration(milliseconds: 300),
      delay: Duration(milliseconds: index * 50),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getOpportunityColor(String level) {
    switch (level) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Moderate':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getTrendColor(String strength) {
    if (strength.contains('Exploding') || strength.contains('Rising')) {
      return Colors.green;
    } else if (strength.contains('Growing')) {
      return Colors.blue;
    } else if (strength.contains('Steady')) {
      return Colors.orange;
    }
    return Colors.red;
  }

  void _showTopicDetails(BuildContext context, TrendingTopic topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      topic.keyword,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.category,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow(context, 'Search Volume', topic.formattedSearchVolume),
                    _buildDetailRow(context, 'Growth Rate', '${topic.growthRate.toStringAsFixed(1)}%'),
                    _buildDetailRow(context, 'Video Count', '${topic.videoCount}'),
                    _buildDetailRow(context, 'Competition', topic.competitionLevelText),
                    _buildDetailRow(context, 'Trend Strength', topic.trendStrength),
                    _buildDetailRow(context, 'Opportunity', topic.opportunityLevel),
                    _buildDetailRow(context, 'Virality Score', '${topic.viralityScore.toStringAsFixed(1)}/100'),
                    const SizedBox(height: 24),
                    if (topic.relatedKeywords.isNotEmpty) ...[
                      Text(
                        'Related Keywords',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: topic.relatedKeywords.map((keyword) {
                          return Chip(
                            label: Text(keyword),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

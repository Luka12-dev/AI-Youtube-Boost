import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';

class NicheAnalyticsScreen extends StatefulWidget {
  const NicheAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<NicheAnalyticsScreen> createState() => _NicheAnalyticsScreenState();
}

class _NicheAnalyticsScreenState extends State<NicheAnalyticsScreen> {
  final TextEditingController _nicheController = TextEditingController();

  @override
  void dispose() {
    _nicheController.dispose();
    super.dispose();
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
              _buildSearchSection(context, appProvider),
              Expanded(
                child: appProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : appProvider.currentNicheData == null
                        ? _buildEmptyState(context)
                        : _buildNicheData(context, appProvider),
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
                  'Niche Analytics',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Analyze any niche or topic',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, AppProvider appProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nicheController,
              decoration: InputDecoration(
                hintText: 'Enter niche or topic...',
                prefixIcon: const Icon(Icons.category_rounded),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  appProvider.analyzeNiche(value);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              if (_nicheController.text.isNotEmpty) {
                appProvider.analyzeNiche(_nicheController.text);
              }
            },
            child: const Text('Analyze'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyze Any Niche',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Enter a niche or topic to get detailed analytics',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicheData(BuildContext context, AppProvider appProvider) {
    final nicheData = appProvider.currentNicheData!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_special_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nicheData.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatRow(
                  context,
                  'Total Videos',
                  '${nicheData.totalVideos}',
                  Icons.videocam_rounded,
                ),
                _buildStatRow(
                  context,
                  'Total Views',
                  nicheData.formattedTotalViews,
                  Icons.visibility_rounded,
                ),
                _buildStatRow(
                  context,
                  'Average Views',
                  nicheData.formattedAvgViews,
                  Icons.trending_up_rounded,
                ),
                _buildStatRow(
                  context,
                  'Engagement Rate',
                  '${nicheData.avgEngagementRate.toStringAsFixed(2)}%',
                  Icons.favorite_rounded,
                ),
                _buildStatRow(
                  context,
                  'Growth Rate',
                  '${nicheData.growthRate.toStringAsFixed(1)}%',
                  Icons.show_chart_rounded,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getGrowthColor(nicheData.growthRate).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: _getGrowthColor(nicheData.growthRate),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nicheData.growthIndicator,
                        style: TextStyle(
                          color: _getGrowthColor(nicheData.growthRate),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
        const SizedBox(height: 16),
        if (nicheData.topKeywords.isNotEmpty) ...[
          Text(
            'Top Keywords',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: nicheData.topKeywords.map((keyword) {
                  return Chip(
                    label: Text(keyword),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                  );
                }).toList(),
              ),
            ),
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 200),
          ),
        ],
        if (nicheData.risingKeywords.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Rising Keywords',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: nicheData.risingKeywords.map((keyword) {
                  return Chip(
                    label: Text(keyword),
                    avatar: const Icon(Icons.arrow_upward, size: 16),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ),
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 300),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'View Distribution',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: nicheData.viewDistribution.entries.map((entry) {
                final percentage = nicheData.totalVideos > 0
                    ? (entry.value / nicheData.totalVideos * 100)
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ).animate().fadeIn(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 400),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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

  Color _getGrowthColor(double rate) {
    if (rate > 20) return Colors.green;
    if (rate > 10) return Colors.blue;
    if (rate > 0) return Colors.orange;
    return Colors.red;
  }
}

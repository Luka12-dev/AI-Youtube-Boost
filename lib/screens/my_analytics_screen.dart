import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../models/video_data.dart';

class MyAnalyticsScreen extends StatefulWidget {
  const MyAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<MyAnalyticsScreen> createState() => _MyAnalyticsScreenState();
}

class _MyAnalyticsScreenState extends State<MyAnalyticsScreen> {
  bool _isLoading = false;
  List<VideoData> _channelVideos = [];

  @override
  void initState() {
    super.initState();
    _loadChannelAnalytics();
  }

  Future<void> _loadChannelAnalytics() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final channelData = appProvider.storageService.getChannelData();
    
    if (channelData == null) return;

    setState(() => _isLoading = true);

    try {
      // Search for videos from this channel
      final channelName = channelData['title'] ?? '';
      final videos = await appProvider.youtubeService.searchVideos(
        query: channelName,
        maxResults: 50,
      );
      
      // Filter to only videos from this channel
      _channelVideos = videos.where((v) => 
        v.channelTitle.toLowerCase() == channelName.toLowerCase()
      ).toList();
      
      // Save analytics data
      await _saveAnalyticsData();
      
    } catch (e) {
      print('Error loading analytics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAnalyticsData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    final analyticsData = {
      'lastUpdated': DateTime.now().toIso8601String(),
      'totalVideos': _channelVideos.length,
      'videos': _channelVideos.map((v) => v.toJson()).toList(),
    };
    
    await appProvider.storageService.prefs.setString(
      'my_analytics_data',
      appProvider.storageService.prefs.getString('my_channel_data') != null 
        ? appProvider.storageService.prefs.getString('my_analytics_data') ?? '{}'
        : '{}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final channelData = appProvider.storageService.getChannelData();

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
                child: channelData == null
                    ? _buildNoChannelState(context)
                    : _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildAnalytics(context, channelData, appProvider, themeProvider),
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
                  'My Analytics',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Your channel performance',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadChannelAnalytics,
          ),
        ],
      ),
    );
  }

  Widget _buildNoChannelState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.link_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Channel Connected',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please connect your YouTube channel first to view analytics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // User will open sidebar to connect channel
              },
              icon: const Icon(Icons.link_rounded),
              label: const Text('Connect Channel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalytics(
    BuildContext context,
    Map<String, dynamic> channelData,
    AppProvider appProvider,
    ThemeProvider themeProvider,
  ) {
    final subscriberCount = channelData['subscriberCount'] ?? 0;
    final videoCount = channelData['videoCount'] ?? 0;
    final viewCount = channelData['viewCount'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadChannelAnalytics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildChannelOverview(context, channelData),
          const SizedBox(height: 16),
          _buildStatsCards(context, subscriberCount, videoCount, viewCount),
          const SizedBox(height: 16),
          if (_channelVideos.isNotEmpty) ...[
            _buildPerformanceSection(context),
            const SizedBox(height: 16),
            _buildTopVideos(context),
            const SizedBox(height: 16),
            _buildEngagementChart(context, themeProvider),
          ],
        ],
      ),
    );
  }

  Widget _buildChannelOverview(BuildContext context, Map<String, dynamic> channelData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Channel Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              channelData['title'] ?? 'Unknown Channel',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (channelData['description'] != null && 
                (channelData['description'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                channelData['description'],
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildStatsCards(
    BuildContext context,
    int subscribers,
    int videos,
    int views,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Subscribers',
            _formatNumber(subscribers),
            Icons.people_rounded,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Videos',
            videos.toString(),
            Icons.videocam_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Total Views',
            _formatNumber(views),
            Icons.visibility_rounded,
            Colors.green,
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 200),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    final totalViews = _channelVideos.fold<int>(0, (sum, v) => sum + v.viewCount);
    final avgViews = _channelVideos.isEmpty ? 0 : totalViews ~/ _channelVideos.length;
    final avgEngagement = _channelVideos.isEmpty
        ? 0.0
        : _channelVideos.fold<double>(0, (sum, v) => sum + v.engagementRate) / 
          _channelVideos.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Performance Metrics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMetricRow(context, 'Average Views', _formatNumber(avgViews)),
            _buildMetricRow(context, 'Average Engagement', '${avgEngagement.toStringAsFixed(2)}%'),
            _buildMetricRow(context, 'Total Videos Analyzed', '${_channelVideos.length}'),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 300),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
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

  Widget _buildTopVideos(BuildContext context) {
    final topVideos = List<VideoData>.from(_channelVideos)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    final top5 = topVideos.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Top Performing Videos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...top5.asMap().entries.map((entry) {
              final index = entry.key;
              final video = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _getRankColor(index),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                            video.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${video.formattedViews} views',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 400),
    );
  }

  Widget _buildEngagementChart(BuildContext context, ThemeProvider themeProvider) {
    if (_channelVideos.isEmpty) return const SizedBox();

    final sortedVideos = List<VideoData>.from(_channelVideos)
      ..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Engagement Trend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sortedVideos.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.engagementRate,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 500),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

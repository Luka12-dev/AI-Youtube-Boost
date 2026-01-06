import 'dart:math';
import '../models/competitor_channel.dart';
import '../models/video_data.dart';

/// Competitor Tracking Service for AI YouTube Boost v2.0
/// Tracks and analyzes competitor channels
class CompetitorTrackingService {
  final Random _random = Random();

  /// Track a new competitor channel
  Future<CompetitorChannel> trackChannel(String channelId, String channelName) async {
    final metrics = await _generateChannelMetrics();
    final schedule = await _analyzeUploadSchedule();
    
    return CompetitorChannel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      channelId: channelId,
      channelName: channelName,
      channelThumbnail: 'https://via.placeholder.com/150',
      subscriberCount: 100000 + _random.nextInt(900000),
      videoCount: 50 + _random.nextInt(450),
      totalViews: 1000000 + _random.nextInt(9000000),
      lastUpdated: DateTime.now(),
      metrics: metrics,
      growthRate: -2 + _random.nextDouble() * 15,
      avgViewsPerVideo: 10000 + _random.nextDouble() * 90000,
      avgEngagementRate: 1 + _random.nextDouble() * 4,
      topTopics: ['Tutorial', 'Review', 'Guide', 'Tips'],
      uploadSchedule: schedule,
      isTracking: true,
    );
  }

  Future<List<ChannelMetric>> _generateChannelMetrics() async {
    final metrics = <ChannelMetric>[];
    final now = DateTime.now();
    
    for (int i = 30; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      metrics.add(ChannelMetric(
        date: date,
        subscribers: 100000 + (30 - i) * 1000 + _random.nextInt(500),
        views: 50000 + _random.nextInt(50000),
        videosPublished: _random.nextInt(3),
        engagementRate: 2.0 + _random.nextDouble() * 3,
      ));
    }
    
    return metrics;
  }

  Future<UploadSchedule> _analyzeUploadSchedule() async {
    return UploadSchedule(
      weekdayFrequency: {
        'Monday': 2 + _random.nextInt(3),
        'Tuesday': 3 + _random.nextInt(4),
        'Wednesday': 2 + _random.nextInt(3),
        'Thursday': 3 + _random.nextInt(4),
        'Friday': 4 + _random.nextInt(3),
        'Saturday': 1 + _random.nextInt(2),
        'Sunday': 1 + _random.nextInt(2),
      },
      optimalHours: [10, 14, 18],
      consistency: 0.7 + _random.nextDouble() * 0.25,
      avgVideosPerWeek: 3 + _random.nextInt(5),
    );
  }

  /// Compare your channel with competitors
  Future<Map<String, dynamic>> compareWithCompetitors(
    Map<String, dynamic> yourStats,
    List<CompetitorChannel> competitors,
  ) async {
    final comparison = <String, dynamic>{};
    
    final yourSubs = yourStats['subscribers'] ?? 0;
    final yourAvgViews = yourStats['avgViews'] ?? 0;
    final yourEngagement = yourStats['engagement'] ?? 0;
    
    final avgCompetitorSubs = competitors.map((c) => c.subscriberCount).reduce((a, b) => a + b) / competitors.length;
    final avgCompetitorViews = competitors.map((c) => c.avgViewsPerVideo).reduce((a, b) => a + b) / competitors.length;
    final avgCompetitorEngagement = competitors.map((c) => c.avgEngagementRate).reduce((a, b) => a + b) / competitors.length;
    
    comparison['subscriberGap'] = yourSubs - avgCompetitorSubs;
    comparison['viewsGap'] = yourAvgViews - avgCompetitorViews;
    comparison['engagementGap'] = yourEngagement - avgCompetitorEngagement;
    comparison['ranking'] = _calculateRanking(yourStats, competitors);
    comparison['recommendations'] = _generateComparisonRecommendations(yourStats, competitors);
    
    return comparison;
  }

  int _calculateRanking(Map<String, dynamic> yourStats, List<CompetitorChannel> competitors) {
    final yourScore = (yourStats['subscribers'] ?? 0) * 0.4 + 
                     (yourStats['avgViews'] ?? 0) * 0.4 + 
                     (yourStats['engagement'] ?? 0) * 20;
    
    int rank = 1;
    for (var competitor in competitors) {
      final competitorScore = competitor.subscriberCount * 0.4 + 
                             competitor.avgViewsPerVideo * 0.4 + 
                             competitor.avgEngagementRate * 20;
      if (competitorScore > yourScore) rank++;
    }
    
    return rank;
  }

  List<String> _generateComparisonRecommendations(
    Map<String, dynamic> yourStats,
    List<CompetitorChannel> competitors,
  ) {
    final recommendations = <String>[];
    
    final bestGrowthCompetitor = competitors.reduce((a, b) => a.growthRate > b.growthRate ? a : b);
    recommendations.add('📈 ${bestGrowthCompetitor.channelName} is growing at ${bestGrowthCompetitor.growthRate.toStringAsFixed(1)}%/month');
    
    final bestSchedule = competitors.reduce((a, b) => a.uploadSchedule.consistency > b.uploadSchedule.consistency ? a : b);
    recommendations.add('📅 Best posting schedule: ${bestSchedule.uploadSchedule.bestUploadDay} at ${bestSchedule.uploadSchedule.bestUploadTime}');
    
    recommendations.add('💡 Average posting frequency: ${(competitors.map((c) => c.uploadSchedule.avgVideosPerWeek).reduce((a, b) => a + b) / competitors.length).toStringAsFixed(1)} videos/week');
    
    return recommendations;
  }
}

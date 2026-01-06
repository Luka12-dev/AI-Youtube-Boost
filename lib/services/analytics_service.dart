import 'dart:math';
import '../models/video_data.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Map<String, dynamic> calculateStatistics(List<VideoData> videos) {
    if (videos.isEmpty) {
      return {
        'total_videos': 0,
        'total_views': 0,
        'avg_views': 0,
        'median_views': 0,
        'max_views': 0,
        'min_views': 0,
        'avg_engagement': 0.0,
        'total_likes': 0,
        'total_comments': 0,
      };
    }

    final totalViews = videos.fold<int>(0, (sum, v) => sum + v.viewCount);
    final totalLikes = videos.fold<int>(0, (sum, v) => sum + v.likeCount);
    final totalComments = videos.fold<int>(0, (sum, v) => sum + v.commentCount);
    
    final sortedViews = videos.map((v) => v.viewCount).toList()..sort();
    final medianViews = sortedViews[sortedViews.length ~/ 2];
    
    final avgEngagement = videos.fold<double>(
      0.0,
      (sum, v) => sum + v.engagementRate,
    ) / videos.length;

    return {
      'total_videos': videos.length,
      'total_views': totalViews,
      'avg_views': totalViews ~/ videos.length,
      'median_views': medianViews,
      'max_views': sortedViews.last,
      'min_views': sortedViews.first,
      'avg_engagement': avgEngagement,
      'total_likes': totalLikes,
      'total_comments': totalComments,
    };
  }

  List<Map<String, dynamic>> getViewDistribution(List<VideoData> videos) {
    final ranges = [
      {'label': '0-1K', 'min': 0, 'max': 1000, 'count': 0},
      {'label': '1K-10K', 'min': 1000, 'max': 10000, 'count': 0},
      {'label': '10K-100K', 'min': 10000, 'max': 100000, 'count': 0},
      {'label': '100K-1M', 'min': 100000, 'max': 1000000, 'count': 0},
      {'label': '1M+', 'min': 1000000, 'max': double.infinity, 'count': 0},
    ];

    for (var video in videos) {
      for (var range in ranges) {
        final minValue = range['min'] as num;
        final maxValue = range['max'] as num;
        if (video.viewCount >= minValue && video.viewCount < maxValue) {
          range['count'] = (range['count'] as int) + 1;
          break;
        }
      }
    }

    return ranges;
  }

  Map<String, int> getPublishingPatterns(List<VideoData> videos) {
    final patterns = <String, int>{};
    
    for (var video in videos) {
      final hour = video.publishedAt.hour;
      final timeSlot = _getTimeSlot(hour);
      patterns[timeSlot] = (patterns[timeSlot] ?? 0) + 1;
    }

    return patterns;
  }

  String _getTimeSlot(int hour) {
    if (hour >= 0 && hour < 6) return 'Night (0-6)';
    if (hour >= 6 && hour < 12) return 'Morning (6-12)';
    if (hour >= 12 && hour < 18) return 'Afternoon (12-18)';
    return 'Evening (18-24)';
  }

  Map<String, int> getDayOfWeekDistribution(List<VideoData> videos) {
    final days = <String, int>{
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };

    for (var video in videos) {
      final dayName = _getDayName(video.publishedAt.weekday);
      days[dayName] = days[dayName]! + 1;
    }

    return days;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }

  List<VideoData> getTopPerformers(List<VideoData> videos, {int limit = 10}) {
    final sorted = List<VideoData>.from(videos)
      ..sort((a, b) => b.trendingScore.compareTo(a.trendingScore));
    return sorted.take(limit).toList();
  }

  List<String> extractCommonKeywords(List<VideoData> videos, {int limit = 20}) {
    final keywordFrequency = <String, int>{};

    for (var video in videos) {
      for (var tag in video.tags) {
        final normalized = tag.toLowerCase();
        keywordFrequency[normalized] = (keywordFrequency[normalized] ?? 0) + 1;
      }
    }

    final sorted = keywordFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }

  double calculateCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) return 0.0;

    final meanX = x.reduce((a, b) => a + b) / x.length.toDouble();
    final meanY = y.reduce((a, b) => a + b) / y.length.toDouble();

    double numerator = 0;
    double denomX = 0;
    double denomY = 0;

    for (int i = 0; i < x.length; i++) {
      final diffX = x[i] - meanX;
      final diffY = y[i] - meanY;
      numerator += diffX * diffY;
      denomX += diffX * diffX;
      denomY += diffY * diffY;
    }

    if (denomX == 0 || denomY == 0) return 0.0;

    return numerator / sqrt(denomX * denomY);
  }

  Map<String, dynamic> predictOptimalPostTime(List<VideoData> videos) {
    final hourlyPerformance = <int, List<double>>{};

    for (var video in videos) {
      final hour = video.publishedAt.hour;
      if (!hourlyPerformance.containsKey(hour)) {
        hourlyPerformance[hour] = [];
      }
      hourlyPerformance[hour]!.add(video.trendingScore);
    }

    int bestHour = 0;
    double bestScore = 0.0;

    for (var entry in hourlyPerformance.entries) {
      final avgScore = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avgScore > bestScore) {
        bestScore = avgScore;
        bestHour = entry.key;
      }
    }

    return {
      'optimal_hour': bestHour,
      'score': bestScore,
      'confidence': hourlyPerformance[bestHour]!.length / videos.length,
      'time_formatted': _formatHour(bestHour),
    };
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  List<Map<String, dynamic>> generateInsights(List<VideoData> videos) {
    final insights = <Map<String, dynamic>>[];

    if (videos.isEmpty) return insights;

    final stats = calculateStatistics(videos);
    final avgViews = stats['avg_views'] as int;
    final avgEngagement = stats['avg_engagement'] as double;

    final topPerformers = getTopPerformers(videos, limit: 3);
    if (topPerformers.isNotEmpty) {
      insights.add({
        'type': 'top_performer',
        'title': 'Top Performing Content',
        'description': 'Your best video has ${topPerformers.first.formattedViews} views',
        'importance': 'high',
      });
    }

    if (avgEngagement > 5.0) {
      insights.add({
        'type': 'engagement',
        'title': 'High Engagement Rate',
        'description': 'Your content has an excellent engagement rate of ${avgEngagement.toStringAsFixed(2)}%',
        'importance': 'high',
      });
    } else if (avgEngagement < 2.0) {
      insights.add({
        'type': 'engagement',
        'title': 'Engagement Opportunity',
        'description': 'Consider improving engagement through better CTAs and interaction',
        'importance': 'medium',
      });
    }

    final optimalTime = predictOptimalPostTime(videos);
    insights.add({
      'type': 'timing',
      'title': 'Optimal Post Time',
      'description': 'Your content performs best when posted at ${optimalTime['time_formatted']}',
      'importance': 'medium',
    });

    return insights;
  }
}

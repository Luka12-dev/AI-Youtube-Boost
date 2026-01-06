/// Competitor Channel Model for AI YouTube Boost v2.0
/// Tracks and analyzes competitor channels
class CompetitorChannel {
  final String id;
  final String channelId;
  final String channelName;
  final String channelThumbnail;
  final int subscriberCount;
  final int videoCount;
  final int totalViews;
  final DateTime lastUpdated;
  final List<ChannelMetric> metrics;
  final double growthRate;
  final double avgViewsPerVideo;
  final double avgEngagementRate;
  final List<String> topTopics;
  final UploadSchedule uploadSchedule;
  final bool isTracking;

  CompetitorChannel({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.channelThumbnail,
    required this.subscriberCount,
    required this.videoCount,
    required this.totalViews,
    required this.lastUpdated,
    required this.metrics,
    required this.growthRate,
    required this.avgViewsPerVideo,
    required this.avgEngagementRate,
    required this.topTopics,
    required this.uploadSchedule,
    required this.isTracking,
  });

  factory CompetitorChannel.fromJson(Map<String, dynamic> json) {
    return CompetitorChannel(
      id: json['id'] ?? '',
      channelId: json['channelId'] ?? '',
      channelName: json['channelName'] ?? '',
      channelThumbnail: json['channelThumbnail'] ?? '',
      subscriberCount: json['subscriberCount'] ?? 0,
      videoCount: json['videoCount'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      metrics: (json['metrics'] as List<dynamic>?)
              ?.map((e) => ChannelMetric.fromJson(e))
              .toList() ??
          [],
      growthRate: (json['growthRate'] ?? 0).toDouble(),
      avgViewsPerVideo: (json['avgViewsPerVideo'] ?? 0).toDouble(),
      avgEngagementRate: (json['avgEngagementRate'] ?? 0).toDouble(),
      topTopics: List<String>.from(json['topTopics'] ?? []),
      uploadSchedule: UploadSchedule.fromJson(json['uploadSchedule'] ?? {}),
      isTracking: json['isTracking'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'channelName': channelName,
      'channelThumbnail': channelThumbnail,
      'subscriberCount': subscriberCount,
      'videoCount': videoCount,
      'totalViews': totalViews,
      'lastUpdated': lastUpdated.toIso8601String(),
      'metrics': metrics.map((e) => e.toJson()).toList(),
      'growthRate': growthRate,
      'avgViewsPerVideo': avgViewsPerVideo,
      'avgEngagementRate': avgEngagementRate,
      'topTopics': topTopics,
      'uploadSchedule': uploadSchedule.toJson(),
      'isTracking': isTracking,
    };
  }

  String get formattedSubscribers {
    if (subscriberCount >= 1000000) {
      return '${(subscriberCount / 1000000).toStringAsFixed(1)}M';
    } else if (subscriberCount >= 1000) {
      return '${(subscriberCount / 1000).toStringAsFixed(1)}K';
    }
    return subscriberCount.toString();
  }

  String get formattedAvgViews {
    if (avgViewsPerVideo >= 1000000) {
      return '${(avgViewsPerVideo / 1000000).toStringAsFixed(1)}M';
    } else if (avgViewsPerVideo >= 1000) {
      return '${(avgViewsPerVideo / 1000).toStringAsFixed(1)}K';
    }
    return avgViewsPerVideo.toStringAsFixed(0);
  }

  String get growthStatus {
    if (growthRate >= 10) return 'Explosive Growth';
    if (growthRate >= 5) return 'High Growth';
    if (growthRate >= 2) return 'Steady Growth';
    if (growthRate >= 0) return 'Slow Growth';
    return 'Declining';
  }
}

class ChannelMetric {
  final DateTime date;
  final int subscribers;
  final int views;
  final int videosPublished;
  final double engagementRate;

  ChannelMetric({
    required this.date,
    required this.subscribers,
    required this.views,
    required this.videosPublished,
    required this.engagementRate,
  });

  factory ChannelMetric.fromJson(Map<String, dynamic> json) {
    return ChannelMetric(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      subscribers: json['subscribers'] ?? 0,
      views: json['views'] ?? 0,
      videosPublished: json['videosPublished'] ?? 0,
      engagementRate: (json['engagementRate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'subscribers': subscribers,
      'views': views,
      'videosPublished': videosPublished,
      'engagementRate': engagementRate,
    };
  }
}

class UploadSchedule {
  final Map<String, int> weekdayFrequency;
  final List<int> optimalHours;
  final double consistency;
  final int avgVideosPerWeek;

  UploadSchedule({
    required this.weekdayFrequency,
    required this.optimalHours,
    required this.consistency,
    required this.avgVideosPerWeek,
  });

  factory UploadSchedule.fromJson(Map<String, dynamic> json) {
    return UploadSchedule(
      weekdayFrequency: Map<String, int>.from(json['weekdayFrequency'] ?? {}),
      optimalHours: List<int>.from(json['optimalHours'] ?? []),
      consistency: (json['consistency'] ?? 0).toDouble(),
      avgVideosPerWeek: json['avgVideosPerWeek'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekdayFrequency': weekdayFrequency,
      'optimalHours': optimalHours,
      'consistency': consistency,
      'avgVideosPerWeek': avgVideosPerWeek,
    };
  }

  String get bestUploadDay {
    if (weekdayFrequency.isEmpty) return 'Unknown';
    return weekdayFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get bestUploadTime {
    if (optimalHours.isEmpty) return 'Unknown';
    final hour = optimalHours.first;
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}

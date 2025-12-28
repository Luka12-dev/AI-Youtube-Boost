class VideoData {
  final String id;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final DateTime publishedAt;
  final String description;
  final List<String> tags;
  final String categoryId;
  final Duration duration;
  final double engagementRate;
  final double trendingScore;

  VideoData({
    required this.id,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.publishedAt,
    required this.description,
    required this.tags,
    required this.categoryId,
    required this.duration,
    required this.engagementRate,
    required this.trendingScore,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    // Check if this is a stored favorite (has direct fields) or API response (has snippet)
    if (json.containsKey('snippet')) {
      // API response format
      final snippet = json['snippet'] ?? {};
      final statistics = json['statistics'] ?? {};
      final contentDetails = json['contentDetails'] ?? {};

      int views = int.tryParse(statistics['viewCount']?.toString() ?? '0') ?? 0;
      int likes = int.tryParse(statistics['likeCount']?.toString() ?? '0') ?? 0;
      int comments = int.tryParse(statistics['commentCount']?.toString() ?? '0') ?? 0;

      double engagement = views > 0 ? ((likes + comments) / views) * 100 : 0.0;

      return VideoData(
        id: json['id'] is String ? json['id'] : json['id']['videoId'] ?? '',
        title: snippet['title'] ?? 'Unknown Title',
        channelTitle: snippet['channelTitle'] ?? 'Unknown Channel',
        thumbnailUrl: snippet['thumbnails']?['high']?['url'] ?? 
                      snippet['thumbnails']?['medium']?['url'] ?? 
                      snippet['thumbnails']?['default']?['url'] ?? '',
        viewCount: views,
        likeCount: likes,
        commentCount: comments,
        publishedAt: DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
        description: snippet['description'] ?? '',
        tags: List<String>.from(snippet['tags'] ?? []),
        categoryId: snippet['categoryId'] ?? '0',
        duration: _parseDuration(contentDetails['duration'] ?? 'PT0S'),
        engagementRate: engagement,
        trendingScore: _calculateTrendingScore(views, likes, comments, 
            DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now()),
      );
    } else {
      // Stored favorite format (from toJson)
      return VideoData(
        id: json['id'] ?? '',
        title: json['title'] ?? 'Unknown Title',
        channelTitle: json['channelTitle'] ?? 'Unknown Channel',
        thumbnailUrl: json['thumbnailUrl'] ?? '',
        viewCount: json['viewCount'] ?? 0,
        likeCount: json['likeCount'] ?? 0,
        commentCount: json['commentCount'] ?? 0,
        publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
        description: json['description'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        categoryId: json['categoryId'] ?? '0',
        duration: Duration(seconds: json['duration'] ?? 0),
        engagementRate: json['engagementRate']?.toDouble() ?? 0.0,
        trendingScore: json['trendingScore']?.toDouble() ?? 0.0,
      );
    }
  }

  static Duration _parseDuration(String isoDuration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);
    
    if (match == null) return Duration.zero;
    
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  static double _calculateTrendingScore(int views, int likes, int comments, DateTime publishedAt) {
    final daysSincePublished = DateTime.now().difference(publishedAt).inDays;
    final recencyFactor = daysSincePublished > 0 ? 1.0 / daysSincePublished : 1.0;
    final engagementScore = (likes * 2 + comments * 3).toDouble();
    final viewScore = views / 1000.0;
    
    return (viewScore * 0.4 + engagementScore * 0.4 + recencyFactor * 1000 * 0.2);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelTitle': channelTitle,
      'thumbnailUrl': thumbnailUrl,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'publishedAt': publishedAt.toIso8601String(),
      'description': description,
      'tags': tags,
      'categoryId': categoryId,
      'duration': duration.inSeconds,
      'engagementRate': engagementRate,
      'trendingScore': trendingScore,
    };
  }

  String get formattedViews {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(publishedAt);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

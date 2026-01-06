/// Hashtag Analysis Model for AI YouTube Boost v2.0
/// Analyzes and generates optimal hashtags for videos
class HashtagAnalysis {
  final String id;
  final String videoTitle;
  final String category;
  final List<HashtagItem> generatedHashtags;
  final List<HashtagItem> trendingHashtags;
  final Map<String, double> categoryRelevance;
  final DateTime analysisDate;
  final double overallScore;
  final List<String> recommendations;

  HashtagAnalysis({
    required this.id,
    required this.videoTitle,
    required this.category,
    required this.generatedHashtags,
    required this.trendingHashtags,
    required this.categoryRelevance,
    required this.analysisDate,
    required this.overallScore,
    required this.recommendations,
  });

  factory HashtagAnalysis.fromJson(Map<String, dynamic> json) {
    return HashtagAnalysis(
      id: json['id'] ?? '',
      videoTitle: json['videoTitle'] ?? '',
      category: json['category'] ?? '',
      generatedHashtags: (json['generatedHashtags'] as List<dynamic>?)
              ?.map((e) => HashtagItem.fromJson(e))
              .toList() ??
          [],
      trendingHashtags: (json['trendingHashtags'] as List<dynamic>?)
              ?.map((e) => HashtagItem.fromJson(e))
              .toList() ??
          [],
      categoryRelevance: Map<String, double>.from(json['categoryRelevance'] ?? {}),
      analysisDate: DateTime.tryParse(json['analysisDate'] ?? '') ?? DateTime.now(),
      overallScore: (json['overallScore'] ?? 0).toDouble(),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoTitle': videoTitle,
      'category': category,
      'generatedHashtags': generatedHashtags.map((e) => e.toJson()).toList(),
      'trendingHashtags': trendingHashtags.map((e) => e.toJson()).toList(),
      'categoryRelevance': categoryRelevance,
      'analysisDate': analysisDate.toIso8601String(),
      'overallScore': overallScore,
      'recommendations': recommendations,
    };
  }

  List<HashtagItem> getTopHashtags(int count) {
    final allHashtags = [...generatedHashtags, ...trendingHashtags];
    allHashtags.sort((a, b) => b.score.compareTo(a.score));
    return allHashtags.take(count).toList();
  }

  String getHashtagString() {
    final topTags = getTopHashtags(30);
    return topTags.map((tag) => '#${tag.tag}').join(' ');
  }
}

class HashtagItem {
  final String tag;
  final double score;
  final int searchVolume;
  final double competitionLevel;
  final HashtagTrend trend;
  final String category;
  final bool isRecommended;

  HashtagItem({
    required this.tag,
    required this.score,
    required this.searchVolume,
    required this.competitionLevel,
    required this.trend,
    required this.category,
    required this.isRecommended,
  });

  factory HashtagItem.fromJson(Map<String, dynamic> json) {
    return HashtagItem(
      tag: json['tag'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      searchVolume: json['searchVolume'] ?? 0,
      competitionLevel: (json['competitionLevel'] ?? 0).toDouble(),
      trend: HashtagTrend.values.firstWhere(
        (e) => e.toString() == json['trend'],
        orElse: () => HashtagTrend.stable,
      ),
      category: json['category'] ?? '',
      isRecommended: json['isRecommended'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'score': score,
      'searchVolume': searchVolume,
      'competitionLevel': competitionLevel,
      'trend': trend.toString(),
      'category': category,
      'isRecommended': isRecommended,
    };
  }

  String get formattedSearchVolume {
    if (searchVolume >= 1000000) {
      return '${(searchVolume / 1000000).toStringAsFixed(1)}M';
    } else if (searchVolume >= 1000) {
      return '${(searchVolume / 1000).toStringAsFixed(1)}K';
    }
    return searchVolume.toString();
  }

  String get competitionLevelText {
    if (competitionLevel >= 0.8) return 'Very High';
    if (competitionLevel >= 0.6) return 'High';
    if (competitionLevel >= 0.4) return 'Medium';
    if (competitionLevel >= 0.2) return 'Low';
    return 'Very Low';
  }
}

enum HashtagTrend {
  rising,
  stable,
  declining,
  viral,
}

extension HashtagTrendExtension on HashtagTrend {
  String get displayName {
    switch (this) {
      case HashtagTrend.rising:
        return 'Rising';
      case HashtagTrend.stable:
        return 'Stable';
      case HashtagTrend.declining:
        return 'Declining';
      case HashtagTrend.viral:
        return 'Viral';
    }
  }

  String get emoji {
    switch (this) {
      case HashtagTrend.rising:
        return '📈';
      case HashtagTrend.stable:
        return '➡️';
      case HashtagTrend.declining:
        return '📉';
      case HashtagTrend.viral:
        return '🔥';
    }
  }
}

class TrendingTopic {
  final String keyword;
  final int searchVolume;
  final double growthRate;
  final int videoCount;
  final double competitionLevel;
  final List<String> relatedKeywords;
  final DateTime trendingStartDate;
  final String category;
  final double viralityScore;

  TrendingTopic({
    required this.keyword,
    required this.searchVolume,
    required this.growthRate,
    required this.videoCount,
    required this.competitionLevel,
    required this.relatedKeywords,
    required this.trendingStartDate,
    required this.category,
    required this.viralityScore,
  });

  factory TrendingTopic.fromJson(Map<String, dynamic> json) {
    return TrendingTopic(
      keyword: json['keyword'] ?? '',
      searchVolume: json['searchVolume'] ?? 0,
      growthRate: (json['growthRate'] ?? 0.0).toDouble(),
      videoCount: json['videoCount'] ?? 0,
      competitionLevel: (json['competitionLevel'] ?? 0.0).toDouble(),
      relatedKeywords: List<String>.from(json['relatedKeywords'] ?? []),
      trendingStartDate: DateTime.tryParse(json['trendingStartDate'] ?? '') ?? DateTime.now(),
      category: json['category'] ?? 'General',
      viralityScore: (json['viralityScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'searchVolume': searchVolume,
      'growthRate': growthRate,
      'videoCount': videoCount,
      'competitionLevel': competitionLevel,
      'relatedKeywords': relatedKeywords,
      'trendingStartDate': trendingStartDate.toIso8601String(),
      'category': category,
      'viralityScore': viralityScore,
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
    if (competitionLevel < 0.3) return 'Low';
    if (competitionLevel < 0.6) return 'Medium';
    if (competitionLevel < 0.8) return 'High';
    return 'Very High';
  }

  String get trendStrength {
    if (growthRate > 100) return 'Exploding';
    if (growthRate > 50) return 'Rising Fast';
    if (growthRate > 20) return 'Growing';
    if (growthRate > 0) return 'Steady';
    return 'Declining';
  }

  String get opportunityLevel {
    if (viralityScore > 80 && competitionLevel < 0.5) return 'Excellent';
    if (viralityScore > 60 && competitionLevel < 0.7) return 'Good';
    if (viralityScore > 40) return 'Moderate';
    return 'Low';
  }
}

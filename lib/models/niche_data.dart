class NicheData {
  final String name;
  final String categoryId;
  final int totalVideos;
  final int totalViews;
  final int avgViews;
  final double avgEngagementRate;
  final double growthRate;
  final List<String> topKeywords;
  final List<String> risingKeywords;
  final Map<String, int> viewDistribution;
  final DateTime lastUpdated;

  NicheData({
    required this.name,
    required this.categoryId,
    required this.totalVideos,
    required this.totalViews,
    required this.avgViews,
    required this.avgEngagementRate,
    required this.growthRate,
    required this.topKeywords,
    required this.risingKeywords,
    required this.viewDistribution,
    required this.lastUpdated,
  });

  factory NicheData.fromJson(Map<String, dynamic> json) {
    return NicheData(
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '0',
      totalVideos: json['totalVideos'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      avgViews: json['avgViews'] ?? 0,
      avgEngagementRate: (json['avgEngagementRate'] ?? 0.0).toDouble(),
      growthRate: (json['growthRate'] ?? 0.0).toDouble(),
      topKeywords: List<String>.from(json['topKeywords'] ?? []),
      risingKeywords: List<String>.from(json['risingKeywords'] ?? []),
      viewDistribution: Map<String, int>.from(json['viewDistribution'] ?? {}),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'totalVideos': totalVideos,
      'totalViews': totalViews,
      'avgViews': avgViews,
      'avgEngagementRate': avgEngagementRate,
      'growthRate': growthRate,
      'topKeywords': topKeywords,
      'risingKeywords': risingKeywords,
      'viewDistribution': viewDistribution,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  String get formattedTotalViews {
    if (totalViews >= 1000000000) {
      return '${(totalViews / 1000000000).toStringAsFixed(1)}B';
    } else if (totalViews >= 1000000) {
      return '${(totalViews / 1000000).toStringAsFixed(1)}M';
    } else if (totalViews >= 1000) {
      return '${(totalViews / 1000).toStringAsFixed(1)}K';
    }
    return totalViews.toString();
  }

  String get formattedAvgViews {
    if (avgViews >= 1000000) {
      return '${(avgViews / 1000000).toStringAsFixed(1)}M';
    } else if (avgViews >= 1000) {
      return '${(avgViews / 1000).toStringAsFixed(1)}K';
    }
    return avgViews.toString();
  }

  String get growthIndicator {
    if (growthRate > 20) return 'Rapidly Growing';
    if (growthRate > 10) return 'Growing';
    if (growthRate > 0) return 'Stable Growth';
    if (growthRate > -10) return 'Declining';
    return 'Rapidly Declining';
  }
}

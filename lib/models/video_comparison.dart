/// Video Comparison Model for AI YouTube Boost v2.0
/// Compares multiple videos side-by-side with AI-powered insights
class VideoComparison {
  final String id;
  final List<String> videoIds;
  final DateTime comparisonDate;
  final Map<String, ComparisonMetrics> metrics;
  final String? recommendation;
  final double confidenceScore;

  VideoComparison({
    required this.id,
    required this.videoIds,
    required this.comparisonDate,
    required this.metrics,
    this.recommendation,
    required this.confidenceScore,
  });

  factory VideoComparison.fromJson(Map<String, dynamic> json) {
    return VideoComparison(
      id: json['id'] ?? '',
      videoIds: List<String>.from(json['videoIds'] ?? []),
      comparisonDate: DateTime.tryParse(json['comparisonDate'] ?? '') ?? DateTime.now(),
      metrics: (json['metrics'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ComparisonMetrics.fromJson(value)),
          ) ??
          {},
      recommendation: json['recommendation'],
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoIds': videoIds,
      'comparisonDate': comparisonDate.toIso8601String(),
      'metrics': metrics.map((key, value) => MapEntry(key, value.toJson())),
      'recommendation': recommendation,
      'confidenceScore': confidenceScore,
    };
  }

  String getWinner() {
    if (metrics.isEmpty) return '';
    
    double maxScore = 0;
    String winner = '';
    
    metrics.forEach((videoId, metric) {
      final score = metric.overallScore;
      if (score > maxScore) {
        maxScore = score;
        winner = videoId;
      }
    });
    
    return winner;
  }
}

class ComparisonMetrics {
  final String videoId;
  final double viewsScore;
  final double engagementScore;
  final double retentionScore;
  final double thumbnailScore;
  final double titleScore;
  final double overallScore;
  final Map<String, dynamic> detailedMetrics;

  ComparisonMetrics({
    required this.videoId,
    required this.viewsScore,
    required this.engagementScore,
    required this.retentionScore,
    required this.thumbnailScore,
    required this.titleScore,
    required this.overallScore,
    required this.detailedMetrics,
  });

  factory ComparisonMetrics.fromJson(Map<String, dynamic> json) {
    return ComparisonMetrics(
      videoId: json['videoId'] ?? '',
      viewsScore: (json['viewsScore'] ?? 0).toDouble(),
      engagementScore: (json['engagementScore'] ?? 0).toDouble(),
      retentionScore: (json['retentionScore'] ?? 0).toDouble(),
      thumbnailScore: (json['thumbnailScore'] ?? 0).toDouble(),
      titleScore: (json['titleScore'] ?? 0).toDouble(),
      overallScore: (json['overallScore'] ?? 0).toDouble(),
      detailedMetrics: json['detailedMetrics'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'viewsScore': viewsScore,
      'engagementScore': engagementScore,
      'retentionScore': retentionScore,
      'thumbnailScore': thumbnailScore,
      'titleScore': titleScore,
      'overallScore': overallScore,
      'detailedMetrics': detailedMetrics,
    };
  }

  String getGrade() {
    if (overallScore >= 90) return 'A+';
    if (overallScore >= 80) return 'A';
    if (overallScore >= 70) return 'B';
    if (overallScore >= 60) return 'C';
    if (overallScore >= 50) return 'D';
    return 'F';
  }
}

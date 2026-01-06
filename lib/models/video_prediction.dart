/// Video Performance Prediction Model for AI YouTube Boost v2.0
/// Predicts potential video performance using AI algorithms
class VideoPrediction {
  final String id;
  final String videoTitle;
  final String category;
  final List<String> tags;
  final int predictedViews;
  final int predictedLikes;
  final int predictedComments;
  final double viralityScore;
  final double successProbability;
  final DateTime predictionDate;
  final Map<String, dynamic> factors;
  final List<String> recommendations;
  final PredictionTimeframe timeframe;

  VideoPrediction({
    required this.id,
    required this.videoTitle,
    required this.category,
    required this.tags,
    required this.predictedViews,
    required this.predictedLikes,
    required this.predictedComments,
    required this.viralityScore,
    required this.successProbability,
    required this.predictionDate,
    required this.factors,
    required this.recommendations,
    required this.timeframe,
  });

  factory VideoPrediction.fromJson(Map<String, dynamic> json) {
    return VideoPrediction(
      id: json['id'] ?? '',
      videoTitle: json['videoTitle'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      predictedViews: json['predictedViews'] ?? 0,
      predictedLikes: json['predictedLikes'] ?? 0,
      predictedComments: json['predictedComments'] ?? 0,
      viralityScore: (json['viralityScore'] ?? 0).toDouble(),
      successProbability: (json['successProbability'] ?? 0).toDouble(),
      predictionDate: DateTime.tryParse(json['predictionDate'] ?? '') ?? DateTime.now(),
      factors: json['factors'] ?? {},
      recommendations: List<String>.from(json['recommendations'] ?? []),
      timeframe: PredictionTimeframe.values.firstWhere(
        (e) => e.toString() == json['timeframe'],
        orElse: () => PredictionTimeframe.week,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoTitle': videoTitle,
      'category': category,
      'tags': tags,
      'predictedViews': predictedViews,
      'predictedLikes': predictedLikes,
      'predictedComments': predictedComments,
      'viralityScore': viralityScore,
      'successProbability': successProbability,
      'predictionDate': predictionDate.toIso8601String(),
      'factors': factors,
      'recommendations': recommendations,
      'timeframe': timeframe.toString(),
    };
  }

  String get formattedPredictedViews {
    if (predictedViews >= 1000000) {
      return '${(predictedViews / 1000000).toStringAsFixed(1)}M';
    } else if (predictedViews >= 1000) {
      return '${(predictedViews / 1000).toStringAsFixed(1)}K';
    }
    return predictedViews.toString();
  }

  String get successLevel {
    if (successProbability >= 0.8) return 'Very High';
    if (successProbability >= 0.6) return 'High';
    if (successProbability >= 0.4) return 'Medium';
    if (successProbability >= 0.2) return 'Low';
    return 'Very Low';
  }

  String get viralityLevel {
    if (viralityScore >= 80) return 'Extremely Viral';
    if (viralityScore >= 60) return 'Highly Viral';
    if (viralityScore >= 40) return 'Moderately Viral';
    if (viralityScore >= 20) return 'Low Viral Potential';
    return 'Minimal Viral Potential';
  }
}

enum PredictionTimeframe {
  day,
  week,
  month,
  quarter,
  year,
}

extension PredictionTimeframeExtension on PredictionTimeframe {
  String get displayName {
    switch (this) {
      case PredictionTimeframe.day:
        return '24 Hours';
      case PredictionTimeframe.week:
        return '7 Days';
      case PredictionTimeframe.month:
        return '30 Days';
      case PredictionTimeframe.quarter:
        return '90 Days';
      case PredictionTimeframe.year:
        return '1 Year';
    }
  }

  int get days {
    switch (this) {
      case PredictionTimeframe.day:
        return 1;
      case PredictionTimeframe.week:
        return 7;
      case PredictionTimeframe.month:
        return 30;
      case PredictionTimeframe.quarter:
        return 90;
      case PredictionTimeframe.year:
        return 365;
    }
  }
}

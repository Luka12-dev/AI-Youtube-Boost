import 'dart:math';
import '../models/video_data.dart';
import '../models/video_prediction.dart';

/// Video Performance Predictor Service for AI YouTube Boost v2.0
/// Uses AI algorithms to predict video performance
class VideoPredictorService {
  /// Predict video performance based on various factors
  Future<VideoPrediction> predictPerformance({
    required String videoTitle,
    required String category,
    required List<String> tags,
    required Duration videoDuration,
    required PredictionTimeframe timeframe,
    List<VideoData>? historicalData,
  }) async {
    final factors = _analyzeFactors(
      title: videoTitle,
      category: category,
      tags: tags,
      duration: videoDuration,
      historicalData: historicalData,
    );

    final baseViews = _calculateBaseViews(factors, historicalData);
    final timeframeMultiplier = _getTimeframeMultiplier(timeframe);
    final predictedViews = (baseViews * timeframeMultiplier).round();
    
    final predictedLikes = (predictedViews * _calculateLikeRate(factors)).round();
    final predictedComments = (predictedViews * _calculateCommentRate(factors)).round();
    
    final viralityScore = _calculateViralityScore(factors);
    final successProbability = _calculateSuccessProbability(factors, viralityScore);
    
    final recommendations = _generateRecommendations(factors, viralityScore);

    return VideoPrediction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoTitle: videoTitle,
      category: category,
      tags: tags,
      predictedViews: predictedViews,
      predictedLikes: predictedLikes,
      predictedComments: predictedComments,
      viralityScore: viralityScore,
      successProbability: successProbability,
      predictionDate: DateTime.now(),
      factors: factors,
      recommendations: recommendations,
      timeframe: timeframe,
    );
  }

  Map<String, dynamic> _analyzeFactors({
    required String title,
    required String category,
    required List<String> tags,
    required Duration duration,
    List<VideoData>? historicalData,
  }) {
    return {
      'titleScore': _analyzeTitleQuality(title),
      'categoryPopularity': _getCategoryPopularity(category),
      'tagRelevance': _analyzeTagRelevance(tags),
      'durationOptimality': _analyzeDurationOptimality(duration),
      'historicalPerformance': _analyzeHistoricalPerformance(historicalData),
      'trendAlignment': _analyzeTrendAlignment(tags, category),
      'seasonalFactor': _getSeasonalFactor(),
      'competitionLevel': _estimateCompetition(category, tags),
    };
  }

  double _analyzeTitleQuality(String title) {
    double score = 50.0;
    
    final length = title.length;
    if (length >= 50 && length <= 70) {
      score += 25;
    } else if (length >= 40 && length <= 80) {
      score += 15;
    }
    
    // Numbers boost click-through rate
    if (title.contains(RegExp(r'\d+'))) score += 10;
    
    // Questions engage curiosity
    if (title.contains('?')) score += 10;
    
    // Power words
    final powerWords = ['ultimate', 'complete', 'guide', 'tutorial', 'secret', 
                        'amazing', 'incredible', 'best', 'top', 'new', 'pro'];
    final lowerTitle = title.toLowerCase();
    final powerWordCount = powerWords.where((word) => lowerTitle.contains(word)).length;
    score += min(15, powerWordCount * 5);
    
    // Proper capitalization
    if (!title.contains(RegExp(r'[A-Z]{5,}'))) score += 5;
    
    // Emojis can boost CTR (but don't overdo it)
    final emojiCount = title.runes.where((rune) => rune > 0x1F000).length;
    if (emojiCount >= 1 && emojiCount <= 3) score += 5;
    
    return min(100, score);
  }

  double _getCategoryPopularity(String category) {
    // Category popularity index (0-100)
    final popularCategories = {
      'Gaming': 95.0,
      'Entertainment': 90.0,
      'Music': 85.0,
      'Comedy': 80.0,
      'Education': 75.0,
      'Technology': 70.0,
      'Sports': 70.0,
      'Food': 65.0,
      'Travel': 60.0,
      'News': 55.0,
    };
    
    return popularCategories[category] ?? 50.0;
  }

  double _analyzeTagRelevance(List<String> tags) {
    if (tags.isEmpty) return 20.0;
    if (tags.length < 3) return 40.0;
    
    double score = 60.0;
    
    // Optimal tag count: 5-15
    if (tags.length >= 5 && tags.length <= 15) {
      score += 20;
    } else if (tags.length >= 3 && tags.length <= 20) {
      score += 10;
    }
    
    // Longer, specific tags are better
    final avgTagLength = tags.map((t) => t.length).reduce((a, b) => a + b) / tags.length;
    if (avgTagLength > 10) {
      score += 15;
    } else if (avgTagLength > 5) {
      score += 10;
    }
    
    // Check for trending keywords
    final trendingKeywords = ['ai', 'tutorial', '2024', '2025', 'guide', 'tips', 'hacks'];
    final hasTrending = tags.any((tag) => 
      trendingKeywords.any((keyword) => tag.toLowerCase().contains(keyword))
    );
    if (hasTrending) score += 5;
    
    return min(100, score);
  }

  double _analyzeDurationOptimality(Duration duration) {
    final minutes = duration.inMinutes;
    
    // Optimal duration: 8-15 minutes
    if (minutes >= 8 && minutes <= 15) return 90.0;
    if (minutes >= 6 && minutes <= 20) return 75.0;
    if (minutes >= 3 && minutes <= 25) return 60.0;
    if (minutes < 3) return 40.0; // Too short
    if (minutes > 30) return 50.0; // Very long
    
    return 55.0;
  }

  double _analyzeHistoricalPerformance(List<VideoData>? historicalData) {
    if (historicalData == null || historicalData.isEmpty) return 50.0;
    
    final avgViews = historicalData
        .map((v) => v.viewCount)
        .reduce((a, b) => a + b) / historicalData.length;
    
    final avgEngagement = historicalData
        .map((v) => v.engagementRate)
        .reduce((a, b) => a + b) / historicalData.length;
    
    double score = 50.0;
    
    // High historical views
    if (avgViews > 100000) {
      score += 30;
    } else if (avgViews > 50000) {
      score += 25;
    } else if (avgViews > 10000) {
      score += 20;
    } else if (avgViews > 1000) {
      score += 10;
    }
    
    // High engagement
    if (avgEngagement > 5.0) {
      score += 20;
    } else if (avgEngagement > 3.0) {
      score += 15;
    } else if (avgEngagement > 1.0) {
      score += 10;
    }
    
    return min(100, score);
  }

  double _analyzeTrendAlignment(List<String> tags, String category) {
    // Simulate trend analysis
    final trendingTopics = ['ai', 'chatgpt', 'tutorial', 'guide', '2025', 'tips', 'hacks'];
    
    final lowerTags = tags.map((t) => t.toLowerCase()).toList();
    final trendingCount = trendingTopics.where((topic) => 
      lowerTags.any((tag) => tag.contains(topic))
    ).length;
    
    return min(100, 50 + (trendingCount * 10));
  }

  double _getSeasonalFactor() {
    final now = DateTime.now();
    final month = now.month;
    
    // Seasonal boost factors
    // Jan: New Year content, Dec: Holiday content
    if (month == 1 || month == 12) return 85.0;
    if (month >= 6 && month <= 8) return 90.0; // Summer
    return 75.0;
  }

  double _estimateCompetition(String category, List<String> tags) {
    // Lower competition = higher score
    final highCompetitionCategories = ['Gaming', 'Entertainment', 'Music'];
    
    double score = 60.0;
    
    if (!highCompetitionCategories.contains(category)) {
      score += 20;
    }
    
    // Niche tags reduce competition
    final hasNicheTags = tags.any((tag) => tag.length > 15);
    if (hasNicheTags) score += 20;
    
    return min(100, score);
  }

  int _calculateBaseViews(Map<String, dynamic> factors, List<VideoData>? historicalData) {
    double baseViews = 1000.0; // Minimum baseline
    
    // Historical performance is the strongest indicator
    if (historicalData != null && historicalData.isNotEmpty) {
      final avgHistorical = historicalData
          .map((v) => v.viewCount)
          .reduce((a, b) => a + b) / historicalData.length;
      baseViews = avgHistorical * 0.8; // Conservative estimate
    }
    
    // Apply all factors
    final titleMultiplier = factors['titleScore'] / 100;
    final categoryMultiplier = factors['categoryPopularity'] / 100;
    final tagMultiplier = factors['tagRelevance'] / 100;
    final durationMultiplier = factors['durationOptimality'] / 100;
    final trendMultiplier = factors['trendAlignment'] / 100;
    final seasonalMultiplier = factors['seasonalFactor'] / 100;
    final competitionMultiplier = factors['competitionLevel'] / 100;
    
    final totalMultiplier = (titleMultiplier * 1.3 +
        categoryMultiplier * 1.2 +
        tagMultiplier * 1.1 +
        durationMultiplier * 0.9 +
        trendMultiplier * 1.4 +
        seasonalMultiplier * 0.8 +
        competitionMultiplier * 1.0) / 7;
    
    return (baseViews * totalMultiplier * (0.8 + Random().nextDouble() * 0.4)).round();
  }

  double _getTimeframeMultiplier(PredictionTimeframe timeframe) {
    switch (timeframe) {
      case PredictionTimeframe.day:
        return 0.15;
      case PredictionTimeframe.week:
        return 0.4;
      case PredictionTimeframe.month:
        return 1.0;
      case PredictionTimeframe.quarter:
        return 2.5;
      case PredictionTimeframe.year:
        return 5.0;
    }
  }

  double _calculateLikeRate(Map<String, dynamic> factors) {
    // Typical like rate: 2-5% of views
    final qualityScore = (factors['titleScore'] + factors['tagRelevance']) / 200;
    return 0.02 + (qualityScore * 0.03);
  }

  double _calculateCommentRate(Map<String, dynamic> factors) {
    // Typical comment rate: 0.1-0.5% of views
    final engagementScore = factors['titleScore'] / 100;
    return 0.001 + (engagementScore * 0.004);
  }

  double _calculateViralityScore(Map<String, dynamic> factors) {
    final weights = {
      'titleScore': 0.2,
      'trendAlignment': 0.3,
      'categoryPopularity': 0.2,
      'tagRelevance': 0.15,
      'competitionLevel': 0.15,
    };
    
    double score = 0;
    weights.forEach((key, weight) {
      score += (factors[key] ?? 50.0) * weight;
    });
    
    // Add viral boost for exceptional combinations
    if (factors['titleScore'] > 80 && factors['trendAlignment'] > 80) {
      score += 15;
    }
    
    return min(100, score);
  }

  double _calculateSuccessProbability(Map<String, dynamic> factors, double viralityScore) {
    final avgFactorScore = factors.values
        .where((v) => v is double)
        .cast<double>()
        .reduce((a, b) => a + b) / factors.length;
    
    final combinedScore = (avgFactorScore * 0.7 + viralityScore * 0.3);
    
    return min(1.0, combinedScore / 100);
  }

  List<String> _generateRecommendations(Map<String, dynamic> factors, double viralityScore) {
    final recommendations = <String>[];
    
    if (factors['titleScore'] < 70) {
      recommendations.add('🎯 Optimize your title: Add numbers, questions, or power words');
    }
    
    if (factors['tagRelevance'] < 60) {
      recommendations.add('🏷️ Improve tags: Use 5-15 relevant, specific tags');
    }
    
    if (factors['durationOptimality'] < 70) {
      recommendations.add('⏱️ Consider 8-15 minute duration for optimal performance');
    }
    
    if (factors['trendAlignment'] < 60) {
      recommendations.add('📈 Align with current trends: Research trending topics in your niche');
    }
    
    if (viralityScore > 70) {
      recommendations.add('🔥 High viral potential! Consider boosting with ads');
    }
    
    if (factors['competitionLevel'] < 50) {
      recommendations.add('⚔️ High competition detected: Focus on niche differentiation');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('✅ Great setup! Your video has strong potential');
    }
    
    return recommendations;
  }

  /// Analyze best posting times based on historical data
  Map<String, dynamic> analyzeBestPostingTimes(List<VideoData> historicalData) {
    if (historicalData.isEmpty) {
      return {
        'bestDay': 'Tuesday',
        'bestHour': 14,
        'bestTimeDescription': '2:00 PM on Tuesday',
      };
    }
    
    // Analyze publishing patterns
    final dayPerformance = <int, double>{};
    final hourPerformance = <int, double>{};
    
    for (var video in historicalData) {
      final day = video.publishedAt.weekday;
      final hour = video.publishedAt.hour;
      
      dayPerformance[day] = (dayPerformance[day] ?? 0) + video.viewCount.toDouble();
      hourPerformance[hour] = (hourPerformance[hour] ?? 0) + video.viewCount.toDouble();
    }
    
    final bestDay = dayPerformance.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    final bestHour = hourPerformance.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return {
      'bestDay': dayNames[bestDay - 1],
      'bestHour': bestHour,
      'bestTimeDescription': '$bestHour:00 on ${dayNames[bestDay - 1]}',
    };
  }
}

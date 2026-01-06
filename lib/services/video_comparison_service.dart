import 'dart:math';
import '../models/video_data.dart';
import '../models/video_comparison.dart';

/// Video Comparison Service for AI YouTube Boost v2.0
/// Provides AI-powered video comparison and analysis
class VideoComparisonService {
  /// Compare multiple videos and generate insights
  Future<VideoComparison> compareVideos(List<VideoData> videos) async {
    if (videos.isEmpty) {
      throw Exception('No videos to compare');
    }

    final metrics = <String, ComparisonMetrics>{};
    
    for (var video in videos) {
      metrics[video.id] = await _analyzeVideoMetrics(video, videos);
    }

    final recommendation = _generateRecommendation(videos, metrics);
    final confidence = _calculateConfidence(videos, metrics);

    return VideoComparison(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoIds: videos.map((v) => v.id).toList(),
      comparisonDate: DateTime.now(),
      metrics: metrics,
      recommendation: recommendation,
      confidenceScore: confidence,
    );
  }

  /// Analyze individual video metrics
  Future<ComparisonMetrics> _analyzeVideoMetrics(
    VideoData video,
    List<VideoData> allVideos,
  ) async {
    final viewsScore = _calculateViewsScore(video, allVideos);
    final engagementScore = _calculateEngagementScore(video, allVideos);
    final retentionScore = _calculateRetentionScore(video);
    final thumbnailScore = _calculateThumbnailScore(video);
    final titleScore = _calculateTitleScore(video);

    final overallScore = (viewsScore * 0.25) +
        (engagementScore * 0.3) +
        (retentionScore * 0.2) +
        (thumbnailScore * 0.15) +
        (titleScore * 0.1);

    return ComparisonMetrics(
      videoId: video.id,
      viewsScore: viewsScore,
      engagementScore: engagementScore,
      retentionScore: retentionScore,
      thumbnailScore: thumbnailScore,
      titleScore: titleScore,
      overallScore: overallScore,
      detailedMetrics: {
        'views': video.viewCount,
        'likes': video.likeCount,
        'comments': video.commentCount,
        'likeToViewRatio': video.viewCount > 0 ? video.likeCount / video.viewCount : 0,
        'commentToViewRatio': video.viewCount > 0 ? video.commentCount / video.viewCount : 0,
        'avgViewsPerDay': _calculateAvgViewsPerDay(video),
        'viralityIndex': _calculateViralityIndex(video),
      },
    );
  }

  double _calculateViewsScore(VideoData video, List<VideoData> allVideos) {
    final maxViews = allVideos.map((v) => v.viewCount).reduce(max);
    if (maxViews == 0) return 0;
    
    final normalizedViews = (video.viewCount / maxViews) * 100;
    
    // Consider recency - newer videos with good views get bonus
    final daysSincePublish = DateTime.now().difference(video.publishedAt).inDays;
    final recencyBonus = daysSincePublish < 7 ? 10 : (daysSincePublish < 30 ? 5 : 0);
    
    return min(100, normalizedViews + recencyBonus);
  }

  double _calculateEngagementScore(VideoData video, List<VideoData> allVideos) {
    final engagementRates = allVideos.map((v) => v.engagementRate).toList();
    final maxEngagement = engagementRates.reduce(max);
    
    if (maxEngagement == 0) return 0;
    
    final normalizedEngagement = (video.engagementRate / maxEngagement) * 100;
    
    // Bonus for high absolute engagement numbers
    final likesBonus = video.likeCount > 1000 ? 5 : 0;
    final commentsBonus = video.commentCount > 100 ? 5 : 0;
    
    return min(100, normalizedEngagement + likesBonus + commentsBonus);
  }

  double _calculateRetentionScore(VideoData video) {
    // Estimate retention based on duration and engagement
    // Shorter videos with high engagement typically have better retention
    final durationMinutes = video.duration.inMinutes;
    
    double baseScore = 70.0;
    
    // Optimal duration is 8-15 minutes
    if (durationMinutes >= 8 && durationMinutes <= 15) {
      baseScore += 15;
    } else if (durationMinutes < 8) {
      baseScore += 10; // Short videos can be good too
    } else if (durationMinutes > 20) {
      baseScore -= 10; // Long videos typically have lower retention
    }
    
    // High engagement suggests good retention
    if (video.engagementRate > 5.0) {
      baseScore += 15;
    } else if (video.engagementRate > 2.0) {
      baseScore += 10;
    }
    
    return min(100, max(0, baseScore));
  }

  double _calculateThumbnailScore(VideoData video) {
    // Analyze thumbnail effectiveness based on performance
    double score = 60.0; // Base score
    
    // High CTR indicators
    final viewsPerDay = _calculateAvgViewsPerDay(video);
    
    if (viewsPerDay > 10000) {
      score += 20;
    } else if (viewsPerDay > 5000) {
      score += 15;
    } else if (viewsPerDay > 1000) {
      score += 10;
    }
    
    // Good engagement suggests attractive thumbnail
    if (video.engagementRate > 3.0) {
      score += 10;
    }
    
    // Trending videos likely have good thumbnails
    if (video.trendingScore > 1000) {
      score += 10;
    }
    
    return min(100, score);
  }

  double _calculateTitleScore(VideoData video) {
    double score = 50.0;
    
    final titleLength = video.title.length;
    
    // Optimal title length: 50-70 characters
    if (titleLength >= 50 && titleLength <= 70) {
      score += 20;
    } else if (titleLength >= 40 && titleLength <= 80) {
      score += 15;
    } else if (titleLength < 30) {
      score += 5; // Too short
    }
    
    // Check for capitalization (ALL CAPS is bad, Title Case is good)
    final hasProperCase = video.title.split(' ').any((word) => 
      word.isNotEmpty && word[0] == word[0].toUpperCase() && 
      word.substring(1).contains(RegExp(r'[a-z]'))
    );
    if (hasProperCase) score += 10;
    
    // Numbers in title often perform well
    if (video.title.contains(RegExp(r'\d+'))) {
      score += 10;
    }
    
    // Question titles often perform well
    if (video.title.contains('?')) {
      score += 5;
    }
    
    // Power words detection
    final powerWords = ['ultimate', 'best', 'top', 'amazing', 'secret', 'pro', 'expert', 'how to'];
    final lowerTitle = video.title.toLowerCase();
    if (powerWords.any((word) => lowerTitle.contains(word))) {
      score += 5;
    }
    
    return min(100, score);
  }

  double _calculateAvgViewsPerDay(VideoData video) {
    final daysSincePublish = DateTime.now().difference(video.publishedAt).inDays;
    if (daysSincePublish == 0) return video.viewCount.toDouble();
    return video.viewCount / daysSincePublish;
  }

  double _calculateViralityIndex(VideoData video) {
    final viewsPerDay = _calculateAvgViewsPerDay(video);
    final engagementMultiplier = 1 + (video.engagementRate / 100);
    return viewsPerDay * engagementMultiplier;
  }

  String _generateRecommendation(
    List<VideoData> videos,
    Map<String, ComparisonMetrics> metrics,
  ) {
    if (metrics.isEmpty) return 'Unable to generate recommendation';

    final winner = metrics.entries
        .reduce((a, b) => a.value.overallScore > b.value.overallScore ? a : b);
    
    final winnerVideo = videos.firstWhere((v) => v.id == winner.key);
    final winnerMetrics = winner.value;

    final recommendations = <String>[];

    recommendations.add(
      '🏆 "${winnerVideo.title}" is the top performer with an overall score of ${winnerMetrics.overallScore.toStringAsFixed(1)}',
    );

    // Analyze what makes it successful
    if (winnerMetrics.engagementScore > 80) {
      recommendations.add('✨ Excellent engagement rate (${winnerVideo.engagementRate.toStringAsFixed(2)}%)');
    }
    
    if (winnerMetrics.viewsScore > 80) {
      recommendations.add('👀 Outstanding view count (${winnerVideo.formattedViews})');
    }
    
    if (winnerMetrics.titleScore > 80) {
      recommendations.add('📝 Effective title optimization');
    }

    // Provide improvement suggestions for others
    final lowestScorer = metrics.entries
        .reduce((a, b) => a.value.overallScore < b.value.overallScore ? a : b);
    
    if (lowestScorer.value.titleScore < 60) {
      recommendations.add('💡 Consider optimizing video titles for better performance');
    }
    
    if (lowestScorer.value.engagementScore < 50) {
      recommendations.add('💡 Focus on improving audience engagement through CTAs');
    }

    return recommendations.join('\n');
  }

  double _calculateConfidence(
    List<VideoData> videos,
    Map<String, ComparisonMetrics> metrics,
  ) {
    if (videos.length < 2) return 0.5;

    // Higher confidence with more videos and larger differences
    final scores = metrics.values.map((m) => m.overallScore).toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores.map((s) => pow(s - avgScore, 2)).reduce((a, b) => a + b) / scores.length;
    
    // More variance = clearer winner = higher confidence
    final varianceScore = min(1.0, variance / 500);
    
    // More videos = better analysis
    final sampleSizeScore = min(1.0, videos.length / 10);
    
    return (varianceScore * 0.7 + sampleSizeScore * 0.3);
  }

  /// Get comparison insights
  String getComparisonInsights(VideoComparison comparison, List<VideoData> videos) {
    final winner = comparison.getWinner();
    final winnerVideo = videos.firstWhere((v) => v.id == winner);
    
    return 'Based on ${videos.length} videos analyzed, "${winnerVideo.title}" '
           'demonstrates superior performance with ${comparison.confidenceScore.toStringAsFixed(0)}% confidence.';
  }

  /// Calculate improvement potential
  Map<String, double> calculateImprovementPotential(
    VideoData video,
    ComparisonMetrics metrics,
  ) {
    return {
      'views': max(0, 100 - metrics.viewsScore),
      'engagement': max(0, 100 - metrics.engagementScore),
      'retention': max(0, 100 - metrics.retentionScore),
      'thumbnail': max(0, 100 - metrics.thumbnailScore),
      'title': max(0, 100 - metrics.titleScore),
    };
  }
}

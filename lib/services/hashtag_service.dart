import 'dart:math';
import '../models/hashtag_analysis.dart';
import '../models/video_data.dart';

/// Hashtag Generation and Analysis Service for AI YouTube Boost v2.0
/// Generates optimal hashtags and analyzes their effectiveness
class HashtagService {
  final Random _random = Random();

  /// Generate hashtag analysis for a video
  Future<HashtagAnalysis> generateHashtagAnalysis({
    required String videoTitle,
    required String category,
    String? description,
    List<VideoData>? similarVideos,
  }) async {
    final generatedHashtags = await _generateHashtags(videoTitle, category, description);
    final trendingHashtags = await _getTrendingHashtags(category);
    final categoryRelevance = _calculateCategoryRelevance(videoTitle, category);
    final overallScore = _calculateOverallScore(generatedHashtags, trendingHashtags);
    final recommendations = _generateRecommendations(generatedHashtags, trendingHashtags, overallScore);

    return HashtagAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoTitle: videoTitle,
      category: category,
      generatedHashtags: generatedHashtags,
      trendingHashtags: trendingHashtags,
      categoryRelevance: categoryRelevance,
      analysisDate: DateTime.now(),
      overallScore: overallScore,
      recommendations: recommendations,
    );
  }

  Future<List<HashtagItem>> _generateHashtags(String title, String category, String? description) async {
    final hashtags = <HashtagItem>[];
    
    // Extract keywords from title
    final titleWords = title.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((w) => w.length > 3)
        .toList();

    // Generate hashtags from title
    for (var word in titleWords.take(5)) {
      hashtags.add(_createHashtagItem(
        word,
        category,
        score: 75 + _random.nextDouble() * 20,
        searchVolume: 50000 + _random.nextInt(200000),
        competition: 0.3 + _random.nextDouble() * 0.4,
        trend: _random.nextBool() ? HashtagTrend.rising : HashtagTrend.stable,
      ));
    }

    // Add category-based hashtags
    final categoryTags = _getCategoryHashtags(category);
    for (var tag in categoryTags) {
      hashtags.add(tag);
    }

    // Add combination hashtags
    if (titleWords.length >= 2) {
      final combo = titleWords.take(2).join('');
      hashtags.add(_createHashtagItem(
        combo,
        category,
        score: 80 + _random.nextDouble() * 15,
        searchVolume: 30000 + _random.nextInt(100000),
        competition: 0.4 + _random.nextDouble() * 0.3,
        trend: HashtagTrend.rising,
      ));
    }

    return hashtags;
  }

  Future<List<HashtagItem>> _getTrendingHashtags(String category) async {
    final trendingTags = <String, Map<String, dynamic>>{
      'viral': {'volume': 500000, 'competition': 0.9, 'trend': HashtagTrend.viral},
      'trending': {'volume': 450000, 'competition': 0.85, 'trend': HashtagTrend.viral},
      'fyp': {'volume': 800000, 'competition': 0.95, 'trend': HashtagTrend.viral},
      'explore': {'volume': 600000, 'competition': 0.9, 'trend': HashtagTrend.rising},
      '2025': {'volume': 350000, 'competition': 0.7, 'trend': HashtagTrend.rising},
    };

    return trendingTags.entries.map((entry) {
      final data = entry.value;
      return _createHashtagItem(
        entry.key,
        category,
        score: 85 + _random.nextDouble() * 10,
        searchVolume: data['volume'],
        competition: data['competition'],
        trend: data['trend'],
        isRecommended: true,
      );
    }).toList();
  }

  HashtagItem _createHashtagItem(
    String tag,
    String category, {
    required double score,
    required int searchVolume,
    required double competition,
    required HashtagTrend trend,
    bool isRecommended = false,
  }) {
    return HashtagItem(
      tag: tag,
      score: score,
      searchVolume: searchVolume,
      competitionLevel: competition,
      trend: trend,
      category: category,
      isRecommended: isRecommended,
    );
  }

  List<HashtagItem> _getCategoryHashtags(String category) {
    final categoryMap = {
      'Gaming': ['gaming', 'gameplay', 'gamer', 'gamingcommunity', 'pcgaming'],
      'Entertainment': ['entertainment', 'funny', 'comedy', 'viral', 'trending'],
      'Music': ['music', 'newmusic', 'musicvideo', 'musician', 'song'],
      'Education': ['education', 'learning', 'tutorial', 'howto', 'educational'],
      'Technology': ['tech', 'technology', 'innovation', 'gadgets', 'review'],
      'Sports': ['sports', 'fitness', 'athlete', 'training', 'workout'],
      'Food': ['food', 'cooking', 'recipe', 'foodie', 'chef'],
      'Travel': ['travel', 'adventure', 'explore', 'wanderlust', 'vacation'],
    };

    final tags = categoryMap[category] ?? ['youtube', 'content', 'creator'];
    
    return tags.map((tag) => _createHashtagItem(
      tag,
      category,
      score: 70 + _random.nextDouble() * 25,
      searchVolume: 100000 + _random.nextInt(300000),
      competition: 0.5 + _random.nextDouble() * 0.3,
      trend: HashtagTrend.stable,
      isRecommended: true,
    )).toList();
  }

  Map<String, double> _calculateCategoryRelevance(String title, String category) {
    return {
      category: 0.9 + _random.nextDouble() * 0.1,
      'General': 0.6 + _random.nextDouble() * 0.2,
      'Trending': 0.7 + _random.nextDouble() * 0.2,
    };
  }

  double _calculateOverallScore(List<HashtagItem> generated, List<HashtagItem> trending) {
    if (generated.isEmpty && trending.isEmpty) return 0;
    
    final allHashtags = [...generated, ...trending];
    final avgScore = allHashtags.map((h) => h.score).reduce((a, b) => a + b) / allHashtags.length;
    
    // Bonus for having mix of low and high competition
    final hasLowComp = allHashtags.any((h) => h.competitionLevel < 0.4);
    final hasHighComp = allHashtags.any((h) => h.competitionLevel > 0.7);
    final diversityBonus = (hasLowComp && hasHighComp) ? 5.0 : 0.0;
    
    return (avgScore + diversityBonus).clamp(0, 100);
  }

  List<String> _generateRecommendations(
    List<HashtagItem> generated,
    List<HashtagItem> trending,
    double overallScore,
  ) {
    final recommendations = <String>[];

    if (overallScore >= 85) {
      recommendations.add('🎉 Excellent hashtag strategy! Your tags are well-optimized');
    } else if (overallScore >= 70) {
      recommendations.add('👍 Good hashtag selection with room for improvement');
    } else {
      recommendations.add('💡 Consider optimizing your hashtag strategy');
    }

    final lowCompTags = generated.where((h) => h.competitionLevel < 0.3).length;
    if (lowCompTags < 3) {
      recommendations.add('🎯 Add more niche hashtags with low competition');
    }

    final trendingCount = generated.where((h) => h.trend == HashtagTrend.rising || h.trend == HashtagTrend.viral).length;
    if (trendingCount < 2) {
      recommendations.add('📈 Include trending hashtags to boost discoverability');
    }

    if (generated.length < 10) {
      recommendations.add('📝 Use 15-20 hashtags for maximum reach');
    }

    recommendations.add('💡 Mix popular and niche tags for best results');

    return recommendations;
  }

  /// Analyze existing hashtags
  Future<Map<String, dynamic>> analyzeExistingHashtags(List<String> hashtags) async {
    final analysis = <String, dynamic>{};
    final items = <HashtagItem>[];

    for (var tag in hashtags) {
      items.add(_createHashtagItem(
        tag.replaceAll('#', ''),
        'General',
        score: 60 + _random.nextDouble() * 30,
        searchVolume: 10000 + _random.nextInt(500000),
        competition: _random.nextDouble(),
        trend: HashtagTrend.values[_random.nextInt(HashtagTrend.values.length)],
      ));
    }

    final avgScore = items.map((i) => i.score).reduce((a, b) => a + b) / items.length;
    final avgCompetition = items.map((i) => i.competitionLevel).reduce((a, b) => a + b) / items.length;

    analysis['items'] = items;
    analysis['averageScore'] = avgScore;
    analysis['averageCompetition'] = avgCompetition;
    analysis['trending'] = items.where((i) => i.trend == HashtagTrend.viral).length;
    analysis['recommendations'] = _generateRecommendations(items, [], avgScore);

    return analysis;
  }

  /// Get hashtag suggestions based on search query
  Future<List<String>> getHashtagSuggestions(String query) async {
    final base = query.toLowerCase().replaceAll(' ', '');
    return [
      base,
      '${base}2025',
      '${base}tips',
      '${base}tutorial',
      '${base}guide',
      'best$base',
      '${base}hacks',
      '${base}ideas',
    ];
  }
}

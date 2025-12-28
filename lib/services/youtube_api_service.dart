import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_data.dart';
import '../models/niche_data.dart';
import '../models/trending_topic.dart';

class YouTubeApiService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  String? _apiKey;
  
  final Map<String, String> _categoryMap = {
    '1': 'Film & Animation',
    '2': 'Autos & Vehicles',
    '10': 'Music',
    '15': 'Pets & Animals',
    '17': 'Sports',
    '18': 'Short Movies',
    '19': 'Travel & Events',
    '20': 'Gaming',
    '21': 'Videoblogging',
    '22': 'People & Blogs',
    '23': 'Comedy',
    '24': 'Entertainment',
    '25': 'News & Politics',
    '26': 'Howto & Style',
    '27': 'Education',
    '28': 'Science & Technology',
    '29': 'Nonprofits & Activism',
    '30': 'Movies',
    '31': 'Anime/Animation',
    '32': 'Action/Adventure',
    '33': 'Classics',
    '34': 'Comedy',
    '35': 'Documentary',
    '36': 'Drama',
    '37': 'Family',
    '38': 'Foreign',
    '39': 'Horror',
    '40': 'Sci-Fi/Fantasy',
    '41': 'Thriller',
    '42': 'Shorts',
    '43': 'Shows',
    '44': 'Trailers',
  };

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<List<VideoData>> searchVideos({
    required String query,
    int maxResults = 50,
    String order = 'relevance',
    DateTime? publishedAfter,
    String? regionCode,
  }) async {
    if (!hasApiKey) {
      throw Exception('YouTube API key not set');
    }

    try {
      final queryParams = {
        'part': 'snippet',
        'q': query,
        'maxResults': maxResults.toString(),
        'order': order,
        'type': 'video',
        'key': _apiKey!,
        if (publishedAfter != null) 'publishedAfter': publishedAfter.toIso8601String(),
        if (regionCode != null) 'regionCode': regionCode,
      };

      final searchUri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);
      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode != 200) {
        throw Exception('Failed to search videos: ${searchResponse.statusCode}');
      }

      final searchData = json.decode(searchResponse.body);
      final items = searchData['items'] as List;

      if (items.isEmpty) {
        return [];
      }

      final videoIds = items.map((item) => item['id']['videoId']).join(',');
      
      final detailsParams = {
        'part': 'snippet,statistics,contentDetails',
        'id': videoIds,
        'key': _apiKey!,
      };

      final detailsUri = Uri.parse('$_baseUrl/videos').replace(queryParameters: detailsParams);
      final detailsResponse = await http.get(detailsUri);

      if (detailsResponse.statusCode != 200) {
        throw Exception('Failed to get video details: ${detailsResponse.statusCode}');
      }

      final detailsData = json.decode(detailsResponse.body);
      final videoItems = detailsData['items'] as List;

      return videoItems.map((item) => VideoData.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error searching videos: $e');
    }
  }

  Future<List<VideoData>> getTrendingVideos({
    String regionCode = 'US',
    String? categoryId,
    int maxResults = 50,
  }) async {
    if (!hasApiKey) {
      throw Exception('YouTube API key not set');
    }

    try {
      final queryParams = {
        'part': 'snippet,statistics,contentDetails',
        'chart': 'mostPopular',
        'regionCode': regionCode,
        'maxResults': maxResults.toString(),
        'key': _apiKey!,
        if (categoryId != null) 'videoCategoryId': categoryId,
      };

      final uri = Uri.parse('$_baseUrl/videos').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to get trending videos: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;

      return items.map((item) => VideoData.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error getting trending videos: $e');
    }
  }

  Future<NicheData> analyzeNiche({
    required String niche,
    String? categoryId,
    int sampleSize = 100,
  }) async {
    if (!hasApiKey) {
      throw Exception('YouTube API key not set');
    }

    try {
      final videos = await searchVideos(
        query: niche,
        maxResults: sampleSize,
        order: 'viewCount',
        publishedAfter: DateTime.now().subtract(const Duration(days: 30)),
      );

      if (videos.isEmpty) {
        throw Exception('No videos found for niche: $niche');
      }

      final totalViews = videos.fold<int>(0, (sum, video) => sum + video.viewCount);
      final avgViews = totalViews ~/ videos.length;
      final avgEngagement = videos.fold<double>(
        0.0,
        (sum, video) => sum + video.engagementRate,
      ) / videos.length;

      final allTags = <String, int>{};
      for (var video in videos) {
        for (var tag in video.tags) {
          allTags[tag.toLowerCase()] = (allTags[tag.toLowerCase()] ?? 0) + 1;
        }
      }

      final topKeywords = allTags.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      final viewDistribution = <String, int>{
        '0-1K': 0,
        '1K-10K': 0,
        '10K-100K': 0,
        '100K-1M': 0,
        '1M+': 0,
      };

      for (var video in videos) {
        if (video.viewCount < 1000) {
          viewDistribution['0-1K'] = viewDistribution['0-1K']! + 1;
        } else if (video.viewCount < 10000) {
          viewDistribution['1K-10K'] = viewDistribution['1K-10K']! + 1;
        } else if (video.viewCount < 100000) {
          viewDistribution['10K-100K'] = viewDistribution['10K-100K']! + 1;
        } else if (video.viewCount < 1000000) {
          viewDistribution['100K-1M'] = viewDistribution['100K-1M']! + 1;
        } else {
          viewDistribution['1M+'] = viewDistribution['1M+']! + 1;
        }
      }

      final recentVideos = videos.where((v) => 
        DateTime.now().difference(v.publishedAt).inDays <= 7
      ).toList();
      
      final olderVideos = videos.where((v) => 
        DateTime.now().difference(v.publishedAt).inDays > 7 &&
        DateTime.now().difference(v.publishedAt).inDays <= 30
      ).toList();

      final recentAvg = recentVideos.isEmpty ? 0 : 
        recentVideos.fold<int>(0, (sum, v) => sum + v.viewCount) / recentVideos.length;
      final olderAvg = olderVideos.isEmpty ? 0 :
        olderVideos.fold<int>(0, (sum, v) => sum + v.viewCount) / olderVideos.length;

      final growthRate = olderAvg > 0 ? ((recentAvg - olderAvg) / olderAvg * 100) : 0.0;

      return NicheData(
        name: niche,
        categoryId: categoryId ?? '0',
        totalVideos: videos.length,
        totalViews: totalViews,
        avgViews: avgViews,
        avgEngagementRate: avgEngagement,
        growthRate: growthRate,
        topKeywords: topKeywords.take(10).map((e) => e.key).toList(),
        risingKeywords: topKeywords.skip(10).take(5).map((e) => e.key).toList(),
        viewDistribution: viewDistribution,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error analyzing niche: $e');
    }
  }

  Future<List<TrendingTopic>> getTrendingTopics({
    String? categoryId,
    int limit = 20,
  }) async {
    if (!hasApiKey) {
      throw Exception('YouTube API key not set');
    }

    try {
      final videos = await getTrendingVideos(
        categoryId: categoryId,
        maxResults: 50,
      );

      final keywordFrequency = <String, List<VideoData>>{};
      
      for (var video in videos) {
        final words = _extractKeywords(video.title + ' ' + video.description);
        for (var word in words) {
          if (!keywordFrequency.containsKey(word)) {
            keywordFrequency[word] = [];
          }
          keywordFrequency[word]!.add(video);
        }
      }

      final topics = <TrendingTopic>[];
      
      for (var entry in keywordFrequency.entries) {
        if (entry.value.length < 3) continue;
        
        final relatedVideos = entry.value;
        final totalViews = relatedVideos.fold<int>(0, (sum, v) => sum + v.viewCount);
        final avgViews = totalViews ~/ relatedVideos.length;
        
        final recentVideos = relatedVideos.where((v) =>
          DateTime.now().difference(v.publishedAt).inDays <= 7
        ).length;
        
        final growthRate = (recentVideos / relatedVideos.length) * 100;
        
        final avgEngagement = relatedVideos.fold<double>(
          0.0,
          (sum, v) => sum + v.engagementRate,
        ) / relatedVideos.length;
        
        final competitionLevel = relatedVideos.length / 50.0;
        
        final viralityScore = (avgViews / 10000.0) * 0.4 +
                             avgEngagement * 0.3 +
                             growthRate * 0.3;
        
        final relatedKeywords = _findRelatedKeywords(entry.key, keywordFrequency.keys.toList());
        
        topics.add(TrendingTopic(
          keyword: entry.key,
          searchVolume: avgViews,
          growthRate: growthRate,
          videoCount: relatedVideos.length,
          competitionLevel: competitionLevel.clamp(0.0, 1.0),
          relatedKeywords: relatedKeywords,
          trendingStartDate: relatedVideos
              .map((v) => v.publishedAt)
              .reduce((a, b) => a.isBefore(b) ? a : b),
          category: categoryId != null ? _categoryMap[categoryId] ?? 'General' : 'General',
          viralityScore: viralityScore.clamp(0.0, 100.0),
        ));
      }

      topics.sort((a, b) => b.viralityScore.compareTo(a.viralityScore));
      
      return topics.take(limit).toList();
    } catch (e) {
      throw Exception('Error getting trending topics: $e');
    }
  }

  List<String> _extractKeywords(String text) {
    final words = text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 3)
        .toList();
    
    final stopWords = {
      'this', 'that', 'with', 'from', 'have', 'been', 'were', 'their',
      'what', 'when', 'where', 'which', 'while', 'about', 'after', 'before',
      'would', 'could', 'should', 'there', 'these', 'those', 'then', 'than',
    };
    
    return words.where((word) => !stopWords.contains(word)).toSet().toList();
  }

  List<String> _findRelatedKeywords(String keyword, List<String> allKeywords) {
    return allKeywords
        .where((k) => k != keyword && (k.contains(keyword) || keyword.contains(k)))
        .take(5)
        .toList();
  }

  Map<String, String> get categories => _categoryMap;

  Future<Map<String, dynamic>> getChannelStatistics(String channelId) async {
    if (!hasApiKey) {
      throw Exception('YouTube API key not set');
    }

    try {
      final queryParams = {
        'part': 'statistics,snippet,contentDetails,brandingSettings',
        'id': channelId,
        'key': _apiKey!,
      };

      final uri = Uri.parse('$_baseUrl/channels').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to get channel statistics: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;

      if (items.isEmpty) {
        throw Exception('Channel not found');
      }

      return items.first;
    } catch (e) {
      throw Exception('Error getting channel statistics: $e');
    }
  }

  Future<Map<String, dynamic>> searchChannelByName(String channelName) async {
    if (!hasApiKey) {
      throw Exception('YouTube API key not set');
    }

    try {
      final searchParams = {
        'part': 'snippet',
        'q': channelName,
        'type': 'channel',
        'maxResults': '1',
        'key': _apiKey!,
      };

      final searchUri = Uri.parse('$_baseUrl/search').replace(queryParameters: searchParams);
      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode != 200) {
        throw Exception('Failed to search channel: ${searchResponse.statusCode}');
      }

      final searchData = json.decode(searchResponse.body);
      final items = searchData['items'] as List;

      if (items.isEmpty) {
        throw Exception('Channel not found');
      }

      final channelId = items.first['snippet']['channelId'];
      return await getChannelStatistics(channelId);
    } catch (e) {
      throw Exception('Error searching channel: $e');
    }
  }
}

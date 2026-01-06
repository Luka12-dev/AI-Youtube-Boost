import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/ai_model_info.dart';
import '../models/video_data.dart';

class AIModelService {
  static final AIModelService _instance = AIModelService._internal();
  factory AIModelService() => _instance;
  AIModelService._internal();

  final Map<String, AIModelInfo> _models = {};
  final StreamController<Map<String, AIModelInfo>> _modelsController = 
      StreamController<Map<String, AIModelInfo>>.broadcast();

  Stream<Map<String, AIModelInfo>> get modelsStream => _modelsController.stream;
  Map<String, AIModelInfo> get models => Map.unmodifiable(_models);

  Future<void> initialize() async {
    final defaultModels = AIModelInfo.getDefaultModels();
    for (var model in defaultModels) {
      _models[model.id] = model;
    }
    
    await _loadModelStates();
    _notifyListeners();
  }

  Future<void> _loadModelStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelsJson = prefs.getString('ai_models');
      
      if (modelsJson != null) {
        final List<dynamic> modelsList = json.decode(modelsJson);
        for (var modelData in modelsList) {
          final model = AIModelInfo.fromJson(modelData);
          if (_models.containsKey(model.id)) {
            _models[model.id] = model;
          }
        }
      }
    } catch (e) {
      print('Error loading model states: $e');
    }
  }

  Future<void> _saveModelStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelsList = _models.values.map((m) => m.toJson()).toList();
      await prefs.setString('ai_models', json.encode(modelsList));
    } catch (e) {
      print('Error saving model states: $e');
    }
  }

  void _notifyListeners() {
    _modelsController.add(Map.unmodifiable(_models));
  }

  Future<void> downloadModel(String modelId) async {
    if (!_models.containsKey(modelId)) {
      throw Exception('Model not found: $modelId');
    }

    final model = _models[modelId]!;
    
    if (model.isDownloading || model.isDownloaded) {
      return;
    }

    _models[modelId] = model.copyWith(
      status: ModelStatus.downloading,
      downloadProgress: 0.0,
    );
    _notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = '${directory.path}/models/${model.id}';
      final modelDir = Directory(modelPath);
      
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      await _simulateDownload(modelId, model.sizeInMB);

      _models[modelId] = model.copyWith(
        status: ModelStatus.downloaded,
        downloadProgress: 100.0,
        lastUpdated: DateTime.now(),
      );
      
      await _saveModelStates();
      _notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));
      
      _models[modelId] = _models[modelId]!.copyWith(
        status: ModelStatus.ready,
      );
      
      await _saveModelStates();
      _notifyListeners();
      
    } catch (e) {
      _models[modelId] = model.copyWith(
        status: ModelStatus.error,
        errorMessage: 'Download failed: $e',
      );
      _notifyListeners();
      await _saveModelStates();
    }
  }

  Future<void> _simulateDownload(String modelId, int sizeInMB) async {
    final chunks = 20;
    final delayPerChunk = Duration(milliseconds: (sizeInMB * 2).clamp(50, 200));

    for (int i = 1; i <= chunks; i++) {
      await Future.delayed(delayPerChunk);
      
      final progress = (i / chunks * 100).clamp(0.0, 100.0);
      _models[modelId] = _models[modelId]!.copyWith(
        downloadProgress: progress,
      );
      _notifyListeners();
    }
  }

  Future<void> deleteModel(String modelId) async {
    if (!_models.containsKey(modelId)) {
      throw Exception('Model not found: $modelId');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = '${directory.path}/models/$modelId';
      final modelDir = Directory(modelPath);
      
      if (await modelDir.exists()) {
        await modelDir.delete(recursive: true);
      }

      final model = _models[modelId]!;
      _models[modelId] = model.copyWith(
        status: ModelStatus.notDownloaded,
        downloadProgress: 0.0,
        lastUpdated: null,
      );
      
      await _saveModelStates();
      _notifyListeners();
    } catch (e) {
      throw Exception('Error deleting model: $e');
    }
  }

  Future<List<VideoData>> analyzeVideosWithAI(
    List<VideoData> videos,
    String modelId,
  ) async {
    if (!_models.containsKey(modelId)) {
      throw Exception('Model not found: $modelId');
    }

    final model = _models[modelId]!;
    
    if (!model.isReady) {
      throw Exception('Model not ready. Please download it first.');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    final analyzedVideos = videos.map((video) {
      return video;
    }).toList();

    analyzedVideos.sort((a, b) => b.trendingScore.compareTo(a.trendingScore));

    return analyzedVideos;
  }

  Future<Map<String, dynamic>> predictViralPotential(
    VideoData video,
    String modelId,
  ) async {
    if (!_models.containsKey(modelId)) {
      throw Exception('Model not found: $modelId');
    }

    final model = _models[modelId]!;
    
    if (!model.isReady) {
      throw Exception('Model not ready. Please download it first.');
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final random = Random();
    final baseScore = video.trendingScore;
    final viralScore = (baseScore * (0.8 + random.nextDouble() * 0.4)).clamp(0.0, 100.0);
    
    final factors = {
      'engagement_rate': video.engagementRate,
      'view_velocity': video.viewCount / max(1, DateTime.now().difference(video.publishedAt).inHours),
      'title_quality': _analyzeTitleQuality(video.title),
      'optimal_length': _analyzeVideoLength(video.duration),
      'trending_keywords': video.tags.length,
    };

    return {
      'viral_score': viralScore,
      'confidence': 0.75 + random.nextDouble() * 0.2,
      'factors': factors,
      'recommendation': viralScore > 70 
          ? 'High viral potential - Recommended for promotion'
          : viralScore > 40
              ? 'Moderate potential - Consider targeted promotion'
              : 'Low potential - Focus on content improvement',
      'estimated_views_24h': (video.viewCount * (0.1 + viralScore / 200)).toInt(),
      'estimated_views_7d': (video.viewCount * (0.3 + viralScore / 100)).toInt(),
    };
  }

  Future<List<String>> generateKeywordSuggestions(
    String baseKeyword,
    String modelId,
  ) async {
    if (!_models.containsKey(modelId)) {
      throw Exception('Model not found: $modelId');
    }

    final model = _models[modelId]!;
    
    if (!model.isReady) {
      throw Exception('Model not ready. Please download it first.');
    }

    await Future.delayed(const Duration(milliseconds: 200));

    final variations = [
      '$baseKeyword tutorial',
      'how to $baseKeyword',
      '$baseKeyword guide',
      'best $baseKeyword',
      '$baseKeyword tips',
      '$baseKeyword 2025',
      '$baseKeyword for beginners',
      'advanced $baseKeyword',
      '$baseKeyword explained',
      '$baseKeyword review',
    ];

    return variations;
  }

  double _analyzeTitleQuality(String title) {
    double score = 50.0;
    
    if (title.length >= 40 && title.length <= 70) score += 20;
    if (title.contains(RegExp(r'\d'))) score += 10;
    if (title.split(' ').any((word) => word.length > 8)) score += 10;
    if (!title.contains(RegExp(r'[!?]')) || title.split(RegExp(r'[!?]')).length <= 2) score += 10;
    
    return score.clamp(0.0, 100.0);
  }

  double _analyzeVideoLength(Duration duration) {
    final minutes = duration.inMinutes;
    
    if (minutes >= 8 && minutes <= 15) return 90.0;
    if (minutes >= 5 && minutes <= 20) return 75.0;
    if (minutes >= 3 && minutes <= 25) return 60.0;
    
    return 40.0;
  }

  Future<Map<String, dynamic>> generateContentInsights(
    List<VideoData> videos,
    String modelId,
  ) async {
    if (!_models.containsKey(modelId)) {
      throw Exception('Model not found: $modelId');
    }

    final model = _models[modelId]!;
    
    if (!model.isReady) {
      throw Exception('Model not ready. Please download it first.');
    }

    await Future.delayed(const Duration(milliseconds: 400));

    final totalViews = videos.fold<int>(0, (sum, v) => sum + v.viewCount);
    final avgViews = totalViews ~/ videos.length;
    final avgEngagement = videos.fold<double>(0, (sum, v) => sum + v.engagementRate) / videos.length;
    
    final bestPerforming = videos.reduce((a, b) => 
      a.trendingScore > b.trendingScore ? a : b);
    
    return {
      'total_videos': videos.length,
      'avg_views': avgViews,
      'avg_engagement': avgEngagement,
      'best_performing': {
        'title': bestPerforming.title,
        'views': bestPerforming.viewCount,
        'engagement': bestPerforming.engagementRate,
      },
      'recommendations': [
        'Focus on content similar to your best performing videos',
        'Optimize video length to 8-15 minutes for better retention',
        'Use trending keywords in titles and descriptions',
        'Post during peak audience activity times',
        'Engage with comments within first 24 hours',
      ],
    };
  }

  void dispose() {
    _modelsController.close();
  }
}

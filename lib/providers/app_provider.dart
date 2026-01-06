import 'package:flutter/material.dart';
import '../models/video_data.dart';
import '../models/niche_data.dart';
import '../models/trending_topic.dart';
import '../services/youtube_api_service.dart';
import '../services/ai_model_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

class AppProvider extends ChangeNotifier {
  final YouTubeApiService _youtubeService = YouTubeApiService();
  final AIModelService _aiModelService = AIModelService();
  final StorageService _storageService = StorageService();
  final AnalyticsService _analyticsService = AnalyticsService();

  List<VideoData> _trendingVideos = [];
  List<VideoData> _searchResults = [];
  List<TrendingTopic> _trendingTopics = [];
  NicheData? _currentNicheData;
  
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRegion = 'US';
  String? _selectedCategory;
  String _currentLanguage = 'en'; // Default to English

  List<VideoData> get trendingVideos => _trendingVideos;
  List<VideoData> get searchResults => _searchResults;
  List<TrendingTopic> get trendingTopics => _trendingTopics;
  NicheData? get currentNicheData => _currentNicheData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedRegion => _selectedRegion;
  String? get selectedCategory => _selectedCategory;
  
  YouTubeApiService get youtubeService => _youtubeService;
  AIModelService get aiModelService => _aiModelService;
  StorageService get storageService => _storageService;
  AnalyticsService get analyticsService => _analyticsService;

  Future<void> initialize() async {
    await _storageService.initialize();
    await _aiModelService.initialize();
    
    final apiKey = _storageService.getApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      _youtubeService.setApiKey(apiKey);
    }
    
    _selectedRegion = _storageService.getRegion();
    _currentLanguage = _storageService.getLanguage();
    notifyListeners();
  }

  void setApiKey(String apiKey) {
    _youtubeService.setApiKey(apiKey);
    _storageService.saveApiKey(apiKey);
    notifyListeners();
  }

  bool get hasApiKey => _youtubeService.hasApiKey;

  Future<void> loadTrendingVideos({String? categoryId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trendingVideos = await _youtubeService.getTrendingVideos(
        regionCode: _selectedRegion,
        categoryId: categoryId ?? _selectedCategory,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _trendingVideos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchVideos(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _youtubeService.searchVideos(
        query: query,
        maxResults: 50,
      );
      
      await _storageService.addToSearchHistory(query);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrendingTopics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trendingTopics = await _youtubeService.getTrendingTopics(
        categoryId: _selectedCategory,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _trendingTopics = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeNiche(String niche) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentNicheData = await _youtubeService.analyzeNiche(
        niche: niche,
        categoryId: _selectedCategory,
      );
      
      if (_currentNicheData != null) {
        await _storageService.saveNicheData(niche, _currentNicheData!);
      }
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _currentNicheData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setRegion(String region) {
    _selectedRegion = region;
    _storageService.saveRegion(region);
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    _storageService.saveLanguage(languageCode);
    notifyListeners();
  }

  String get currentLanguage => _currentLanguage;

  void setCategory(String? categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  Map<String, String> get categories => _youtubeService.categories;

  List<String> get searchHistory => _storageService.getSearchHistory();

  Future<void> toggleFavorite(VideoData video) async {
    if (_storageService.isFavorite(video.id)) {
      await _storageService.removeFavoriteVideo(video.id);
    } else {
      await _storageService.addFavoriteVideo(video);
    }
    notifyListeners();
  }

  bool isFavorite(String videoId) {
    return _storageService.isFavorite(videoId);
  }

  List<VideoData> get favoriteVideos => _storageService.getFavoriteVideos();
}

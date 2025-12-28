import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_data.dart';
import '../models/niche_data.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return _prefs!;
  }

  Future<void> saveApiKey(String apiKey) async {
    await prefs.setString('youtube_api_key', apiKey);
  }

  String? getApiKey() {
    return prefs.getString('youtube_api_key');
  }

  Future<void> saveSearchHistory(List<String> history) async {
    await prefs.setString('search_history', json.encode(history));
  }

  List<String> getSearchHistory() {
    final historyJson = prefs.getString('search_history');
    if (historyJson == null) return [];
    return List<String>.from(json.decode(historyJson));
  }

  Future<void> addToSearchHistory(String query) async {
    final history = getSearchHistory();
    history.remove(query);
    history.insert(0, query);
    if (history.length > 20) {
      history.removeLast();
    }
    await saveSearchHistory(history);
  }

  Future<void> saveFavoriteVideos(List<VideoData> videos) async {
    final videosJson = videos.map((v) => v.toJson()).toList();
    await prefs.setString('favorite_videos', json.encode(videosJson));
  }

  List<VideoData> getFavoriteVideos() {
    final videosJson = prefs.getString('favorite_videos');
    if (videosJson == null) return [];
    final List<dynamic> videosList = json.decode(videosJson);
    return videosList.map((v) => VideoData.fromJson(v)).toList();
  }

  Future<void> addFavoriteVideo(VideoData video) async {
    final favorites = getFavoriteVideos();
    if (!favorites.any((v) => v.id == video.id)) {
      favorites.add(video);
      await saveFavoriteVideos(favorites);
    }
  }

  Future<void> removeFavoriteVideo(String videoId) async {
    final favorites = getFavoriteVideos();
    favorites.removeWhere((v) => v.id == videoId);
    await saveFavoriteVideos(favorites);
  }

  bool isFavorite(String videoId) {
    return getFavoriteVideos().any((v) => v.id == videoId);
  }

  Future<void> saveNicheData(String niche, NicheData data) async {
    final nicheKey = 'niche_$niche';
    await prefs.setString(nicheKey, json.encode(data.toJson()));
  }

  NicheData? getNicheData(String niche) {
    final nicheKey = 'niche_$niche';
    final dataJson = prefs.getString(nicheKey);
    if (dataJson == null) return null;
    return NicheData.fromJson(json.decode(dataJson));
  }

  Future<void> saveLanguage(String languageCode) async {
    await prefs.setString('language', languageCode);
  }

  String getLanguage() {
    return prefs.getString('language') ?? 'en';
  }

  Future<void> saveRegion(String regionCode) async {
    await prefs.setString('region', regionCode);
  }

  String getRegion() {
    return prefs.getString('region') ?? 'US';
  }

  Future<void> clearAllData() async {
    await prefs.clear();
  }

  // Channel data methods
  Future<void> saveChannelData(Map<String, dynamic> channelData) async {
    await prefs.setString('my_channel_data', json.encode(channelData));
  }

  Map<String, dynamic>? getChannelData() {
    final dataJson = prefs.getString('my_channel_data');
    if (dataJson == null) return null;
    return json.decode(dataJson) as Map<String, dynamic>;
  }

  Future<void> clearChannelData() async {
    await prefs.remove('my_channel_data');
  }
}

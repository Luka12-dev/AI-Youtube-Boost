import 'package:flutter/material.dart';

/// Base class for app localizations
abstract class AppLocalizations {
  // General
  String get appName;
  String get ok;
  String get cancel;
  String get save;
  String get delete;
  String get search;
  String get retry;
  String get loading;
  String get error;
  
  // Navigation
  String get home;
  String get trending;
  String get analytics;
  String get myAnalytics;
  String get nicheAnalytics;
  String get aiModels;
  String get settings;
  String get about;
  String get account;
  
  // Home Screen
  String get trendingVideos;
  String get searchVideos;
  String get searchHint;
  String get noVideosFound;
  String get errorLoadingVideos;
  String get allCategories;
  
  // Video Card
  String get views;
  String get likes;
  String get comments;
  String get publishedOn;
  String get watchOnYouTube;
  
  // Settings Screen
  String get appearance;
  String get apiConfiguration;
  String get regionAndLanguage;
  String get dataManagement;
  String get theme;
  String get liquidBlue;
  String get liquidDark;
  String get youtubeApiKey;
  String get enterApiKey;
  String get apiKeySaved;
  String get region;
  String get language;
  String get clearCache;
  String get clearCacheDescription;
  String get clearAllData;
  String get clearCacheConfirmTitle;
  String get clearCacheConfirmMessage;
  String get cacheCleared;
  String get customizeExperience;
  
  // Analytics Screen
  String get trendingAnalysis;
  String get topVideos;
  String get topChannels;
  String get categoryDistribution;
  String get viewsOverTime;
  String get engagementMetrics;
  String get averageViews;
  String get averageLikes;
  String get averageComments;
  String get totalVideos;
  
  // Niche Analytics
  String get nicheAnalysis;
  String get enterNiche;
  String get analyzeNiche;
  String get competitionLevel;
  String get opportunities;
  String get recommendations;
  String get topPerformers;
  
  // My Analytics
  String get myChannel;
  String get channelStats;
  String get subscribers;
  String get totalViews;
  String get videoCount;
  String get recentPerformance;
  String get connectChannel;
  String get channelUrl;
  String get enterChannelUrl;
  
  // AI Models
  String get selectAiModel;
  String get currentModel;
  String get modelDescription;
  String get apiKeyRequired;
  String get configureApiKey;
  
  // Error Messages
  String get noInternetConnection;
  String get apiKeyNotSet;
  String get failedToLoadData;
  String get somethingWentWrong;
  
  // Empty States
  String get noDataAvailable;
  String get startSearching;
  String get noFavorites;
  String get noHistory;
  
  // Regions
  String get unitedStates;
  String get unitedKingdom;
  String get canada;
  String get australia;
  String get india;
  String get germany;
  String get france;
  String get japan;
  String get southKorea;
  String get brazil;
  
  // Languages
  String get english;
  String get serbian;
  
  // Helper method to get localized instance
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

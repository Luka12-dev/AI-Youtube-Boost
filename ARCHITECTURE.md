# Architecture Documentation

## Overview

AI YouTube Boost follows a clean architecture pattern with separation of concerns, making the codebase maintainable, testable, and scalable. The app uses the Provider pattern for state management and implements a service-oriented architecture for business logic.

## Architecture Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│   (Screens, Widgets, UI Logic)      │
├─────────────────────────────────────┤
│       State Management Layer        │
│      (Providers, ViewModels)        │
├─────────────────────────────────────┤
│        Business Logic Layer         │
│    (Services, Use Cases, Utils)     │
├─────────────────────────────────────┤
│          Data Layer                 │
│  (Models, API, Local Storage)       │
└─────────────────────────────────────┘
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── video_data.dart
│   ├── niche_data.dart
│   ├── trending_topic.dart
│   └── ai_model_info.dart
├── providers/                # State management
│   ├── app_provider.dart
│   └── theme_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── api_key_setup_screen.dart
│   ├── trending_analysis_screen.dart
│   ├── niche_analytics_screen.dart
│   ├── my_analytics_screen.dart
│   ├── ai_models_screen.dart
│   ├── settings_screen.dart
│   ├── about_screen.dart
│   └── account_screen.dart
├── widgets/                  # Reusable components
│   ├── app_drawer.dart
│   ├── video_card.dart
│   ├── search_bar_widget.dart
│   ├── category_chips.dart
│   └── empty_state.dart
├── services/                 # Business logic
│   ├── youtube_api_service.dart
│   ├── ai_model_service.dart
│   ├── analytics_service.dart
│   └── storage_service.dart
├── theme/                    # Theme configuration
│   └── app_theme.dart
└── l10n/                     # Localization
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    ├── app_lovalizations_delegate.dart
    └── app_localizations_sr.dart
```

## Core Components

### 1. Data Layer

#### Models
Data models represent the structure of information used throughout the app:

- **VideoData**: YouTube video information including statistics, metadata, and calculated metrics
- **NicheData**: Aggregated analytics for a specific niche or topic
- **TrendingTopic**: Information about trending keywords and topics
- **AIModelInfo**: AI model metadata and download status

**Key Features:**
- JSON serialization/deserialization
- Computed properties for formatted data
- Immutable data structures with `copyWith` methods

#### Services

**YouTubeApiService**
- Handles all YouTube Data API v3 interactions
- Methods:
  - `searchVideos()`: Search for videos by query
  - `getTrendingVideos()`: Fetch trending videos by region
  - `analyzeNiche()`: Analyze a specific niche
  - `getTrendingTopics()`: Discover trending topics
  - `getChannelStatistics()`: Fetch channel data

**StorageService**
- Manages local data persistence using SharedPreferences
- Methods:
  - `saveApiKey()` / `getApiKey()`: API key management
  - `saveFavoriteVideos()` / `getFavoriteVideos()`: Favorites management
  - `saveSearchHistory()` / `getSearchHistory()`: Search history
  - `saveNicheData()` / `getNicheData()`: Cached niche analytics
  - `saveChannelData()` / `getChannelData()`: User channel information

**AIModelService**
- Manages AI model lifecycle (download, deletion, usage)
- Simulates model downloads with progress tracking
- Provides AI-powered analytics:
  - `analyzeVideosWithAI()`: Batch video analysis
  - `predictViralPotential()`: Viral score prediction
  - `generateKeywordSuggestions()`: Keyword generation
  - `generateContentInsights()`: Content recommendations

**AnalyticsService**
- Performs statistical analysis on video data
- Methods:
  - `calculateStatistics()`: Basic stats computation
  - `getViewDistribution()`: View range distribution
  - `getPublishingPatterns()`: Posting time analysis
  - `getDayOfWeekDistribution()`: Weekly patterns
  - `getTopPerformers()`: Top video identification
  - `extractCommonKeywords()`: Keyword extraction
  - `predictOptimalPostTime()`: Best posting time prediction

### 2. State Management Layer

#### Providers

**AppProvider**
- Central state management for the entire application
- Manages:
  - API key configuration
  - Video data (trending, search results, favorites)
  - Niche analytics
  - Trending topics
  - Search history
  - Loading states and error handling
- Methods:
  - `loadTrendingVideos()`: Fetch trending videos
  - `searchVideos()`: Search functionality
  - `analyzeNiche()`: Niche analysis
  - `toggleFavorite()`: Manage favorites
  - `setRegion()` / `setLanguage()`: Preferences

**ThemeProvider**
- Manages theme state and persistence
- Supports two theme modes:
  - Liquid Blue (light)
  - Liquid Dark (dark)
- Provides gradient configurations
- Persists theme preference

### 3. Presentation Layer

#### Screens

**SplashScreen**
- App initialization
- Animated logo with liquid background
- Provider initialization
- Navigation to home screen

**HomeScreen**
- Main interface with tabbed navigation
- Tabs:
  - Trending: Display trending videos
  - Search: Search results
  - Favorites: Saved videos
- Features:
  - Category filtering
  - Search functionality
  - Pull-to-refresh
  - Theme toggle

**TrendingAnalysisScreen**
- Detailed trending topic analysis
- Overview statistics
- Topic cards with metrics
- Modal bottom sheets for details

**NicheAnalyticsScreen**
- Niche-specific analytics
- Input field for niche query
- Statistics display:
  - Total videos and views
  - Engagement rates
  - Growth indicators
- Keyword analysis (top & rising)
- View distribution charts

**MyAnalyticsScreen**
- Personal channel analytics
- Channel connection interface
- Performance metrics:
  - Subscriber count
  - Video count
  - Total views
- Top performing videos
- Engagement trends chart

**AIModelsScreen**
- AI model management interface
- Model cards showing:
  - Model information
  - Download status
  - Progress indicators
- Download and delete functionality

**SettingsScreen**
- App configuration
- Sections:
  - Appearance (theme selection)
  - API Configuration
  - Region & Language
  - Data Management
- Theme preview cards
- Clear cache functionality

**AboutScreen**
- App information
- Feature highlights
- Social links
- Version information

**AccountScreen**
- User profile management
- Activity statistics
- Name and email fields
- Save functionality

**ApiKeySetupScreen**
- Initial API key setup
- Onboarding interface
- API key input with visibility toggle
- Help dialog for API key acquisition

#### Widgets

**AppDrawer**
- Navigation drawer
- Sections:
  - App header with logo
  - Channel section (connect/manage)
  - Navigation items
  - Footer
- Animated menu items
- Channel data display and management

**VideoCard**
- Reusable video display component
- Shows:
  - Thumbnail with duration overlay
  - Title and channel
  - View count and publish time
  - Engagement rate badge
  - Favorite toggle button
- Cached images for performance

**SearchBarWidget**
- Search input component
- Clear button when text present
- Submit on enter
- Customizable callbacks

**CategoryChips**
- Horizontal scrollable category filter
- Selected state management
- Category selection callback

**EmptyState**
- Generic empty state component
- Configurable:
  - Icon
  - Title
  - Message
  - Optional action button

### 4. Theme System

**AppTheme**
- Defines two complete theme configurations
- **Liquid Blue Theme:**
  - Light background (#F5F9FC)
  - Blue gradient (#00B4DB to #00A8CC)
  - High contrast for readability
- **Liquid Dark Theme:**
  - Pure black background (#000000)
  - Subtle gray surfaces (#0A0A0A, #1A1A1A)
  - White text with reduced opacity

**Theme Components:**
- TextTheme using Inter font family
- Custom card theme (rounded corners, no elevation)
- Elevated button theme (rounded, consistent padding)
- Input decoration theme (filled fields, rounded borders)
- Icon theme
- Chip theme

### 5. Localization System

**Structure:**
- Abstract base class: `AppLocalizations`
- Language implementations:
  - `AppLocalizationsEn`: English translations
  - `AppLocalizationsSr`: Serbian translations (Cyrillic)

**Coverage:**
- UI labels and buttons
- Navigation items
- Error messages
- Empty state messages
- Settings options
- Region names
- Language names

**Usage:**
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.appName);
```

## Data Flow

### Typical User Flow

1. **App Launch**
   ```
   SplashScreen
   ↓
   Initialize AppProvider & ThemeProvider
   ↓
   Check API key existence
   ↓
   Navigate to HomeScreen or ApiKeySetupScreen
   ```

2. **Video Search**
   ```
   User enters search query
   ↓
   AppProvider.searchVideos(query)
   ↓
   YouTubeApiService.searchVideos()
   ↓
   API request to YouTube
   ↓
   Parse response to VideoData models
   ↓
   Update state & notify listeners
   ↓
   UI rebuilds with results
   ```

3. **Niche Analysis**
   ```
   User enters niche keyword
   ↓
   AppProvider.analyzeNiche(keyword)
   ↓
   YouTubeApiService.analyzeNiche()
   ↓
   Fetch videos, calculate statistics
   ↓
   Create NicheData model
   ↓
   Cache in StorageService
   ↓
   Update state & display results
   ```

4. **AI Analysis**
   ```
   User selects AI model
   ↓
   AIModelService.downloadModel()
   ↓
   Simulate download with progress
   ↓
   Mark model as ready
   ↓
   User requests analysis
   ↓
   AIModelService.analyzeVideosWithAI()
   ↓
   Calculate viral potential, insights
   ↓
   Display results
   ```

## Key Design Patterns

### 1. Provider Pattern
Used for state management with clear separation between UI and business logic.

```dart
// In Provider
class AppProvider extends ChangeNotifier {
  void updateData() {
    // Update state
    notifyListeners(); // Rebuild dependent widgets
  }
}

// In Widget
final appProvider = Provider.of<AppProvider>(context);
```

### 2. Service Pattern
Business logic encapsulated in service classes, injected where needed.

```dart
class YouTubeApiService {
  Future<List<VideoData>> searchVideos({...}) async {
    // API logic
  }
}
```

### 3. Repository Pattern
StorageService acts as a repository for local data persistence.

```dart
class StorageService {
  SharedPreferences get prefs => _prefs!;
  
  Future<void> saveData(String key, String value) async {
    await prefs.setString(key, value);
  }
}
```

### 4. Factory Pattern
Models use factory constructors for JSON parsing.

```dart
class VideoData {
  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id'],
      title: json['snippet']['title'],
      // ...
    );
  }
}
```

### 5. Singleton Pattern
Services use singleton pattern for global access.

```dart
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();
}
```

## State Management Flow

```
User Action (Widget)
↓
Provider Method Call
↓
Service Layer (Business Logic)
↓
API Call / Local Storage
↓
Data Processing
↓
Provider State Update
↓
notifyListeners()
↓
Widget Rebuild (Consumer/Provider.of)
```

## Error Handling Strategy

1. **API Errors**: Caught in services, error messages stored in provider
2. **UI Errors**: Displayed using `ScaffoldMessenger` or error widgets
3. **Network Errors**: Graceful degradation with retry options
4. **Storage Errors**: Fallback to default values

Example:
```dart
try {
  final videos = await youtubeService.searchVideos(query: query);
  _searchResults = videos;
  _errorMessage = null;
} catch (e) {
  _errorMessage = 'Failed to search videos: $e';
  _searchResults = [];
} finally {
  _isLoading = false;
  notifyListeners();
}
```

## Performance Optimizations

1. **Image Caching**: `cached_network_image` for thumbnails
2. **Lazy Loading**: ListView.builder for efficient list rendering
3. **Debouncing**: Search input debouncing to reduce API calls
4. **State Persistence**: Store frequently accessed data locally
5. **Selective Rebuilds**: Consumer widgets for targeted rebuilds

## Testing Strategy

### Unit Tests
- Test services independently
- Test data models (JSON parsing, computed properties)
- Test utility functions

### Widget Tests
- Test individual widget behavior
- Test user interactions
- Test state changes

### Integration Tests
- Test complete user flows
- Test provider interactions
- Test API integration

## Security Considerations

1. **API Key Storage**: Stored locally using SharedPreferences
2. **No Hardcoded Secrets**: API key required from user
3. **HTTPS Only**: All API calls use HTTPS
4. **Input Validation**: User inputs sanitized before API calls
5. **Error Messages**: Generic error messages without sensitive data

## Scalability Considerations

1. **Modular Architecture**: Easy to add new features
2. **Service Layer**: Business logic isolated from UI
3. **Provider Pattern**: Scales well with app complexity
4. **Theme System**: Easy to add new themes
5. **Localization**: Easy to add new languages

## Future Enhancements

1. **Offline Mode**: Cache more data for offline access
2. **User Authentication**: Firebase auth for cloud sync
3. **Advanced AI Models**: Integration with real AI APIs
4. **Export Features**: Export analytics as PDF/CSV
5. **Notifications**: Trend alerts and new video notifications
6. **Real-time Updates**: WebSocket for live data
7. **Advanced Filtering**: More granular search filters
8. **Collaboration**: Share analytics with team members

## Dependencies

### Core
- `flutter`: SDK
- `provider`: State management
- `shared_preferences`: Local storage

### UI/UX
- `google_fonts`: Typography
- `flutter_animate`: Animations
- `cached_network_image`: Image caching
- `fl_chart`: Charts and graphs

### Networking
- `http`: HTTP client
- `url_launcher`: External URLs

### Utilities
- `intl`: Internationalization
- `path_provider`: File system paths

## Best Practices Followed

1. **Separation of Concerns**: Clear layer separation
2. **DRY Principle**: Reusable widgets and services
3. **SOLID Principles**: Single responsibility, open/closed
4. **Consistent Naming**: Clear, descriptive names
5. **Code Documentation**: Comments for complex logic
6. **Error Handling**: Comprehensive try-catch blocks
7. **Immutability**: Immutable models with copyWith
8. **Responsive Design**: Adapts to different screen sizes
9. **Accessibility**: Semantic widgets, proper labels
10. **Performance**: Optimized rendering and caching

---

This architecture ensures the app is maintainable, testable, and ready for future growth while providing a smooth user experience.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/video_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';
import 'api_key_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      if (appProvider.hasApiKey) {
        appProvider.loadTrendingVideos();
        appProvider.loadTrendingTopics();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (!appProvider.hasApiKey) {
      return const ApiKeySetupScreen();
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeProvider.isDarkMode
                ? [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                  ],
          ),
        ),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: false,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  title: Text(
                    'AI YouTube Boost',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(120),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SearchBarWidget(
                            controller: _searchController,
                            onSearch: (query) {
                              if (query.isNotEmpty) {
                                appProvider.searchVideos(query);
                                _tabController.animateTo(1); // Switch to Search tab
                              }
                            },
                            onClear: () {
                              _searchController.clear();
                              appProvider.clearSearchResults();
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        CategoryChips(
                          selectedCategory: appProvider.selectedCategory,
                          onCategorySelected: (categoryId) {
                            appProvider.setCategory(categoryId);
                            appProvider.loadTrendingVideos(categoryId: categoryId);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: themeProvider.isDarkMode
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  labelColor: themeProvider.isDarkMode
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.6),
                  tabs: const [
                    Tab(text: 'Trending'),
                    Tab(text: 'Search'),
                    Tab(text: 'Favorites'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTrendingTab(appProvider),
                      _buildSearchTab(appProvider),
                      _buildFavoritesTab(appProvider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingTab(AppProvider appProvider) {
    if (appProvider.isLoading && appProvider.trendingVideos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (appProvider.errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Error Loading Videos',
        message: appProvider.errorMessage!,
        actionLabel: 'Retry',
        onAction: () => appProvider.loadTrendingVideos(),
      );
    }

    if (appProvider.trendingVideos.isEmpty) {
      return EmptyState(
        icon: Icons.trending_up_rounded,
        title: 'No Trending Videos',
        message: 'Check your internet connection and try again',
        actionLabel: 'Reload',
        onAction: () => appProvider.loadTrendingVideos(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => appProvider.loadTrendingVideos(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: appProvider.trendingVideos.length,
        itemBuilder: (context, index) {
          final video = appProvider.trendingVideos[index];
          return VideoCard(
            video: video,
            onTap: () {
              // Video details will be handled later
            },
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: index * 50),
          ).slideX(
            begin: 0.2,
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: index * 50),
          );
        },
      ),
    );
  }

  Widget _buildSearchTab(AppProvider appProvider) {
    if (appProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (appProvider.errorMessage != null && appProvider.searchResults.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Search Error',
        message: appProvider.errorMessage!,
        actionLabel: 'Retry',
        onAction: () {
          if (_searchController.text.isNotEmpty) {
            appProvider.searchVideos(_searchController.text);
          }
        },
      );
    }

    if (appProvider.searchResults.isEmpty) {
      return EmptyState(
        icon: Icons.search_rounded,
        title: 'Search Videos',
        message: 'Enter a keyword to search for videos and analyze trends',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: appProvider.searchResults.length,
      itemBuilder: (context, index) {
        final video = appProvider.searchResults[index];
        return VideoCard(
          video: video,
          onTap: () {
            // Video details will be handled later
          },
        ).animate().fadeIn(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: index * 50),
        );
      },
    );
  }

  Widget _buildFavoritesTab(AppProvider appProvider) {
    final favorites = appProvider.favoriteVideos;

    if (favorites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_outline_rounded,
        title: 'No Favorites Yet',
        message: 'Save videos to your favorites for quick access',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final video = favorites[index];
        return VideoCard(
          video: video,
          onTap: () {
            // Video details will be handled later
          },
        );
      },
    );
  }
}

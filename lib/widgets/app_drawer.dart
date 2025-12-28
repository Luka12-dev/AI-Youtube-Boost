import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/theme_provider.dart';
import '../providers/app_provider.dart';
import '../screens/trending_analysis_screen.dart';
import '../screens/niche_analytics_screen.dart';
import '../screens/my_analytics_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';
import '../screens/account_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeProvider.isDarkMode
                ? [
                    const Color(0xFF000000),
                    const Color(0xFF0A0A0A),
                  ]
                : [
                    const Color(0xFFF5F9FC),
                    const Color(0xFFE8F4F8),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, themeProvider),
              const SizedBox(height: 20),
              _buildChannelSection(context, appProvider, themeProvider),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.home_rounded,
                      title: 'Home',
                      onTap: () => Navigator.pop(context),
                      index: 0,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.account_circle_rounded,
                      title: 'My Account',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AccountScreen()),
                        );
                      },
                      index: 1,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.bar_chart_rounded,
                      title: 'My Analytics',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyAnalyticsScreen()),
                        );
                      },
                      index: 2,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.trending_up_rounded,
                      title: 'Trending Analysis',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TrendingAnalysisScreen()),
                        );
                      },
                      index: 3,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.analytics_rounded,
                      title: 'Niche Analytics',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NicheAnalyticsScreen()),
                        );
                      },
                      index: 4,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Divider(),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                      index: 5,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutScreen()),
                        );
                      },
                      index: 6,
                    ),
                  ],
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: themeProvider.getMainGradient(),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              size: 40,
              color: Colors.white,
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 15),
          Text(
            'AI YouTube Boost',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
          const SizedBox(height: 5),
          Text(
            'Analyze. Optimize. Grow.',
            style: Theme.of(context).textTheme.bodySmall,
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 100 + (index * 50)),
      duration: const Duration(milliseconds: 300),
    ).slideX(
      begin: -0.2,
      delay: Duration(milliseconds: 100 + (index * 50)),
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildChannelSection(BuildContext context, AppProvider appProvider, ThemeProvider themeProvider) {
    final channelData = appProvider.storageService.getChannelData();
    final channelName = channelData?['title'] ?? '';
    final channelLogo = channelData?['thumbnailUrl'] ?? '';
    final subscriberCount = channelData?['subscriberCount'] ?? 0;
    final videoCount = channelData?['videoCount'] ?? 0;
    final viewCount = channelData?['viewCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: channelLogo.isEmpty ? themeProvider.getMainGradient() : null,
                ),
                child: channelLogo.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: channelLogo,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channelName.isEmpty ? 'My Channel' : channelName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subscriberCount > 0) ...[
                      Text(
                        '${_formatCount(subscriberCount)} subscribers',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (videoCount > 0)
                        Text(
                          '$videoCount videos • ${_formatCount(viewCount)} views',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                              ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showChannelSetupDialog(context, appProvider),
                  icon: Icon(
                    channelName.isEmpty ? Icons.add_rounded : Icons.edit_rounded,
                    size: 18,
                  ),
                  label: Text(channelName.isEmpty ? 'Set Channel' : 'Edit'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (channelName.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _clearChannelData(context, appProvider),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  tooltip: 'Clear Channel Data',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 100),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _showChannelSetupDialog(BuildContext context, AppProvider appProvider) {
    final channelIdController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Load Your Channel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your YouTube Channel ID or Channel Name:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: channelIdController,
                  decoration: const InputDecoration(
                    labelText: 'Channel ID or Name',
                    hintText: 'e.g., UC... or Channel Name',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'How to find your Channel ID:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '1. Go to YouTube Studio\n2. Click Settings > Channel\n3. Copy your Channel ID\n\nOr just enter your channel name!',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final input = channelIdController.text.trim();
                if (input.isEmpty) return;

                setState(() => isLoading = true);

                try {
                  Map<String, dynamic> channelInfo;
                  
                  // Check if it's a channel ID (starts with UC)
                  if (input.startsWith('UC')) {
                    channelInfo = await appProvider.youtubeService.getChannelStatistics(input);
                  } else {
                    // Search by channel name
                    channelInfo = await appProvider.youtubeService.searchChannelByName(input);
                  }

                  // Extract and save data
                  final snippet = channelInfo['snippet'] ?? {};
                  final statistics = channelInfo['statistics'] ?? {};
                  
                  final channelData = {
                    'id': channelInfo['id'],
                    'title': snippet['title'] ?? '',
                    'description': snippet['description'] ?? '',
                    'thumbnailUrl': snippet['thumbnails']?['high']?['url'] ?? 
                                   snippet['thumbnails']?['medium']?['url'] ?? 
                                   snippet['thumbnails']?['default']?['url'] ?? '',
                    'subscriberCount': int.tryParse(statistics['subscriberCount']?.toString() ?? '0') ?? 0,
                    'videoCount': int.tryParse(statistics['videoCount']?.toString() ?? '0') ?? 0,
                    'viewCount': int.tryParse(statistics['viewCount']?.toString() ?? '0') ?? 0,
                  };

                  await appProvider.storageService.saveChannelData(channelData);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Channel loaded: ${channelData['title']}'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() => isLoading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        duration: const Duration(seconds: 4),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Load Channel'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearChannelData(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Channel Data'),
        content: const Text('Are you sure you want to remove your channel information?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await appProvider.storageService.clearChannelData();
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Channel data cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 10),
          Text(
            'Version 1.0.0',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

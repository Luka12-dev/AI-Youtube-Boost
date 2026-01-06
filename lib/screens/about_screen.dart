import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
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
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAppInfo(context, themeProvider),
                    const SizedBox(height: 24),
                    _buildDescription(context),
                    const SizedBox(height: 24),
                    _buildFeatures(context),
                    const SizedBox(height: 24),
                    _buildSocialLinks(context),
                    const SizedBox(height: 24),
                    _buildFooter(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Learn more about the app',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: themeProvider.getMainGradient(),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                size: 50,
                color: Colors.white,
              ),
            ).animate().scale(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 20),
            Text(
              'AI YouTube Boost',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
            const SizedBox(height: 16),
            Text(
              'Analyze. Optimize. Grow.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'About This App',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'AI YouTube Boost is a powerful analytics tool designed to help content creators and marketers understand YouTube trends, analyze niches, and optimize their content strategy using advanced AI models.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 200),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final features = [
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Trending Analysis',
        'description': 'Discover what\'s trending in real-time',
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'Niche Analytics',
        'description': 'Deep dive into any niche or topic',
      },
      {
        'icon': Icons.psychology_rounded,
        'title': 'AI Models',
        'description': 'Advanced AI-powered insights',
      },
      {
        'icon': Icons.search_rounded,
        'title': 'Smart Search',
        'description': 'Find and analyze any content',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Features',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        ...features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          return Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                feature['title'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: Text(feature['description'] as String),
            ),
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: 300 + (index * 100)),
          ).slideX(
            begin: 0.2,
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: 300 + (index * 100)),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Connect With Us',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSocialButton(
              context,
              icon: Icons.code_rounded,
              label: 'GitHub Repository',
              url: 'https://github.com/Luka12-dev/AI-Youtube-Boost',
            ),
            const SizedBox(height: 12),
            _buildSocialButton(
              context,
              icon: Icons.person_rounded,
              label: 'Developer Profile',
              url: 'https://github.com/Luka12-dev/',
            ),
            const SizedBox(height: 12),
            _buildSocialButton(
              context,
              icon: Icons.play_circle_outline_rounded,
              label: 'YouTube Channel',
              url: 'https://www.youtube.com/@LukaCyber-s4b7o',
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 600),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Made with dedication for content creators',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '© 2025 AI YouTube Boost',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 800),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

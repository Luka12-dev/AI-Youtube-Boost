import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isApiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final apiKey = appProvider.storageService.getApiKey();
    if (apiKey != null) {
      _apiKeyController.text = apiKey;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context);

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
                    _buildSection(
                      context,
                      l10n.appearance,
                      [
                        _buildThemeSelector(context, themeProvider),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      l10n.apiConfiguration,
                      [
                        _buildApiKeyField(context, appProvider),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      l10n.regionAndLanguage,
                      [
                        _buildRegionSelector(context, appProvider),
                        const Divider(),
                        _buildLanguageSelector(context, appProvider),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      l10n.dataManagement,
                      [
                        _buildClearCacheButton(context, appProvider),
                      ],
                    ),
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
    final l10n = AppLocalizations.of(context);
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
                  l10n.settings,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  l10n.customizeExperience,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.theme,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildThemeOption(
                context,
                themeProvider,
                l10n.liquidBlue,
                AppThemeMode.liquidBlue,
                Icons.water_drop_rounded,
                const LinearGradient(
                  colors: [
                    AppTheme.liquidBlueGradientStart,
                    AppTheme.liquidBlueGradientEnd,
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildThemeOption(
                context,
                themeProvider,
                l10n.liquidDark,
                AppThemeMode.liquidDark,
                Icons.dark_mode_rounded,
                const LinearGradient(
                  colors: [
                    AppTheme.liquidDarkBackground,
                    AppTheme.liquidDarkSurfaceVariant,
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    String label,
    AppThemeMode mode,
    IconData icon,
    LinearGradient gradient,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return GestureDetector(
      onTap: () => themeProvider.setTheme(mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyField(BuildContext context, AppProvider appProvider) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.youtubeApiKey,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _apiKeyController,
          obscureText: !_isApiKeyVisible,
          decoration: InputDecoration(
            hintText: l10n.enterApiKey,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isApiKeyVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _isApiKeyVisible = !_isApiKeyVisible;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.save_rounded),
                  onPressed: () {
                    appProvider.setApiKey(_apiKeyController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.apiKeySaved),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegionSelector(BuildContext context, AppProvider appProvider) {
    final l10n = AppLocalizations.of(context);
    final regions = {
      'US': l10n.unitedStates,
      'GB': l10n.unitedKingdom,
      'CA': l10n.canada,
      'AU': l10n.australia,
      'IN': l10n.india,
      'DE': l10n.germany,
      'FR': l10n.france,
      'JP': l10n.japan,
      'KR': l10n.southKorea,
      'BR': l10n.brazil,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.region,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: appProvider.selectedRegion,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.public_rounded),
          ),
          items: regions.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              appProvider.setRegion(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context, AppProvider appProvider) {
    final l10n = AppLocalizations.of(context);
    // Only supported languages: English and Serbian
    final languages = {
      'en': l10n.english,
      'sr': l10n.serbian,
    };

    final currentLanguage = appProvider.storageService.getLanguage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.language,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: languages.containsKey(currentLanguage) ? currentLanguage : 'en',
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.language_rounded),
          ),
          items: languages.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              appProvider.setLanguage(value);
              // Show restart message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Language will be applied on next app restart'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildClearCacheButton(BuildContext context, AppProvider appProvider) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.clearCache,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.clearCacheDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.clearCacheConfirmTitle),
                  content: Text(l10n.clearCacheConfirmMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await appProvider.storageService.clearAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.cacheCleared),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.clearAllData),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';

class ApiKeySetupScreen extends StatefulWidget {
  const ApiKeySetupScreen({Key? key}) : super(key: key);

  @override
  State<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends State<ApiKeySetupScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.getMainGradient(),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.key_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ).animate().scale(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'YouTube API Key',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your YouTube Data API v3 key to get started',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _apiKeyController,
                          obscureText: _isObscured,
                          decoration: InputDecoration(
                            labelText: 'API Key',
                            hintText: 'AIzaSy...',
                            prefixIcon: const Icon(Icons.vpn_key_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_apiKeyController.text.isNotEmpty) {
                                final appProvider = Provider.of<AppProvider>(
                                  context,
                                  listen: false,
                                );
                                appProvider.setApiKey(_apiKeyController.text);
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Continue'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(
                    delay: const Duration(milliseconds: 400),
                  ).slideY(
                    begin: 0.2,
                    delay: const Duration(milliseconds: 400),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      _showHelpDialog(context);
                    },
                    child: Text(
                      'How to get an API key?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get YouTube API Key'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Follow these steps to get your API key:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildStep('1', 'Go to Google Cloud Console'),
              _buildStep('2', 'Create a new project or select existing'),
              _buildStep('3', 'Enable YouTube Data API v3'),
              _buildStep('4', 'Go to Credentials section'),
              _buildStep('5', 'Create API Key'),
              _buildStep('6', 'Copy and paste it here'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Note: The API key is stored locally on your device and never shared.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

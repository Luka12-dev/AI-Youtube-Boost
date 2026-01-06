import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated Feature Card for AI YouTube Boost v2.0
/// Beautiful card to showcase new features
class AnimatedFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final bool isNew;

  const AnimatedFeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const Spacer(),
                  if (isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2000.ms),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: color, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}

/// Feature Grid Widget
class FeatureGridWidget extends StatelessWidget {
  const FeatureGridWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      children: [
        AnimatedFeatureCard(
          icon: Icons.compare_arrows_rounded,
          title: 'Video Comparison',
          description: 'Compare multiple videos side-by-side with AI insights',
          color: Colors.purple,
          isNew: true,
          onTap: () {
            // Navigate to comparison screen
          },
        ),
        AnimatedFeatureCard(
          icon: Icons.psychology_rounded,
          title: 'Performance Predictor',
          description: 'Predict video performance before publishing',
          color: Colors.blue,
          isNew: true,
          onTap: () {
            // Navigate to predictor screen
          },
        ),
        AnimatedFeatureCard(
          icon: Icons.tag_rounded,
          title: 'Hashtag Generator',
          description: 'Generate optimal hashtags for maximum reach',
          color: Colors.orange,
          isNew: true,
          onTap: () {
            // Navigate to hashtag screen
          },
        ),
        AnimatedFeatureCard(
          icon: Icons.group_rounded,
          title: 'Competitor Tracker',
          description: 'Track and analyze competitor channels',
          color: Colors.green,
          isNew: true,
          onTap: () {
            // Navigate to competitor screen
          },
        ),
      ],
    );
  }
}

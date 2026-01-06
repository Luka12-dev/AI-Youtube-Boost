import 'package:flutter/material.dart';
import '../models/video_comparison.dart';

/// Comparison Card Widget for AI YouTube Boost v2.0
class ComparisonCard extends StatelessWidget {
  final VideoComparison comparison;
  final VoidCallback? onTap;

  const ComparisonCard({
    Key? key,
    required this.comparison,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final winner = comparison.getWinner();
    final winnerMetrics = comparison.metrics[winner];

    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.compare_arrows, color: Colors.purple, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Video Comparison',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          winnerMetrics?.getGrade() ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${comparison.videoIds.length} videos compared',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (winnerMetrics != null)
                LinearProgressIndicator(
                  value: winnerMetrics.overallScore / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 8,
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confidence',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    '${(comparison.confidenceScore * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

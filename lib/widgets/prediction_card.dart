import 'package:flutter/material.dart';
import '../models/video_prediction.dart';

/// Prediction Card Widget for AI YouTube Boost v2.0
class PredictionCard extends StatelessWidget {
  final VideoPrediction prediction;
  final VoidCallback? onTap;

  const PredictionCard({
    Key? key,
    required this.prediction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.analytics, color: Colors.blue, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prediction.videoTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMetricRow(
                context,
                'Predicted Views',
                prediction.formattedPredictedViews,
                Icons.visibility,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildMetricRow(
                context,
                'Success Rate',
                '${(prediction.successProbability * 100).toStringAsFixed(0)}%',
                Icons.trending_up,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildMetricRow(
                context,
                'Virality',
                prediction.viralityLevel,
                Icons.whatshot,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(prediction.category),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(prediction.timeframe.displayName),
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
}

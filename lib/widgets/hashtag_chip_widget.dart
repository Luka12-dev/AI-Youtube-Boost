import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hashtag_analysis.dart';

/// Advanced Hashtag Chip Widget for AI YouTube Boost v2.0
class HashtagChipWidget extends StatelessWidget {
  final HashtagItem hashtag;
  final VoidCallback? onTap;
  final bool showDetails;

  const HashtagChipWidget({
    Key? key,
    required this.hashtag,
    this.onTap,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _copyHashtag(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getChipColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getChipColor(), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hashtag.trend.emoji,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            Text(
              '#${hashtag.tag}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getChipColor(),
              ),
            ),
            if (showDetails) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getChipColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  hashtag.formattedSearchVolume,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getChipColor() {
    if (hashtag.trend == HashtagTrend.viral) return Colors.red;
    if (hashtag.trend == HashtagTrend.rising) return Colors.orange;
    if (hashtag.trend == HashtagTrend.stable) return Colors.blue;
    return Colors.grey;
  }

  void _copyHashtag(BuildContext context) {
    Clipboard.setData(ClipboardData(text: '#${hashtag.tag}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied #${hashtag.tag}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Hashtag Grid Widget
class HashtagGridWidget extends StatelessWidget {
  final List<HashtagItem> hashtags;
  final bool showDetails;

  const HashtagGridWidget({
    Key? key,
    required this.hashtags,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hashtags.map((tag) {
        return HashtagChipWidget(
          hashtag: tag,
          showDetails: showDetails,
          onTap: () => _showHashtagDetails(context, tag),
        );
      }).toList(),
    );
  }

  void _showHashtagDetails(BuildContext context, HashtagItem tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(tag.trend.emoji),
            const SizedBox(width: 8),
            Expanded(child: Text('#${tag.tag}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Score', '${tag.score.toStringAsFixed(0)}/100'),
            _buildDetailRow('Search Volume', tag.formattedSearchVolume),
            _buildDetailRow('Competition', tag.competitionLevelText),
            _buildDetailRow('Trend', tag.trend.displayName),
            _buildDetailRow('Category', tag.category),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '#${tag.tag}'));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hashtag copied!')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/competitor_channel.dart';
import '../services/competitor_tracking_service.dart';
import 'package:fl_chart/fl_chart.dart';

/// Competitor Tracker Screen for AI YouTube Boost v2.0
class CompetitorTrackerScreen extends StatefulWidget {
  const CompetitorTrackerScreen({Key? key}) : super(key: key);

  @override
  State<CompetitorTrackerScreen> createState() => _CompetitorTrackerScreenState();
}

class _CompetitorTrackerScreenState extends State<CompetitorTrackerScreen> {
  final _trackingService = CompetitorTrackingService();
  final List<CompetitorChannel> _competitors = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Competitor Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCompetitorDialog,
          ),
        ],
      ),
      body: _competitors.isEmpty ? _buildEmptyState() : _buildCompetitorsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No Competitors Tracked', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Track competitor channels to analyze their strategies', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddCompetitorDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Competitor'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _competitors.length,
      itemBuilder: (context, index) {
        final competitor = _competitors[index];
        return _buildCompetitorCard(competitor);
      },
    );
  }

  Widget _buildCompetitorCard(CompetitorChannel competitor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(competitor.channelName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
        ),
        title: Text(competitor.channelName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${competitor.formattedSubscribers} subscribers • ${competitor.growthStatus}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsRow(competitor),
                const SizedBox(height: 16),
                _buildGrowthChart(competitor),
                const SizedBox(height: 16),
                _buildUploadScheduleInfo(competitor),
                const SizedBox(height: 16),
                _buildActionButtons(competitor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(CompetitorChannel competitor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Videos', competitor.videoCount.toString(), Icons.video_library),
        _buildStatItem('Avg Views', competitor.formattedAvgViews, Icons.visibility),
        _buildStatItem('Engagement', '${competitor.avgEngagementRate.toStringAsFixed(1)}%', Icons.favorite),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildGrowthChart(CompetitorChannel competitor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Growth Trend', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: competitor.metrics.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.subscribers.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadScheduleInfo(CompetitorChannel competitor) {
    final schedule = competitor.uploadSchedule;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Pattern', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildInfoRow('Best Day', schedule.bestUploadDay),
        _buildInfoRow('Best Time', schedule.bestUploadTime),
        _buildInfoRow('Frequency', '${schedule.avgVideosPerWeek} videos/week'),
        _buildInfoRow('Consistency', '${(schedule.consistency * 100).toStringAsFixed(0)}%'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CompetitorChannel competitor) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _removeCompetitor(competitor),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove'),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddCompetitorDialog() async {
    final nameController = TextEditingController();
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Competitor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Channel Name',
                hintText: 'Enter channel name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Channel ID',
                hintText: 'Enter channel ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && idController.text.isNotEmpty) {
                Navigator.pop(context);
                await _addCompetitor(idController.text, nameController.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCompetitor(String channelId, String channelName) async {
    setState(() => _isLoading = true);

    try {
      final competitor = await _trackingService.trackChannel(channelId, channelName);
      setState(() {
        _competitors.add(competitor);
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${channelName} added successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _removeCompetitor(CompetitorChannel competitor) {
    setState(() {
      _competitors.remove(competitor);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${competitor.channelName} removed')),
    );
  }
}

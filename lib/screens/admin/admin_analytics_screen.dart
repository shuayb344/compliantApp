import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../providers/complaint_provider.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performance Analytics', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Category Distribution'),
                const SizedBox(height: 16),
                _buildPieChart(provider),
                const SizedBox(height: 40),
                
                _buildSectionTitle('Status Overview'),
                const SizedBox(height: 16),
                _buildBarChart(provider),
                const SizedBox(height: 40),
                
                _buildSectionTitle('Efficiency Metrics'),
                const SizedBox(height: 16),
                _buildMetricsList(provider),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppStyles.heading3);
  }

  Widget _buildPieChart(ComplaintProvider provider) {
    final categories = ['Billing', 'Technical', 'Service', 'Infrastructure'];
    final data = categories.map((cat) {
      final count = provider.complaints.where((c) => c.category == cat).length;
      return PieChartSectionData(
        value: count.toDouble() == 0 ? 0.1 : count.toDouble(),
        title: count > 0 ? '$count' : '',
        color: _getCategoryColor(cat),
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      height: 250,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: data,
                sectionsSpace: 4,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((cat) => _buildLegendItem(cat, _getCategoryColor(cat))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ComplaintProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      decoration: AppStyles.cardDecoration,
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barGroups: [
            _buildBarGroup(0, provider.pendingCount.toDouble(), AppColors.pending, 'Pending'),
            _buildBarGroup(1, provider.inProgressCount.toDouble(), AppColors.inProgress, 'In Progress'),
            _buildBarGroup(2, provider.resolvedCount.toDouble(), AppColors.resolved, 'Resolved'),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Pending', 'Progress', 'Resolved'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(titles[value.toInt()], style: AppStyles.caption),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMetricsList(ComplaintProvider provider) {
    return Column(
      children: [
        _buildMetricTile('Avg. Resolution Time', '4.2 Days', Icons.timer_outlined, Colors.blue),
        const SizedBox(height: 12),
        _buildMetricTile('Satisfaction Score', '92%', Icons.star_outline, Colors.orange),
        const SizedBox(height: 12),
        _buildMetricTile('Total Interactions', '${provider.complaints.length * 3}', Icons.forum_outlined, Colors.green),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(value, style: AppStyles.heading3),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Billing': return AppColors.billing;
      case 'Technical': return AppColors.technical;
      case 'Service': return AppColors.service;
      case 'Infrastructure': return AppColors.infrastructure;
      default: return Colors.grey;
    }
  }
}

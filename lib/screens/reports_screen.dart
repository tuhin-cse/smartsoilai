import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            'Disease Analysis Report',
            'Leaf Blight Detection',
            '2 days ago',
            Icons.bug_report,
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Soil Health Report',
            'Nutrient Analysis Complete',
            '1 week ago',
            Icons.landscape,
            AppColors.primary500,
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Growth Monitoring',
            'Weekly Progress Update',
            '1 week ago',
            Icons.trending_up,
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Weather Impact',
            'Rainfall Analysis',
            '2 weeks ago',
            Icons.cloud,
            AppColors.weatherCloud,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textTertiary,
        ),
        onTap: () {
          // TODO: Navigate to report detail
        },
      ),
    );
  }
}

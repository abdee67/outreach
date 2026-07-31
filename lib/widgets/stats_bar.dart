import 'package:flutter/material.dart';

import '../models/business.dart';
import '../theme/app_colors.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key, required this.stats});

  final BusinessStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _StatItem(label: 'Total', value: stats.total),
          _divider(),
          _StatItem(label: 'Called', value: stats.called),
          _divider(),
          _StatItem(label: 'Booked', value: stats.booked, highlight: true),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.border,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final int value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: highlight ? AppColors.sage : AppColors.ink,
                ),
          ),
        ],
      ),
    );
  }
}

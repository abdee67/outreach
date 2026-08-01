import 'package:flutter/material.dart';

import '../models/business.dart';
import '../models/business_status.dart';
import '../theme/app_colors.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({
    super.key,
    required this.stats,
    this.selectedStatus,
    required this.onStatusSelected,
  });

  final BusinessStats stats;
  final BusinessStatus? selectedStatus;
  final ValueChanged<BusinessStatus?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _StatTab(
              label: 'All',
              value: stats.total,
              isSelected: selectedStatus == null,
              onTap: () => onStatusSelected(null),
            ),
            const SizedBox(width: 8),
            _StatTab(
              label: 'Not Contacted',
              value: stats.notContacted,
              isSelected: selectedStatus == BusinessStatus.notContacted,
              onTap: () => onStatusSelected(BusinessStatus.notContacted),
            ),
            const SizedBox(width: 8),
            _StatTab(
              label: 'Called',
              value: stats.called,
              isSelected: selectedStatus == BusinessStatus.called,
              onTap: () => onStatusSelected(BusinessStatus.called),
            ),
            const SizedBox(width: 8),
            _StatTab(
              label: 'Interested',
              value: stats.interested,
              isSelected: selectedStatus == BusinessStatus.interested,
              onTap: () => onStatusSelected(BusinessStatus.interested),
            ),
            const SizedBox(width: 8),
            _StatTab(
              label: 'Booked',
              value: stats.booked,
              isSelected: selectedStatus == BusinessStatus.booked,
              highlightColor: AppColors.sage,
              onTap: () => onStatusSelected(BusinessStatus.booked),
            ),
            const SizedBox(width: 8),
            _StatTab(
              label: 'Rejected',
              value: stats.rejected,
              isSelected: selectedStatus == BusinessStatus.rejected,
              onTap: () => onStatusSelected(BusinessStatus.rejected),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTab extends StatelessWidget {
  const _StatTab({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
    this.highlightColor,
  });

  final String label;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final activeColor = highlightColor ?? AppColors.burgundy;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : AppColors.ink,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.2) 
                    : AppColors.paper,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected ? Colors.white : AppColors.muted,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/business_status.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.onTap,
    this.compact = false,
  });

  final BusinessStatus status;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForStatus(status);

    final badge = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(status),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Text(
          status.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );

    if (onTap == null) return badge;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: badge,
    );
  }

  static ({Color background, Color foreground}) _colorsForStatus(
    BusinessStatus status,
  ) {
    switch (status) {
      case BusinessStatus.notContacted:
        return (background: AppColors.blush, foreground: AppColors.muted);
      case BusinessStatus.called:
        return (background: AppColors.peach, foreground: AppColors.clay);
      case BusinessStatus.interested:
        return (background: AppColors.rose, foreground: AppColors.clay);
      case BusinessStatus.booked:
        return (background: AppColors.successSurface, foreground: AppColors.sage);
      case BusinessStatus.rejected:
        return (
          background: AppColors.error.withValues(alpha: 0.12),
          foreground: AppColors.error,
        );
    }
  }
}

class StatusChipSelector extends StatelessWidget {
  const StatusChipSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final BusinessStatus selected;
  final ValueChanged<BusinessStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BusinessStatus.values.map((status) {
        final isSelected = status == selected;
        final colors = StatusBadge._colorsForStatus(status);

        return FilterChip(
          label: Text(status.label),
          selected: isSelected,
          onSelected: (_) => onSelected(status),
          backgroundColor: colors.background,
          selectedColor: AppColors.peach,
          checkmarkColor: AppColors.burgundy,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.burgundy : colors.foreground,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.burgundy : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }
}

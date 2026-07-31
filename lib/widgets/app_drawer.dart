import 'package:flutter/material.dart';

import '../models/business.dart';
import '../theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.totalBusinesses,
    required this.totalBooked,
    required this.onCategorySelected,
  });

  final List<CategoryCount> categories;
  final String? selectedCategory;
  final int totalBusinesses;
  final int totalBooked;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(
              totalBusinesses: totalBusinesses,
              totalBooked: totalBooked,
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _CategoryTile(
                    title: 'All Businesses',
                    count: totalBusinesses,
                    isSelected: selectedCategory == null,
                    onTap: () => onCategorySelected(null),
                  ),
                  if (categories.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Categories',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.muted,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                    ...categories.map(
                      (cat) => _CategoryTile(
                        title: cat.category,
                        count: cat.count,
                        isSelected: selectedCategory == cat.category,
                        onTap: () => onCategorySelected(cat.category),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.totalBusinesses,
    required this.totalBooked,
  });

  final int totalBusinesses;
  final int totalBooked;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outreach CRM',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.burgundy,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalBusinesses businesses · $totalBooked booked',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? AppColors.peach : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? const Border(
                      left: BorderSide(color: AppColors.burgundy, width: 3),
                    )
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? AppColors.burgundy : AppColors.ink,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surface : AppColors.blush,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected ? AppColors.burgundy : AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

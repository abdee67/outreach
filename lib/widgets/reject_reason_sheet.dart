import 'package:flutter/material.dart';

import '../models/reject_reason.dart';
import '../theme/app_colors.dart';

class RejectReasonSheet extends StatelessWidget {
  const RejectReasonSheet({
    super.key,
    required this.businessName,
    required this.onSelected,
  });

  final String businessName;
  final ValueChanged<RejectReason> onSelected;

  static Future<RejectReason?> show(
    BuildContext context, {
    required String businessName,
  }) {
    return showModalBottomSheet<RejectReason>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RejectReasonSheet(
        businessName: businessName,
        onSelected: (reason) {
          Navigator.of(context).pop(reason);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Reject reason',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            businessName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...RejectReason.values.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => onSelected(reason),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(reason.label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

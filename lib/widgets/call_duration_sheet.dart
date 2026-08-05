import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CallDurationSheet extends StatefulWidget {
  const CallDurationSheet({
    super.key,
    required this.businessName,
    required this.onSave,
  });

  final String businessName;
  final ValueChanged<int> onSave;

  static Future<void> show(
    BuildContext context, {
    required String businessName,
    required ValueChanged<int> onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CallDurationSheet(
        businessName: businessName,
        onSave: onSave,
      ),
    );
  }

  @override
  State<CallDurationSheet> createState() => _CallDurationSheetState();
}

class _CallDurationSheetState extends State<CallDurationSheet> {
  int _minutes = 0;

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
            'How long was the call?',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            widget.businessName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _minutes > 0
                    ? () => setState(() => _minutes--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.burgundy,
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '$_minutes min',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: _minutes < 60
                    ? () => setState(() => _minutes++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.burgundy,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _minutes.toDouble(),
            min: 0,
            max: 60,
            divisions: 60,
            activeColor: AppColors.burgundy,
            onChanged: (value) => setState(() => _minutes = value.round()),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              widget.onSave(_minutes);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

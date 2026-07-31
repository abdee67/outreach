import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business.dart';
import '../models/business_status.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class BusinessDetailSheet extends StatefulWidget {
  const BusinessDetailSheet({
    super.key,
    required this.business,
    required this.onSave,
  });

  final Business business;
  final ValueChanged<Business> onSave;

  static Future<void> show(
    BuildContext context, {
    required Business business,
    required ValueChanged<Business> onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BusinessDetailSheet(
        business: business,
        onSave: onSave,
      ),
    );
  }

  @override
  State<BusinessDetailSheet> createState() => _BusinessDetailSheetState();
}

class _BusinessDetailSheetState extends State<BusinessDetailSheet> {
  late final TextEditingController _notesController;
  late BusinessStatus _status;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.business.notes);
    _status = widget.business.status;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveNotes() {
    widget.onSave(
      widget.business.copyWith(
        notes: _notesController.text.trim(),
        status: _status,
      ),
    );
  }

  Future<void> _callPhone() async {
    final phone = widget.business.phone;
    if (phone == null || phone.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMaps() async {
    final url = widget.business.googleMapsUrl;
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                widget.business.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.business.category != null &&
                  widget.business.category!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.business.category!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.business.phone?.isNotEmpty == true
                          ? _callPhone
                          : null,
                      icon: const Icon(Icons.phone_outlined),
                      label: const Text('Call'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.burgundy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.business.googleMapsUrl?.isNotEmpty == true
                          ? _openMaps
                          : null,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Open in Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.burgundy,
                        side: const BorderSide(color: AppColors.burgundy),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              StatusChipSelector(
                selected: _status,
                onSelected: (status) {
                  setState(() => _status = status);
                  widget.onSave(widget.business.copyWith(status: status));
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) _saveNotes();
                },
                child: TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Add outreach notes…',
                  ),
                  onEditingComplete: _saveNotes,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

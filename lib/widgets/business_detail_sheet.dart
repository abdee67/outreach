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
    this.onCallStarted,
    this.onStatusChanged,
  });

  final Business business;
  final ValueChanged<Business> onSave;
  final ValueChanged<Business>? onCallStarted;
  final Future<void> Function(Business business, BusinessStatus status)?
      onStatusChanged;

  static Future<void> show(
    BuildContext context, {
    required Business business,
    required ValueChanged<Business> onSave,
    ValueChanged<Business>? onCallStarted,
    Future<void> Function(Business business, BusinessStatus status)?
        onStatusChanged,
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
        onCallStarted: onCallStarted,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

  @override
  State<BusinessDetailSheet> createState() => _BusinessDetailSheetState();
}

class _BusinessDetailSheetState extends State<BusinessDetailSheet> {
  late final TextEditingController _notesController;
  late final TextEditingController _dealValueController;
  late BusinessStatus _status;
  DateTime? _followUpDate;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.business.notes);
    _dealValueController = TextEditingController(
      text: widget.business.dealValue?.toString() ?? '',
    );
    _status = widget.business.status;
    _followUpDate = widget.business.followUpDate;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _dealValueController.dispose();
    super.dispose();
  }

  void _saveNotes() {
    widget.onSave(
      widget.business.copyWith(
        notes: _notesController.text.trim(),
        status: _status,
        dealValue: _parseDealValue(_dealValueController.text),
      ),
    );
  }

  double? _parseDealValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', ''));
  }

  Future<void> _callPhone() async {
    final phone = widget.business.phone;
    if (phone == null || phone.isEmpty) return;

    widget.onCallStarted?.call(widget.business);

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

  Future<void> _pickFollowUpDateTime() async {
    final now = DateTime.now();
    final initialDate = _followUpDate ?? now.add(const Duration(days: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_followUpDate ?? initialDate),
    );
    if (time == null || !mounted) return;

    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() => _followUpDate = scheduled);

    final updated = widget.business.copyWith(followUpDate: scheduled);
    widget.onSave(updated);
  }

  Future<void> _clearFollowUp() async {
    setState(() => _followUpDate = null);

    final updated = widget.business.copyWith(clearFollowUpDate: true);
    widget.onSave(updated);
  }

  Future<void> _handleStatusChange(BusinessStatus status) async {
    if (widget.onStatusChanged != null) {
      await widget.onStatusChanged!(widget.business, status);
      if (!mounted) return;
      setState(() => _status = status);
      return;
    }

    setState(() => _status = status);
    widget.onSave(widget.business.copyWith(status: status));
  }

  String _formatFollowUp(DateTime date) {
    final local = date.toLocal();
    final datePart =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final timePart =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$datePart at $timePart';
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
                onSelected: _handleStatusChange,
              ),
              const SizedBox(height: 24),
              Text(
                'Follow-up Reminder',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              if (_followUpDate != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.peach,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: AppColors.clay),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatFollowUp(_followUpDate!),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: _clearFollowUp,
                        icon: const Icon(Icons.close, size: 18),
                        color: AppColors.muted,
                        tooltip: 'Clear follow-up',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: _pickFollowUpDateTime,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _followUpDate == null
                      ? 'Schedule callback'
                      : 'Change callback time',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.burgundy,
                  side: const BorderSide(color: AppColors.burgundy),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_status == BusinessStatus.booked ||
                  _status == BusinessStatus.interested) ...[
                const SizedBox(height: 24),
                Text(
                  'Deal Value',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) _saveNotes();
                  },
                  child: TextField(
                    controller: _dealValueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter deal value…',
                      prefixText: '\$ ',
                    ),
                    onEditingComplete: _saveNotes,
                  ),
                ),
              ],
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

import 'package:flutter/material.dart';

import '../models/csv_field.dart';
import '../services/csv_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';

enum ImportMode { merge, replace }

class ColumnMappingScreen extends StatefulWidget {
  const ColumnMappingScreen({
    super.key,
    required this.parseResult,
    required this.hasExistingData,
  });

  final CsvParseResult parseResult;
  final bool hasExistingData;

  @override
  State<ColumnMappingScreen> createState() => _ColumnMappingScreenState();
}

class _ColumnMappingScreenState extends State<ColumnMappingScreen> {
  late final Map<String, CsvField> _mapping;
  ImportMode _importMode = ImportMode.merge;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _mapping = _buildInitialMapping(widget.parseResult.headers);
  }

  Map<String, CsvField> _buildInitialMapping(List<String> headers) {
    final mapping = <String, CsvField>{};

    for (final header in headers) {
      final normalized = header.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      mapping[header] = _guessField(normalized) ?? CsvField.skip;
    }

    return mapping;
  }

  CsvField? _guessField(String normalized) {
    if (normalized.contains('name') || normalized.contains('business')) {
      return CsvField.businessName;
    }
    if (normalized.contains('address') || normalized == 'addr') {
      return CsvField.address;
    }
    if (normalized.contains('category') ||
        normalized.contains('type') ||
        normalized.contains('industry')) {
      return CsvField.category;
    }
    if (normalized.contains('phone') || normalized.contains('tel')) {
      return CsvField.phone;
    }
    if (normalized.contains('lat')) {
      return CsvField.latitude;
    }
    if (normalized.contains('lng') || normalized.contains('lon')) {
      return CsvField.longitude;
    }
    if (normalized.contains('maps') || normalized.contains('url') || normalized.contains('link')) {
      return CsvField.googleMapsUrl;
    }
    return null;
  }

  bool get _hasBusinessNameMapping {
    return _mapping.values.contains(CsvField.businessName);
  }

  Set<CsvField> get _usedFields {
    return _mapping.values.where((f) => f != CsvField.skip).toSet();
  }

  Future<void> _import() async {
    if (!_hasBusinessNameMapping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please map a column to Business Name.')),
      );
      return;
    }

    setState(() => _isImporting = true);

    try {
      final businesses = CsvService.instance.mapRowsToBusinesses(
        headers: widget.parseResult.headers,
        rows: widget.parseResult.rows,
        columnMapping: _mapping,
      );

      if (businesses.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid rows found in the CSV.')),
          );
        }
        return;
      }

      if (_importMode == ImportMode.replace) {
        await DatabaseService.instance.replaceAllBusinesses(businesses);
      } else {
        await DatabaseService.instance.mergeBusinesses(businesses);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Columns'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${widget.parseResult.rows.length} rows detected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assign each CSV column to a field. Business Name is required.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                ...widget.parseResult.headers.map((header) {
                  return _MappingRow(
                    header: header,
                    selected: _mapping[header] ?? CsvField.skip,
                    usedFields: _usedFields,
                    onChanged: (field) {
                      setState(() => _mapping[header] = field);
                    },
                  );
                }),
                if (widget.hasExistingData) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Import mode',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<ImportMode>(
                    segments: const [
                      ButtonSegment(
                        value: ImportMode.merge,
                        label: Text('Merge'),
                        icon: Icon(Icons.merge_type, size: 18),
                      ),
                      ButtonSegment(
                        value: ImportMode.replace,
                        label: Text('Replace'),
                        icon: Icon(Icons.swap_horiz, size: 18),
                      ),
                    ],
                    selected: {_importMode},
                    onSelectionChanged: (selection) {
                      setState(() => _importMode = selection.first);
                    },
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.burgundy;
                        }
                        return AppColors.ink;
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _importMode == ImportMode.merge
                        ? 'Merge keeps existing statuses and notes for matching businesses.'
                        : 'Replace deletes all existing data and imports fresh.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isImporting ? null : _import,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.burgundy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isImporting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Import Businesses'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MappingRow extends StatelessWidget {
  const _MappingRow({
    required this.header,
    required this.selected,
    required this.usedFields,
    required this.onChanged,
  });

  final String header;
  final CsvField selected;
  final Set<CsvField> usedFields;
  final ValueChanged<CsvField> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              header,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<CsvField>(
              key: ValueKey('$header-$selected'),
              initialValue: selected,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: CsvField.mappableFields.map((field) {
                final isUsedElsewhere =
                    usedFields.contains(field) && field != selected && field != CsvField.skip;
                return DropdownMenuItem(
                  value: field,
                  enabled: !isUsedElsewhere,
                  child: Text(
                    field.label + (field.required ? ' *' : ''),
                    style: TextStyle(
                      color: isUsedElsewhere ? AppColors.muted : AppColors.ink,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:csv/csv.dart';

import '../models/business.dart';
import '../models/csv_field.dart';

class CsvParseResult {
  const CsvParseResult({
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<String>> rows;
}

class CsvService {
  CsvService._();
  static final CsvService instance = CsvService._();

  static final Csv _codec = Csv(lineDelimiter: '\n');

  CsvParseResult parse(String content) {
    final rows = _codec.decode(content);

    if (rows.isEmpty) {
      return const CsvParseResult(headers: [], rows: []);
    }

    final headers = rows.first.map((cell) => cell?.toString().trim() ?? '').toList();
    final dataRows = rows
        .skip(1)
        .where((row) => row.any((cell) => cell?.toString().trim().isNotEmpty ?? false))
        .map(
          (row) => List.generate(
            headers.length,
            (i) => i < row.length ? (row[i]?.toString().trim() ?? '') : '',
          ),
        )
        .toList();

    return CsvParseResult(headers: headers, rows: dataRows);
  }

  List<Business> mapRowsToBusinesses({
    required List<String> headers,
    required List<List<String>> rows,
    required Map<String, CsvField> columnMapping,
  }) {
    final fieldIndex = <CsvField, int>{};
    columnMapping.forEach((header, field) {
      if (field != CsvField.skip) {
        fieldIndex[field] = headers.indexOf(header);
      }
    });

    if (!fieldIndex.containsKey(CsvField.businessName)) {
      throw ArgumentError('Business Name column must be mapped.');
    }

    final businesses = <Business>[];
    for (final row in rows) {
      final name = _cellValue(row, fieldIndex[CsvField.businessName]);
      if (name.isEmpty) continue;

      businesses.add(
        Business(
          name: name,
          address: _optionalCell(row, fieldIndex[CsvField.address]),
          category: _optionalCell(row, fieldIndex[CsvField.category]),
          phone: _optionalCell(row, fieldIndex[CsvField.phone]),
          latitude: _parseDouble(_optionalCell(row, fieldIndex[CsvField.latitude])),
          longitude: _parseDouble(_optionalCell(row, fieldIndex[CsvField.longitude])),
          googleMapsUrl: _optionalCell(row, fieldIndex[CsvField.googleMapsUrl]),
        ),
      );
    }

    return businesses;
  }

  String _cellValue(List<String> row, int? index) {
    if (index == null || index < 0 || index >= row.length) return '';
    return row[index].trim();
  }

  String? _optionalCell(List<String> row, int? index) {
    final value = _cellValue(row, index);
    return value.isEmpty ? null : value;
  }

  double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', ''));
  }

  String businessesToCsv(List<Business> businesses) {
    const exportHeaders = [
      'Business Name',
      'Address',
      'Category',
      'Phone',
      'Latitude',
      'Longitude',
      'Google Maps URL',
      'Status',
      'Date First Contacted',
      'Date Last Contacted',
      'Total Call Attempts',
      'Last Call Duration (min)',
      'Follow-up Date',
      'Reject Reason',
      'Deal Value',
      'Date Booked',
      'Call Notes',
    ];

    final rows = businesses.map((b) {
      return [
        b.name,
        b.address ?? '',
        b.category ?? '',
        b.phone ?? '',
        b.latitude?.toString() ?? '',
        b.longitude?.toString() ?? '',
        b.googleMapsUrl ?? '',
        b.status.label,
        _formatDateTime(b.dateFirstContacted),
        _formatDateTime(b.dateLastContacted),
        b.totalCallAttempts.toString(),
        b.lastCallDurationMin?.toString() ?? '',
        _formatDateTime(b.followUpDate),
        b.rejectReason?.label ?? '',
        b.dealValue?.toString() ?? '',
        _formatDateTime(b.dateBooked),
        b.notes,
      ];
    }).toList();

    return _codec.encode([exportHeaders, ...rows]);
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<String> readFileContent(List<int> bytes) async {
    return utf8.decode(bytes);
  }
}

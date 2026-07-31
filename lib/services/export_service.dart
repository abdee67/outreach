import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/business.dart';
import 'csv_service.dart';

class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  Future<void> exportAndShare(List<Business> businesses) async {
    final csvContent = CsvService.instance.businessesToCsv(businesses);
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/businesses_export_$timestamp.csv');
    await file.writeAsString(csvContent);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv', name: 'businesses_export.csv')],
        subject: 'Business Outreach Export',
        text: 'Exported ${businesses.length} businesses',
      ),
    );
  }
}

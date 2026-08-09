import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:outreach/services/notifications/notification_service.dart';

import '../models/business.dart';
import '../models/business_status.dart';
import '../services/csv_service.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/business_card.dart';
import '../widgets/business_detail_sheet.dart';
import '../widgets/call_duration_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/reject_reason_sheet.dart';
import '../widgets/stats_bar.dart';
import 'column_mapping_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Business> _businesses = [];
  List<CategoryCount> _categories = [];
  BusinessStats _stats = BusinessStats.empty;
  int _totalBusinesses = 0;
  int _totalBooked = 0;

  String? _selectedCategory;
  BusinessStatus? _statusFilter;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isExporting = false;

  int? _pendingCallBusinessId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.instance.pendingBusinessId.addListener(
      _handlePendingNotificationTap,
    );
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
      _loadBusinesses();
    });
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.instance.pendingBusinessId.removeListener(
      _handlePendingNotificationTap,
    );
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleReturnFromCall();
      _handlePendingNotificationTap();
    }
  }

  void _handlePendingNotificationTap() {
    final businessId = NotificationService.instance.consumePendingBusinessId();
    if (businessId == null || !mounted) return;
    _openBusinessFromNotification(businessId);
  }

  Future<void> _openBusinessFromNotification(int businessId) async {
    final business = await DatabaseService.instance.getBusinessById(businessId);
    if (business == null || !mounted) return;

    await BusinessDetailSheet.show(
      context,
      business: business,
      onSave: _saveBusiness,
      onCallStarted: _onCallStarted,
      onStatusChanged: _applyStatusChange,
    );
  }

  Future<void> _handleReturnFromCall() async {
    final businessId = _pendingCallBusinessId;
    if (businessId == null || !mounted) return;

    _pendingCallBusinessId = null;

    final business = await DatabaseService.instance.getBusinessById(businessId);
    if (business == null || !mounted) return;

    await CallDurationSheet.show(
      context,
      businessName: business.name,
      onSave: (minutes) async {
        final updated = business.recordCall(durationMin: minutes);
        await DatabaseService.instance.updateBusiness(updated);
        await _loadData();
      },
    );
  }

  void _onCallStarted(Business business) {
    _pendingCallBusinessId = business.id;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final categories = await DatabaseService.instance.getCategoryCounts();
    final total = await DatabaseService.instance.getTotalCount();
    final booked = await DatabaseService.instance.getBookedCount();
    final stats = await DatabaseService.instance.getStats(category: _selectedCategory);
    final businesses = await DatabaseService.instance.getBusinesses(
      category: _selectedCategory,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      statusFilter: _statusFilter,
    );

    final allBusinesses = await DatabaseService.instance.getAllBusinesses();
    await NotificationService.instance.reschedulePendingFollowUps(allBusinesses);

    if (mounted) {
      setState(() {
        _categories = categories;
        _totalBusinesses = total;
        _totalBooked = booked;
        _stats = stats;
        _businesses = businesses;
        _isLoading = false;
      });
      _handlePendingNotificationTap();
    }
  }

  Future<void> _loadBusinesses() async {
    final stats = await DatabaseService.instance.getStats(category: _selectedCategory);
    final businesses = await DatabaseService.instance.getBusinesses(
      category: _selectedCategory,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      statusFilter: _statusFilter,
    );

    if (mounted) {
      setState(() {
        _stats = stats;
        _businesses = businesses;
      });
    }
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read the selected file.')),
        );
      }
      return;
    }

    final content = await CsvService.instance.readFileContent(file.bytes!);
    final parseResult = CsvService.instance.parse(content);

    if (parseResult.headers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The CSV file appears to be empty.')),
        );
      }
      return;
    }

    if (!mounted) return;

    final imported = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ColumnMappingScreen(
          parseResult: parseResult,
          hasExistingData: _totalBusinesses > 0,
        ),
      ),
    );

    if (imported == true) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import completed successfully.')),
        );
      }
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      await ExportService.instance.exportAndShare(_businesses);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _applyStatusChange(
    Business business,
    BusinessStatus status,
  ) async {
    if (status == BusinessStatus.rejected) {
      final reason = await RejectReasonSheet.show(
        context,
        businessName: business.name,
      );
      if (reason == null || !mounted) return;

      final updated = business.copyWith(
        status: BusinessStatus.rejected,
        rejectReason: reason,
      );
      await DatabaseService.instance.updateBusiness(updated);
    } else {
      var updated = business.copyWith(
        status: status,
        clearRejectReason: status != BusinessStatus.rejected,
      );

      if (status == BusinessStatus.booked && business.dateBooked == null) {
        updated = updated.copyWith(dateBooked: DateTime.now());
      }

      await DatabaseService.instance.updateBusiness(updated);
    }

    await _loadData();
  }

  Future<void> _updateStatus(Business business, BusinessStatus status) async {
    await _applyStatusChange(business, status);
  }

  Future<void> _cycleStatus(Business business) async {
    await _updateStatus(business, business.status.next);
  }

  Future<void> _saveBusiness(Business business) async {
    var updated = business;

    if (business.status == BusinessStatus.booked &&
        updated.dateBooked == null) {
      updated = updated.copyWith(dateBooked: DateTime.now());
    }

    await DatabaseService.instance.updateBusiness(updated);
    await NotificationService.instance.syncFollowUpForBusiness(updated);
    await _loadData();
  }

  Future<void> _deleteBusiness(Business business) async {
    await NotificationService.instance.cancelFollowUp(business.id!);
    await DatabaseService.instance.deleteBusiness(business.id!);
    await _loadData();
  }

  void _selectCategory(String? category) {
    setState(() => _selectedCategory = category);
    _scaffoldKey.currentState?.closeDrawer();
    _loadData();
  }

  void _selectStatusFilter(BusinessStatus? status) {
    setState(() => _statusFilter = status);
    _loadBusinesses();
  }

  String get _appBarTitle {
    if (_selectedCategory != null) return _selectedCategory!;
    return 'All Businesses';
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _totalBusinesses > 0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.paper,
      drawer: hasData
          ? AppDrawer(
              categories: _categories,
              selectedCategory: _selectedCategory,
              totalBusinesses: _totalBusinesses,
              totalBooked: _totalBooked,
              onCategorySelected: _selectCategory,
            )
          : null,
      appBar: AppBar(
        title: Text(hasData ? _appBarTitle : 'Outreach'),
        automaticallyImplyLeading: hasData,
        actions: [
          if (hasData)
            IconButton(
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_outlined),
              tooltip: 'Export CSV',
              onPressed: _isExporting ? null : _exportCsv,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'import') _importCsv();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_file_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Import CSV'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: hasData
          ? null
          : FloatingActionButton.extended(
              onPressed: _importCsv,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Import CSV'),
            ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.burgundy),
            )
          : hasData
              ? Column(
                  children: [
                    StatsBar(
                      stats: _stats,
                      selectedStatus: _statusFilter,
                      onStatusSelected: _selectStatusFilter,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name…',
                          prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _businesses.isEmpty
                          ? Center(
                              child: Text(
                                'No businesses match your filters.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.muted,
                                    ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _businesses.length,
                              itemBuilder: (context, index) {
                                final business = _businesses[index];
                                return BusinessCard(
                                  business: business,
                                  onTap: () => BusinessDetailSheet.show(
                                    context,
                                    business: business,
                                    onSave: _saveBusiness,
                                    onCallStarted: _onCallStarted,
                                    onStatusChanged: _applyStatusChange,
                                  ),
                                  onStatusTap: () => _cycleStatus(business),
                                  onDelete: () => _deleteBusiness(business),
                                );
                              },
                            ),
                    ),
                  ],
                )
              : EmptyState(onImport: _importCsv),
    );
  }
}

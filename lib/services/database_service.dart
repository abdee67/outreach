import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/business.dart';
import '../models/business_status.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_crm.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE businesses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT,
            category TEXT,
            phone TEXT,
            latitude REAL,
            longitude REAL,
            google_maps_url TEXT,
            status TEXT NOT NULL DEFAULT 'notContacted',
            notes TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_businesses_category ON businesses(category)',
        );
        await db.execute(
          'CREATE INDEX idx_businesses_status ON businesses(status)',
        );
        await db.execute(
          'CREATE INDEX idx_businesses_name ON businesses(name)',
        );
      },
    );
  }

  Future<List<Business>> getBusinesses({
    String? category,
    String? searchQuery,
    BusinessStatus? statusFilter,
  }) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (category != null && category.isNotEmpty) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClauses.add('name LIKE ?');
      whereArgs.add('%$searchQuery%');
    }

    if (statusFilter != null) {
      whereClauses.add('status = ?');
      whereArgs.add(statusFilter.name);
    }

    final maps = await db.query(
      'businesses',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return maps.map(Business.fromMap).toList();
  }

  Future<List<CategoryCount>> getCategoryCounts() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM businesses
      WHERE category IS NOT NULL AND category != ''
      GROUP BY category
      ORDER BY category COLLATE NOCASE ASC
    ''');

    return maps
        .map(
          (m) => CategoryCount(
            category: m['category'] as String,
            count: m['count'] as int,
          ),
        )
        .toList();
  }

  Future<BusinessStats> getStats({String? category}) async {
    final db = await database;
    final where = category != null && category.isNotEmpty
        ? 'WHERE category = ?'
        : '';
    final args = category != null && category.isNotEmpty ? [category] : <Object?>[];

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM businesses $where',
      args,
    );
    final calledResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM businesses $where${where.isEmpty ? 'WHERE' : ' AND'} status IN ('called', 'interested', 'booked', 'rejected')",
      args,
    );
    final bookedResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM businesses $where${where.isEmpty ? 'WHERE' : ' AND'} status = 'booked'",
      args,
    );

    return BusinessStats(
      total: Sqflite.firstIntValue(totalResult) ?? 0,
      called: Sqflite.firstIntValue(calledResult) ?? 0,
      booked: Sqflite.firstIntValue(bookedResult) ?? 0,
    );
  }

  Future<int> getTotalCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM businesses');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getBookedCount() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM businesses WHERE status = 'booked'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> insertBusinesses(List<Business> businesses) async {
    final db = await database;
    final batch = db.batch();
    for (final business in businesses) {
      batch.insert('businesses', business.toMap()..remove('id'));
    }
    await batch.commit(noResult: true);
  }

  Future<void> replaceAllBusinesses(List<Business> businesses) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('businesses');
      for (final business in businesses) {
        await txn.insert('businesses', business.toMap()..remove('id'));
      }
    });
  }

  Future<void> mergeBusinesses(List<Business> incoming) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final business in incoming) {
        final existing = await txn.query(
          'businesses',
          where: 'name = ? AND IFNULL(category, \'\') = IFNULL(?, \'\')',
          whereArgs: [business.name, business.category],
          limit: 1,
        );

        if (existing.isEmpty) {
          await txn.insert('businesses', business.toMap()..remove('id'));
        } else {
          final current = Business.fromMap(existing.first);
          await txn.update(
            'businesses',
            business
                .copyWith(
                  id: current.id,
                  status: current.status,
                  notes: current.notes,
                )
                .copyWith(updatedAt: DateTime.now())
                .toMap()
              ..remove('id'),
            where: 'id = ?',
            whereArgs: [current.id],
          );
        }
      }
    });
  }

  Future<void> updateBusiness(Business business) async {
    final db = await database;
    await db.update(
      'businesses',
      business.copyWith(updatedAt: DateTime.now()).toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [business.id],
    );
  }

  Future<void> updateStatus(int id, BusinessStatus status) async {
    final db = await database;
    await db.update(
      'businesses',
      {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteBusiness(int id) async {
    final db = await database;
    await db.delete('businesses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Business>> getAllBusinesses() async {
    final db = await database;
    final maps = await db.query('businesses', orderBy: 'name COLLATE NOCASE ASC');
    return maps.map(Business.fromMap).toList();
  }
}

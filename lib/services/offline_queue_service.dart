import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class OfflineQueueService {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'tb_mobile_queue.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE offline_operations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            local_uuid TEXT NOT NULL,
            type TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> addProductExit({
    required String trackingCode,
    required int pickedByUserId,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    final database = await db;
    await database.insert('offline_operations', {
      'local_uuid': const Uuid().v4(),
      'type': 'product-exit',
      'payload': jsonEncode({
        'tracking_code': trackingCode,
        'picked_by_user_id': pickedByUserId,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes ?? '',
      }),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> pending() async {
    final database = await db;
    final rows = await database.query('offline_operations', orderBy: 'id ASC');
    return rows.map((row) => {
      'id': row['id'],
      'local_uuid': row['local_uuid'],
      'type': row['type'],
      'payload': jsonDecode('${row['payload']}'),
      'created_at': row['created_at'],
    }).toList();
  }

  Future<int> count() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) AS total FROM offline_operations');
    return int.tryParse('${result.first['total'] ?? 0}') ?? 0;
  }

  Future<void> deleteIds(List<int> ids) async {
    if (ids.isEmpty) return;
    final database = await db;
    final placeholders = List.filled(ids.length, '?').join(',');
    await database.delete('offline_operations', where: 'id IN ($placeholders)', whereArgs: ids);
  }
}

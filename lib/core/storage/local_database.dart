import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/storage_keys.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  Database? _database;

  // Base de données
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, StorageKeys.databaseName);

    return openDatabase(
      path,
      version: StorageKeys.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Cache offline minimal
    await db.execute('''
      CREATE TABLE ${StorageKeys.cacheTable} (
        cache_key TEXT PRIMARY KEY,
        cache_type TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        expires_at TEXT,
        last_synced_at TEXT,
        etag TEXT,
        server_version TEXT,
        revoked_at TEXT,
        is_stale INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Queue des opérations à synchroniser
    await db.execute('''
      CREATE TABLE ${StorageKeys.syncQueueTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idempotency_key TEXT NOT NULL UNIQUE,
        method TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        body TEXT,
        headers TEXT,
        etag TEXT,
        server_version TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        last_error TEXT
      )
    ''');

    // Journal de synchronisation
    await db.execute('''
      CREATE TABLE sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT NOT NULL,
        operation_id INTEGER,
        cache_key TEXT,
        action TEXT NOT NULL,
        status TEXT NOT NULL,
        message TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Index
    await db.execute('''
      CREATE INDEX idx_cache_type
      ON ${StorageKeys.cacheTable}(cache_type)
    ''');

    await db.execute('''
      CREATE INDEX idx_cache_expiration
      ON ${StorageKeys.cacheTable}(expires_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_status
      ON ${StorageKeys.syncQueueTable}(status)
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_created
      ON ${StorageKeys.syncQueueTable}(created_at)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE ${StorageKeys.cacheTable}
        ADD COLUMN cache_type TEXT NOT NULL DEFAULT 'general'
      ''');

      await db.execute('''
        ALTER TABLE ${StorageKeys.cacheTable}
        ADD COLUMN updated_at TEXT NOT NULL DEFAULT ''
      ''');

      await db.execute('''
        ALTER TABLE ${StorageKeys.cacheTable}
        ADD COLUMN last_synced_at TEXT
      ''');

      await db.execute('''
        ALTER TABLE ${StorageKeys.cacheTable}
        ADD COLUMN etag TEXT
      ''');

      await db.execute('''
        ALTER TABLE ${StorageKeys.cacheTable}
        ADD COLUMN server_version TEXT
      ''');

      await db.execute('''
        ALTER TABLE ${StorageKeys.cacheTable}
        ADD COLUMN revoked_at TEXT
      ''');

      await db.execute('''
        ALTER TABLE ${StorageKeys.cacheTable}
        ADD COLUMN is_stale INTEGER NOT NULL DEFAULT 0
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE ${StorageKeys.syncQueueTable}
        ADD COLUMN idempotency_key TEXT
      ''');

      await db.execute('''
        ALTER TABLE ${StorageKeys.syncQueueTable}
        ADD COLUMN etag TEXT
      ''');

      await db.execute('''
        ALTER TABLE ${StorageKeys.syncQueueTable}
        ADD COLUMN server_version TEXT
      ''');

      await db.execute('''
        ALTER TABLE ${StorageKeys.syncQueueTable}
        ADD COLUMN updated_at TEXT
      ''');

      await db.execute('''
        CREATE TABLE sync_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sync_id TEXT NOT NULL,
          operation_id INTEGER,
          cache_key TEXT,
          action TEXT NOT NULL,
          status TEXT NOT NULL,
          message TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  // Cache minimal
  Future<void> saveCache({
    required String key,
    required String type,
    required dynamic data,
    Duration? duration,
    String? etag,
    String? serverVersion,
    DateTime? lastSyncedAt,
    bool isStale = false,
  }) async {
    final db = await database;

    final now = DateTime.now();

    final expiresAt = duration == null
        ? null
        : now.add(duration).toIso8601String();

    await db.insert(StorageKeys.cacheTable, {
      'cache_key': key,
      'cache_type': type,
      'data': jsonEncode(data),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'expires_at': expiresAt,
      'last_synced_at': (lastSyncedAt ?? now).toIso8601String(),
      'etag': etag,
      'server_version': serverVersion,
      'revoked_at': null,
      'is_stale': isStale ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<dynamic> getCache(
    String key, {
    bool allowExpired = false,
    bool allowRevoked = false,
  }) async {
    final db = await database;

    final results = await db.query(
      StorageKeys.cacheTable,
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;

    // Donnée révoquée
    if (!allowRevoked && row['revoked_at'] != null) {
      return null;
    }

    final expiresAtValue = row['expires_at']?.toString();

    // Donnée expirée
    if (!allowExpired && expiresAtValue != null) {
      final expiresAt = DateTime.tryParse(expiresAtValue);

      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        await _markCacheStale(key);
        return null;
      }
    }

    try {
      return jsonDecode(row['data'].toString());
    } catch (_) {
      return null;
    }
  }

  // Récupérer les métadonnées du cache
  Future<Map<String, dynamic>?> getCacheMetadata(String key) async {
    final db = await database;

    final results = await db.query(
      StorageKeys.cacheTable,
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(results.first);
  }

  // Indicateur de fraîcheur
  Future<String?> getFreshness(String key) async {
    final metadata = await getCacheMetadata(key);

    if (metadata == null) {
      return null;
    }

    if (metadata['revoked_at'] != null) {
      return 'revoked';
    }

    final expiresAt = metadata['expires_at'];

    if (expiresAt != null) {
      final date = DateTime.tryParse(expiresAt.toString());

      if (date != null && DateTime.now().isAfter(date)) {
        return 'expired';
      }
    }

    final isStale = metadata['is_stale'] == 1;

    if (isStale) {
      return 'stale';
    }

    return 'fresh';
  }

  Future<bool> hasValidCache(String key) async {
    final data = await getCache(key);

    return data != null;
  }

  Future<void> _markCacheStale(String key) async {
    final db = await database;

    await db.update(
      StorageKeys.cacheTable,
      {'is_stale': 1},
      where: 'cache_key = ?',
      whereArgs: [key],
    );
  }

  Future<void> markCacheStale(String key) async {
    await _markCacheStale(key);
  }

  // Révoquer une donnée
  Future<void> revokeCache(String key) async {
    final db = await database;

    await db.update(
      StorageKeys.cacheTable,
      {'revoked_at': DateTime.now().toIso8601String(), 'is_stale': 1},
      where: 'cache_key = ?',
      whereArgs: [key],
    );
  }

  Future<void> deleteCache(String key) async {
    final db = await database;

    await db.delete(
      StorageKeys.cacheTable,
      where: 'cache_key = ?',
      whereArgs: [key],
    );
  }

  Future<void> clearCache() async {
    final db = await database;

    await db.delete(StorageKeys.cacheTable);
  }

  Future<void> clearExpiredCache() async {
    final db = await database;

    await db.delete(
      StorageKeys.cacheTable,
      where: 'expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }

  // Queue de synchronisation
  Future<int> addToSyncQueue({
    required String idempotencyKey,
    required String method,
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? headers,
    String? etag,
    String? serverVersion,
  }) async {
    final db = await database;

    final now = DateTime.now().toIso8601String();

    return db.insert(StorageKeys.syncQueueTable, {
      'idempotency_key': idempotencyKey,
      'method': method,
      'endpoint': endpoint,
      'body': body == null ? null : jsonEncode(body),
      'headers': headers == null ? null : jsonEncode(headers),
      'etag': etag,
      'server_version': serverVersion,
      'created_at': now,
      'updated_at': now,
      'attempts': 0,
      'status': 'pending',
      'last_error': null,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;

    return db.query(
      StorageKeys.syncQueueTable,
      where: 'status IN (?, ?)',
      whereArgs: ['pending', 'retry'],
      orderBy: 'created_at ASC',
    );
  }

  Future<Map<String, dynamic>?> getSyncItem(int id) async {
    final db = await database;

    final results = await db.query(
      StorageKeys.syncQueueTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(results.first);
  }

  Future<void> markSyncItemProcessing(int id) async {
    final db = await database;

    final item = await getSyncItem(id);

    if (item == null) {
      return;
    }

    final attempts = (item['attempts'] as int? ?? 0) + 1;

    await db.update(
      StorageKeys.syncQueueTable,
      {
        'status': 'processing',
        'attempts': attempts,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementSyncAttempts(int id, String error) async {
    final db = await database;

    final results = await db.query(
      StorageKeys.syncQueueTable,
      columns: ['attempts'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return;
    }

    final attempts = (results.first['attempts'] as int? ?? 0) + 1;

    await db.update(
      StorageKeys.syncQueueTable,
      {
        'attempts': attempts,
        'status': 'retry',
        'last_error': error,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSyncItemCompleted(int id) async {
    final db = await database;

    await db.update(
      StorageKeys.syncQueueTable,
      {'status': 'completed', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSyncItemConflict(int id, String message) async {
    final db = await database;

    await db.update(
      StorageKeys.syncQueueTable,
      {
        'status': 'conflict',
        'last_error': message,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSyncItemFailed(int id, String error) async {
    final db = await database;

    await db.update(
      StorageKeys.syncQueueTable,
      {
        'status': 'failed',
        'last_error': error,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearSyncQueue() async {
    final db = await database;

    await db.delete(StorageKeys.syncQueueTable);
  }

  // Journal de synchronisation
  Future<int> addSyncLog({
    required String syncId,
    int? operationId,
    String? cacheKey,
    required String action,
    required String status,
    String? message,
  }) async {
    final db = await database;

    return db.insert('sync_log', {
      'sync_id': syncId,
      'operation_id': operationId,
      'cache_key': cacheKey,
      'action': action,
      'status': status,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSyncLogs({int limit = 50}) async {
    final db = await database;

    return db.query('sync_log', orderBy: 'created_at DESC', limit: limit);
  }

  Future<void> clearSyncLogs() async {
    final db = await database;

    await db.delete('sync_log');
  }

  // Gestion globale
  Future<void> clearAll() async {
    await clearCache();
    await clearSyncQueue();
    await clearSyncLogs();
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'local_database.dart';

class OfflineSyncService {
  OfflineSyncService(this._database, this._client);
  final LocalDatabase _database;
  final SupabaseClient _client;

  Future<void> flush() async {
    for (final item in await _database.pendingSync()) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        if (item.entityType == 'task' && item.operation == 'status') {
          await _client.rpc('transition_task', params: payload);
        } else {
          throw UnsupportedError('Unsupported offline operation: ${item.entityType}/${item.operation}');
        }
        await _database.removeSyncItem(item.id);
      } catch (_) {
        await _database.incrementSyncAttempts(item.id);
        rethrow;
      }
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'local_database.dart';
import 'offline_sync_service.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final database = LocalDatabase();
  ref.onDispose(database.close);
  return database;
});

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) => OfflineSyncService(ref.watch(localDatabaseProvider), Supabase.instance.client));

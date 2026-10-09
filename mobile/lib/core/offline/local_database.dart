import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_database.g.dart';

class CachedTasks extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get title => text()();
  TextColumn get status => text()();
  TextColumn get priority => text()();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [CachedTasks, SyncQueue])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(driftDatabase(name: 'enterprise_task_cache'));

  @override
  int get schemaVersion => 1;

  Future<void> replaceTasks(String organizationId, List<Map<String, dynamic>> rows) async {
    await transaction(() async {
      await (delete(cachedTasks)..where((task) => task.organizationId.equals(organizationId))).go();
      await batch((batch) {
        batch.insertAll(
          cachedTasks,
          rows.map((row) => CachedTasksCompanion.insert(
                id: row['id'] as String,
                organizationId: organizationId,
                title: row['title'] as String,
                status: row['status'] as String,
                priority: row['priority'] as String,
                deadline: Value(row['deadline'] == null ? null : DateTime.parse(row['deadline'] as String)),
                progress: Value((row['progress'] as num?)?.toInt() ?? 0),
                version: Value((row['version'] as num?)?.toInt() ?? 1),
              )),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<List<CachedTask>> tasksForOrganization(String organizationId) =>
      (select(cachedTasks)..where((task) => task.organizationId.equals(organizationId))).get();

  Future<int> enqueue(String entityType, String entityId, String operation, Map<String, dynamic> payload) =>
      into(syncQueue).insert(SyncQueueCompanion.insert(entityType: entityType, entityId: entityId, operation: operation, payload: jsonEncode(payload)));

  Future<List<SyncQueueData>> pendingSync() => (select(syncQueue)..orderBy([(row) => OrderingTerm.asc(row.createdAt)])).get();

  Future<void> removeSyncItem(int id) => (delete(syncQueue)..where((row) => row.id.equals(id))).go();

  Future<void> incrementSyncAttempts(int id) async {
    final item = await (select(syncQueue)..where((row) => row.id.equals(id))).getSingle();
    await (update(syncQueue)..where((row) => row.id.equals(id))).write(SyncQueueCompanion(attempts: Value(item.attempts + 1)));
  }
}

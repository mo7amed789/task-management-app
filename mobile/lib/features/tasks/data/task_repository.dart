import 'package:supabase_flutter/supabase_flutter.dart';

class TaskRecord {
  const TaskRecord({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.deadline,
    required this.progress,
    required this.version,
  });

  final String id;
  final String title;
  final String status;
  final String priority;
  final DateTime? deadline;
  final int progress;
  final int version;

  factory TaskRecord.fromJson(Map<String, dynamic> json) => TaskRecord(
        id: json['id'] as String,
        title: json['title'] as String,
        status: json['status'] as String,
        priority: json['priority'] as String,
        deadline: json['deadline'] == null ? null : DateTime.parse(json['deadline'] as String),
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        version: (json['version'] as num?)?.toInt() ?? 1,
      );
}

class TaskRepository {
  TaskRepository(this._client);

  final SupabaseClient _client;

  Future<List<TaskRecord>> listForOrganization(String organizationId) async {
    final rows = await _client.from('tasks').select('id,title,status,priority,deadline,progress,version').eq('organization_id', organizationId).isFilter('archived_at', null).order('deadline', ascending: true);
    return (rows as List<dynamic>).map((row) => TaskRecord.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<TaskRecord> create({required String organizationId, required String projectId, required String title, String? description, String priority = 'normal', DateTime? deadline}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('You must be signed in to create a task.');
    final row = await _client.from('tasks').insert({
      'organization_id': organizationId,
      'project_id': projectId,
      'title': title,
      'description': description,
      'priority': priority,
      'creator_id': userId,
      'deadline': deadline?.toUtc().toIso8601String(),
    }).select('id,title,status,priority,deadline,progress,version').single();
    return TaskRecord.fromJson(row);
  }

  Future<void> updateStatus({required String taskId, required String status, required int version}) async {
    await _client.rpc('transition_task', params: {
      'target_task': taskId,
      'target_status': status,
      'expected_version': version,
    });
  }

  Stream<List<Map<String, dynamic>>> changesForOrganization(String organizationId) => _client.from('tasks').stream(primaryKey: ['id']).eq('organization_id', organizationId);
}

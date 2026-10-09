import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectRecord {
  const ProjectRecord({required this.id, required this.name, required this.status, this.dueOn});
  final String id;
  final String name;
  final String status;
  final DateTime? dueOn;

  factory ProjectRecord.fromJson(Map<String, dynamic> json) => ProjectRecord(
        id: json['id'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        dueOn: json['due_on'] == null ? null : DateTime.parse(json['due_on'] as String),
      );
}

class ProjectRepository {
  ProjectRepository(this._client);
  final SupabaseClient _client;

  Future<List<ProjectRecord>> listForOrganization(String organizationId) async {
    final rows = await _client.from('projects').select('id,name,status,due_on').eq('organization_id', organizationId).neq('status', 'archived').order('due_on', ascending: true);
    return (rows as List<dynamic>).map((row) => ProjectRecord.fromJson(row as Map<String, dynamic>)).toList();
  }
}

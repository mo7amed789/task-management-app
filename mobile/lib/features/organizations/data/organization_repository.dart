import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationRecord {
  const OrganizationRecord({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final String role;

  factory OrganizationRecord.fromJson(Map<String, dynamic> json) => OrganizationRecord(
        id: json['id'] as String,
        name: json['name'] as String,
        role: (json['organization_members'] as List<dynamic>).first['role'] as String,
      );
}

class OrganizationRepository {
  OrganizationRepository(this._client);

  final SupabaseClient _client;

  Future<List<OrganizationRecord>> listMine() async {
    final rows = await _client.from('organizations').select('id,name,organization_members!inner(role)').order('name');
    return (rows as List<dynamic>).map((row) => OrganizationRecord.fromJson(row as Map<String, dynamic>)).toList();
  }
}

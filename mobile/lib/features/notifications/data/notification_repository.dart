import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRecord {
  const NotificationRecord({required this.id, required this.title, required this.body, required this.createdAt, this.readAt});
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  factory NotificationRecord.fromJson(Map<String, dynamic> json) => NotificationRecord(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        readAt: json['read_at'] == null ? null : DateTime.parse(json['read_at'] as String),
      );
}

class NotificationRepository {
  NotificationRepository(this._client);
  final SupabaseClient _client;

  Future<List<NotificationRecord>> listMine() async {
    final rows = await _client.from('notifications').select('id,title,body,created_at,read_at').order('created_at', ascending: false).limit(50);
    return (rows as List<dynamic>).map((row) => NotificationRecord.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<void> markRead(String id) => _client.from('notifications').update({'read_at': DateTime.now().toUtc().toIso8601String()}).eq('id', id);
}

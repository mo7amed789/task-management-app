import 'package:supabase_flutter/supabase_flutter.dart';

class CommentRecord {
  const CommentRecord({required this.id, required this.body, required this.authorId, required this.createdAt});
  final String id;
  final String body;
  final String authorId;
  final DateTime createdAt;

  factory CommentRecord.fromJson(Map<String, dynamic> json) => CommentRecord(
        id: json['id'] as String,
        body: json['body'] as String,
        authorId: json['author_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class CommentRepository {
  CommentRepository(this._client);
  final SupabaseClient _client;

  Future<List<CommentRecord>> listForTask(String taskId) async {
    final rows = await _client.from('task_comments').select('id,body,author_id,created_at').eq('task_id', taskId).order('created_at');
    return (rows as List<dynamic>).map((row) => CommentRecord.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<void> add(String taskId, String body) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('You must be signed in to comment.');
    await _client.from('task_comments').insert({'task_id': taskId, 'author_id': userId, 'body': body.trim()});
  }
}

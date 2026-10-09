import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class AttachmentRepository {
  AttachmentRepository(this._client);
  final SupabaseClient _client;

  Future<void> upload({required String organizationId, required String taskId, required String filePath, required String fileName, required String contentType}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('You must be signed in to upload an attachment.');
    final file = File(filePath);
    final path = '$organizationId/$taskId/${userId}_${DateTime.now().microsecondsSinceEpoch}_$fileName';
    await _client.storage.from('private-attachments').upload(path, file, fileOptions: FileOptions(contentType: contentType, upsert: false));
    await _client.from('task_attachments').insert({'task_id': taskId, 'uploaded_by': userId, 'object_path': path, 'file_name': fileName, 'content_type': contentType, 'byte_size': await file.length()});
  }

  Future<String> createDownloadUrl(String objectPath) => _client.storage.from('private-attachments').createSignedUrl(objectPath, 300);
}

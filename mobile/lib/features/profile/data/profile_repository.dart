import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>> load() async => _client.from('profiles').select('id,display_name,avatar_path,locale').eq('id', _client.auth.currentUser!.id).single();

  Future<void> update({required String displayName, required String locale}) async {
    await _client.from('profiles').update({'display_name': displayName.trim(), 'locale': locale}).eq('id', _client.auth.currentUser!.id);
  }
}

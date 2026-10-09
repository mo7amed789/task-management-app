import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository(Supabase.instance.client));
final profileProvider = FutureProvider((ref) => ref.watch(profileRepositoryProvider).load());

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _name = TextEditingController();
  String _locale = 'en';
  bool _loaded = false;

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile and settings')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load profile: $error')),
        data: (data) {
          if (!_loaded) { _name.text = data['display_name'] as String? ?? ''; _locale = data['locale'] as String? ?? 'en'; _loaded = true; }
          return ListView(padding: const EdgeInsets.all(20), children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Display name')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(initialValue: _locale, decoration: const InputDecoration(labelText: 'Language'), items: const [DropdownMenuItem(value: 'en', child: Text('English')), DropdownMenuItem(value: 'ar', child: Text('العربية'))], onChanged: (value) => setState(() => _locale = value ?? 'en')),
            const SizedBox(height: 24),
            FilledButton(onPressed: () async { await ref.read(profileRepositoryProvider).update(displayName: _name.text, locale: _locale); if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated'))); }, child: const Text('Save changes')),
          ]);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider((ref) => NotificationRepository(Supabase.instance.client));
final notificationsProvider = FutureProvider((ref) => ref.watch(notificationRepositoryProvider).listMine());

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load notifications: $error')),
        data: (items) => items.isEmpty ? const Center(child: Text('You are all caught up.')) : ListView.builder(itemCount: items.length, itemBuilder: (_, index) { final item = items[index]; return ListTile(title: Text(item.title), subtitle: Text(item.body), leading: Icon(item.readAt == null ? Icons.notifications_active : Icons.notifications_none), onTap: () async { await ref.read(notificationRepositoryProvider).markRead(item.id); ref.invalidate(notificationsProvider); }); }),
      ),
    );
  }
}

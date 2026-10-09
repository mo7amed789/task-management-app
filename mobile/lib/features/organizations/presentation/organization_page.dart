import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'organization_providers.dart';

class OrganizationPage extends ConsumerWidget {
  const OrganizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(organizationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Select organization')),
      body: organizations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load organizations: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('You are not a member of an organization yet.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.role),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => ref.read(selectedOrganizationProvider.notifier).state = item.id,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

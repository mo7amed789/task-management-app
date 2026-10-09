import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../authentication/presentation/auth_providers.dart';
import '../../organizations/presentation/organization_page.dart';
import '../../organizations/presentation/organization_providers.dart';
import '../../tasks/presentation/task_list_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final organizationId = ref.watch(selectedOrganizationProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        actions: [IconButton(onPressed: () => ref.read(authRepositoryProvider).signOut(), icon: const Icon(Icons.logout))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Hello, ${user?.userMetadata?['display_name'] ?? user?.email ?? 'there'}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Your work, deadlines, and collaboration in one place.'),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: organizationId == null ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrganizationPage())) : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaskListPage())), icon: Icon(organizationId == null ? Icons.business : Icons.checklist), label: Text(organizationId == null ? 'Choose organization' : 'View my tasks')),
          if (organizationId != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () => context.go('/projects'), icon: const Icon(Icons.folder_outlined), label: const Text('Browse projects')),
          ],
        ]),
      ),
    );
  }
}

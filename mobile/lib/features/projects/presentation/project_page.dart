import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../organizations/presentation/organization_providers.dart';
import '../data/project_repository.dart';

final projectRepositoryProvider = Provider((ref) => ProjectRepository(Supabase.instance.client));
final projectsProvider = FutureProvider<List<ProjectRecord>>((ref) {
  final id = ref.watch(selectedOrganizationProvider);
  return id == null ? Future.value(const []) : ref.watch(projectRepositoryProvider).listForOrganization(id);
});

class ProjectPage extends ConsumerWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: projects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load projects: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No active projects yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return Card(child: ListTile(title: Text(item.name), subtitle: Text(item.status), trailing: item.dueOn == null ? null : Text(DateFormat.yMMMd().format(item.dueOn!))));
                },
              ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/task_repository.dart';
import '../../organizations/presentation/organization_providers.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository(Supabase.instance.client));

final tasksProvider = FutureProvider<List<TaskRecord>>((ref) {
  final organizationId = ref.watch(selectedOrganizationProvider);
  if (organizationId == null) return Future.value(const []);
  return ref.watch(taskRepositoryProvider).listForOrganization(organizationId);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/task_repository.dart';
import 'task_providers.dart';
import 'task_details_page.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My tasks')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tasksProvider.future),
        child: tasks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('Unable to load tasks: $error'))]),
          data: (items) => items.isEmpty
              ? ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No tasks yet.')))])
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => _TaskTile(task: items[index]),
                ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});
  final TaskRecord task;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(task.title),
          subtitle: Text('${task.status} · ${task.priority}${task.deadline == null ? '' : ' · due ${DateFormat.yMMMd().format(task.deadline!.toLocal())}'}'),
          trailing: SizedBox(width: 52, child: Text('${task.progress}%')),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskDetailsPage(task: task))),
        ),
      );
}

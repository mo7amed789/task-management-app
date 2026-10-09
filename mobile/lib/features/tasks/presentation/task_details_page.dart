import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/task_repository.dart';
import '../../comments/data/comment_repository.dart';
import 'task_providers.dart';

final commentRepositoryProvider = Provider((ref) => CommentRepository(Supabase.instance.client));

class TaskDetailsPage extends ConsumerStatefulWidget {
  const TaskDetailsPage({required this.task, super.key});
  final TaskRecord task;

  @override
  ConsumerState<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends ConsumerState<TaskDetailsPage> {
  late String _status;
  bool _saving = false;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(String? value) async {
    if (value == null || value == _status) return;
    setState(() => _saving = true);
    try {
      await ref.read(taskRepositoryProvider).updateStatus(taskId: widget.task.id, status: value, version: widget.task.version);
      if (mounted) setState(() => _status = value);
      ref.invalidate(tasksProvider);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update task: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Task details')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text(widget.task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(initialValue: _status, decoration: const InputDecoration(labelText: 'Status'), items: const [
            DropdownMenuItem(value: 'backlog', child: Text('Backlog')),
            DropdownMenuItem(value: 'todo', child: Text('To do')),
            DropdownMenuItem(value: 'in_progress', child: Text('In progress')),
            DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
            DropdownMenuItem(value: 'in_review', child: Text('In review')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
          ], onChanged: _saving ? null : _changeStatus),
          const SizedBox(height: 24),
          LinearProgressIndicator(value: widget.task.progress / 100),
          const SizedBox(height: 8),
          Text('${widget.task.progress}% complete'),
          const SizedBox(height: 28),
          Text('Comments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          FutureBuilder<List<CommentRecord>>(
            future: ref.read(commentRepositoryProvider).listForTask(widget.task.id),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
              if (snapshot.hasError) return Text('Unable to load comments: ${snapshot.error}');
              final comments = snapshot.data ?? const <CommentRecord>[];
              return Column(children: [
                for (final comment in comments) ListTile(contentPadding: EdgeInsets.zero, title: Text(comment.body), subtitle: Text(comment.createdAt.toLocal().toString())),
                TextField(controller: _commentController, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Add a comment')),
                const SizedBox(height: 8),
                Align(alignment: AlignmentDirectional.centerEnd, child: OutlinedButton(onPressed: () async { final body = _commentController.text.trim(); if (body.isEmpty) return; await ref.read(commentRepositoryProvider).add(widget.task.id, body); _commentController.clear(); if (mounted) setState(() {}); }, child: const Text('Post comment'))),
              ]);
            },
          ),
        ]),
      );
}

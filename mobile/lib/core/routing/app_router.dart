import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../../features/authentication/presentation/login_page.dart';
import '../../features/authentication/presentation/register_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/organizations/presentation/organization_page.dart';
import '../../features/projects/presentation/project_page.dart';
import '../../features/notifications/presentation/notification_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/tasks/presentation/task_list_page.dart';

final appRouter = GoRouter(
  redirect: (_, state) {
    if (!AppConfig.isConfigured) return null;
    final signedIn = Supabase.instance.client.auth.currentSession != null;
    final isLogin = state.matchedLocation == '/login' || state.matchedLocation == '/';
    if (!signedIn && !isLogin) return '/login';
    if (signedIn && isLogin) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const _HomePage(),
    ),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
    GoRoute(path: '/organizations', builder: (_, __) => const OrganizationPage()),
    GoRoute(path: '/projects', builder: (_, __) => const ProjectPage()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationPage()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/tasks', builder: (_, __) => const TaskListPage()),
  ],
);

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Task Management')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sign in to continue'),
          ),
        ),
      );
}

import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/organizations/presentation/organization_page.dart';
import '../../features/projects/presentation/project_page.dart';
import '../../features/notifications/presentation/notification_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/tasks/presentation/task_list_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const DashboardPage(),
    ),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
    GoRoute(path: '/organizations', builder: (_, __) => const OrganizationPage()),
    GoRoute(path: '/projects', builder: (_, __) => const ProjectPage()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationPage()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/tasks', builder: (_, __) => const TaskListPage()),
  ],
);

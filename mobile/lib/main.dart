import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.validate();
  if (AppConfig.isConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }
  runApp(const EnterpriseTaskManagementApp());
}

class EnterpriseTaskManagementApp extends StatelessWidget {
  const EnterpriseTaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Task Management',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: appRouter,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
      );
}

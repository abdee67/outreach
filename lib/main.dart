import 'package:flutter/material.dart';
import 'package:outreach/services/notifications/notification_service.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const OutreachApp());
}

class OutreachApp extends StatelessWidget {
  const OutreachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outreach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}

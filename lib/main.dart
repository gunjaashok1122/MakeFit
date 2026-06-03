import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/fitness_provider.dart';
import 'services/notification_service.dart';
import 'themes/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service wrappers asynchronously (non-blocking)
  NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FitnessProvider>(
          create: (context) => FitnessProvider(),
          update: (context, auth, fitness) => fitness!..updateUser(auth.userId),
        ),
      ],
      child: const MakeFitApp(),
    ),
  );
}

class MakeFitApp extends StatelessWidget {
  const MakeFitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Make Fit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // We fall back to premium dark default
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}

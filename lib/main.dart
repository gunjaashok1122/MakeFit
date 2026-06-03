import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/fitness_provider.dart';
import 'services/notification_service.dart';
import 'themes/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the provided configuration parameters
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCK_qIFO_nfe3p32Ozs42lBOg6Ny8zCSUA",
        authDomain: "make-fit-48502.firebaseapp.com",
        projectId: "make-fit-48502",
        storageBucket: "make-fit-48502.firebasestorage.app",
        messagingSenderId: "1088596469711",
        appId: "1:1088596469711:web:d13aa53c6ef5a56034d4ba",
        measurementId: "G-YD00299DK4",
      ),
    );
    print("Firebase initialized successfully with make-fit config.");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  
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
      builder: (context, child) {
        return ClipRect(
          child: Container(
            color: const Color(0xFF060713), // outer deep background
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }
}

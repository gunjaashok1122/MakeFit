// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:makefit/providers/auth_provider.dart';
import 'package:makefit/providers/theme_provider.dart';
import 'package:makefit/providers/fitness_provider.dart';
import 'package:makefit/main.dart';

void main() {
  testWidgets('App renders splash screen successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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

    // Verify that the splash screen displays the app name.
    expect(find.text('Make Fit'), findsOneWidget);
    expect(find.text('Your Health, Your Strength'), findsOneWidget);
  });
}

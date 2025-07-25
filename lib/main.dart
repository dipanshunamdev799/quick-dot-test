import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Imports for a complete and correct dependency injection ---
import 'package:quick_dot_test/src/data/datasources/user_api.dart';
import 'package:quick_dot_test/src/data/repositories/user_repository.dart';
import 'package:quick_dot_test/src/logic/user_provider.dart';
// -------------------------------------------------------------

import 'package:quick_dot_test/src/core/theme/app_theme.dart';
import 'package:quick_dot_test/src/presentation/screens/auth_screen.dart';
import 'firebase_options.dart'; // Generated by FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // FIXED: Create and provide UserProvider with its required repository.
        ChangeNotifierProvider(
          create: (_) => UserProvider(
            userRepository: UserRepository(
              dataSource: UserApiDataSource(),
            ),
          ),
        ),
        // You can add other providers here in the future
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Dot Test',
      // --- Use the themes here ---
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically switch based on system settings
      // --------------------------
      home: const AuthScreen(),
    );
  }
}
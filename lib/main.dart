import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'firebase_options.dart'; // Import generated options
// Duplicate import removed

// Import the custom theme
import 'package:planner/presentation/theme/app_theme.dart';
// Import the app shell (default entry point for offline-first)
import 'package:planner/presentation/navigation/main_app_shell.dart'; // Restore as initial home
// import 'package:planner/presentation/navigation/splash_screen.dart'; // Remove SplashScreen import
// AuthWrapper will be imported and used later
// import 'package:planner/features/auth/presentation/view/auth_wrapper.dart';

// Make main async
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app
  runApp(
    const ProviderScope(
      // Keep ProviderScope for Riverpod
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planner App',
      // Apply the custom dark theme
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      // Use MainAppShell with improved navigation
      home: const MainAppShell(),
      // Add theme mode for system preference support
      themeMode: ThemeMode.dark,
      // Add responsive design settings
      builder: (context, child) {
        // Apply text scaling factor limit for better UI consistency
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

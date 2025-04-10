import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'firebase_options.dart'; // Import generated options

// Import the custom theme
import 'package:planner/presentation/theme/app_theme.dart';
// Import the app shell (default entry point for offline-first)
import 'package:planner/presentation/navigation/main_app_shell.dart';
// AuthWrapper will be imported and used later
// import 'package:planner/features/auth/presentation/view/auth_wrapper.dart';

// Make main async
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Initialize Firebase conditionally based on platform
  if (kIsWeb) {
    // For web, use environment variables passed during build
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
        appId: String.fromEnvironment('FIREBASE_APP_ID'),
        messagingSenderId: String.fromEnvironment(
          'FIREBASE_MESSAGING_SENDER_ID',
        ),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
        authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
        measurementId: String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
      ),
    );
  } else {
    // For non-web platforms, attempt to use the generated options
    // This part might need adjustment if you add support for other platforms
    // without using the FlutterFire CLI for them.
    // The original DefaultFirebaseOptions.currentPlatform logic is kept here.
    FirebaseOptions options;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        // Assuming you might eventually have DefaultFirebaseOptions.ios defined
        // If not, this will need specific options or throw an error.
        // options = DefaultFirebaseOptions.ios; // Example if defined elsewhere
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS using environment variables.',
        );
      case TargetPlatform.macOS:
        // Assuming you might eventually have DefaultFirebaseOptions.macos defined
        // options = DefaultFirebaseOptions.macos; // Example if defined elsewhere
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS using environment variables.',
        );
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
    // await Firebase.initializeApp(options: options); // Uncomment and adjust if needed
  }

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

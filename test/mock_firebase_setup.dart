import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock Firebase Core Platform Interface
// Based on: https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core/test/mock.dart

typedef Callback = void Function(MethodCall call);

// Function to setup the mock handlers
Future<void> setupFirebaseCoreMocks() async {
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        MethodChannel('plugins.flutter.io/firebase_core'),
        (call) async {
          if (call.method == 'Firebase#initializeCore') {
            return [
              {
                'name': defaultFirebaseAppName,
                'options': {
                  'apiKey': 'mock_api_key',
                  'appId': 'mock_app_id',
                  'messagingSenderId': 'mock_sender_id',
                  'projectId': 'mock_project_id',
                  'storageBucket': 'mock_storage_bucket',
                },
                'pluginConstants': {},
              },
            ];
          }
          if (call.method == 'Firebase#initializeApp') {
            return {
              'name': call.arguments['appName'],
              'options': call.arguments['options'],
              'pluginConstants': {},
            };
          }
          return null;
        },
      );
}

// Helper to mock a specific Firebase service channel
void setupFirebaseMockService(String channelName, String serviceName) {
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannel(channelName), (call) async {
        // You might need to add specific mock responses here
        // if your tests interact directly with other Firebase services (Auth, Firestore, etc.)
        // For now, a basic handler might suffice for initialization tests.
        print('Mock $serviceName call: ${call.method}');
        return null;
      });
}

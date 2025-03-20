import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khoras_5_6/Cubits/add_score_cubit.dart';
import 'package:khoras_5_6/services/notification_service.dart';
import 'package:khoras_5_6/staff_screen.dart';
import 'package:khoras_5_6/widgets/color_schemes.g.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Cubits/get_staff_cubit.dart';
import 'firebase_options.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // Add logic here if needed for background messages
  print('Background message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Optionally show a fallback UI in runApp if critical
  }

  // Initialize Notification Service
  final NotificationService notificationService = NotificationService();
  try {
    await notificationService.initialize();
    print('Notification service initialized successfully');
  } catch (e) {
    print('Notification service initialization error: $e');
  }

  // Set up Firebase Messaging
  try {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM token: $token');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  } catch (e) {
    print('FCM setup error: $e');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://wcfcaiqlmlxmkamtwtml.supabase.co',
      anonKey:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndjZmNhaXFsbWx4bWthbXR3dG1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIwMzAwNDMsImV4cCI6MjA1NzYwNjA0M30.5kVBktCPHPdPON4SIsw68zNabzDzZkPbZkDcPIwWEmo',
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Supabase initialization error: $e');
  }

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    try {
      if (message.notification != null) {
        String? imageUrl = message.data['imageUrl'] ?? message.notification!.android?.imageUrl;
        notificationService.showNotification(
          title: message.notification!.title ?? 'No Title',
          body: message.notification!.body ?? 'No Body',
          imageUrl: imageUrl,
        );
        print('Foreground message received: ${message.messageId}');
      }
    } catch (e) {
      print('Error handling foreground notification: $e');
    }
  });

  // Handle notification opening
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('App opened from notification: ${message.data}');
  });

  // Request permissions (non-blocking)
  await Permission.notification.request();
  await Permission.camera.request();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetStaffCubit()),
        BlocProvider(create: (context) => AddScoreCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        title: 'Khoras 5-6',
        home: const StaffScreen(),
      ),
    );
  }
}
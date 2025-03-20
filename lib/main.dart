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

Future<void> handleBackgroundMessage(RemoteMessage message) async {}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Notification Service
    final NotificationService notificationService = NotificationService();
    await notificationService.initialize();
    await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    await Supabase.initialize(
      url: 'https://wcfcaiqlmlxmkamtwtml.supabase.co',
      anonKey:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndjZmNhaXFsbWx4bWthbXR3dG1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIwMzAwNDMsImV4cCI6MjA1NzYwNjA0M30.5kVBktCPHPdPON4SIsw68zNabzDzZkPbZkDcPIwWEmo',
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String? imageUrl =
            message.data['imageUrl'] ?? message.notification!.android?.imageUrl;

        notificationService.showNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          imageUrl: imageUrl,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    Permission.notification.request();
    Permission.camera.request();
  }catch(e){
    print('Error initializing: $e');
  }

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
        BlocProvider(
          create: (context) => GetStaffCubit(),
        ),
        BlocProvider(
          create: (context) => AddScoreCubit(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme:
              ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          title: 'Khoras 5-6',
          home: const StaffScreen()),
    );
  }
}

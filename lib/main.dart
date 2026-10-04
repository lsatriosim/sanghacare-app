import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/notifications/data/push_notification_service.dart';

// Top-level entry point required for background FCM message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 2. Fetch environment variables safely
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Guard against launch crashes when running standalone without dart-define
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint('❌ CRITICAL: SUPABASE_URL or SUPABASE_ANON_KEY is missing!');
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await Firebase.initializeApp();

  runApp(const ProviderScope(child: SanghaCareStaffApp()));
}

class SanghaCareStaffApp extends ConsumerStatefulWidget {
  const SanghaCareStaffApp({super.key});

  @override
  ConsumerState<SanghaCareStaffApp> createState() => _SanghaCareStaffAppState();
}

class _SanghaCareStaffAppState extends ConsumerState<SanghaCareStaffApp> {
  @override
  Widget build(BuildContext context) {
    // Register for push once we have a signed-in user.
    ref.listen(authControllerProvider, (previous, next) {
      final user = next.value;
      if (user != null && previous?.value?.id != user.id) {
        PushNotificationService(Supabase.instance.client).initialize(user.id);
      }
    });

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'SanghaCare Staff',
      theme: buildAppTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
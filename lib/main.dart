import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/notifications/data/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
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

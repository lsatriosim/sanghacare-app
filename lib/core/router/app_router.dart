import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/tickets/presentation/screens/ticket_list_screen.dart';

part 'app_router.g.dart';

/// A ChangeNotifier that go_router can listen to, bridging Riverpod's
/// async auth state into the imperative `Listenable` API GoRouter expects.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

@riverpod
GoRouter appRouter(Ref ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/tickets',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isSignedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      // Still resolving the initial auth check — don't redirect yet.
      if (authState.isLoading) return null;

      if (!isSignedIn && !isLoggingIn) return '/login';
      if (isSignedIn && isLoggingIn) return '/tickets';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/tickets', builder: (context, state) => const TicketListScreen()),
    ],
  );
}

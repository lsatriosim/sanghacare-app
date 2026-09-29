import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client);
}

/// Holds the currently signed-in user (or null). The router watches this
/// to decide whether to show the login screen or the ticket list.
@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<User?> build() {
    final repo = ref.watch(authRepositoryProvider);

    // Emit the current user immediately, then follow subsequent changes.
    return repo.authStateChanges.map((state) => state.session?.user).asBroadcastStream()
      ..listen((_) {}); // keep hot for late subscribers (go_router refresh)
  }

  Future<String?> signIn(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);

    try {
      await repo.signInWithEmail(email: email, password: password);
    } on AuthException catch (e) {
      return e.message; // returned to the UI to show under the form
    }

    final userId = repo.currentUser?.id;
    if (userId == null) return 'Sign in failed. Please try again.';

    final allowed = await repo.isStaff(userId);
    if (!allowed) {
      await repo.signOut();
      return 'This account is not registered as staff.';
    }

    return null; // null == success
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}

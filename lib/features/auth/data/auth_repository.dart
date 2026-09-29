import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  /// Fires on sign-in, sign-out, and token refresh — this is what the
  /// router listens to for its redirect logic.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Confirms the signed-in account actually has the `staff` role before
  /// letting them into this app — the same `profiles.role` check the web
  /// admin page uses.
  Future<bool> isStaff(String userId) async {
    final row = await _client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    final role = (row?['role'] as String?)?.toLowerCase();
    return role == 'staff' || role == 'admin';
  }
}

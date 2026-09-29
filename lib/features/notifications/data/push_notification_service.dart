import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Registers this device for push notifications and keeps the token in
/// sync with Supabase. Call [initialize] once, after the user is signed
/// in (we need their profile id to attach the token to).
///
/// Note: iOS requires explicit permission (handled here) and a real
/// Apple Push Notification key configured in your Firebase project —
/// the FCM token itself is what Firebase uses to relay to APNs, so this
/// same code path covers both platforms.
class PushNotificationService {
  PushNotificationService(this._client);

  final SupabaseClient _client;
  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize(String profileId) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Push notifications denied by user.');
      return;
    }

    final token = await _messaging.getToken();
    if (token != null) {
      await _upsertToken(profileId, token);
    }

    // Token can rotate (app reinstall, OS-level refresh) — keep it current.
    _messaging.onTokenRefresh.listen((newToken) => _upsertToken(profileId, newToken));
  }

  Future<void> _upsertToken(String profileId, String token) async {
    await _client.from('push_subscriptions').upsert(
      {
        'profile_id': profileId,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'subscription': {'token': token},
        'last_used_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'profile_id, platform',
    );
  }

  /// Call on sign-out so a shared/reused device stops receiving this
  /// user's notifications.
  Future<void> removeTokenForCurrentDevice(String profileId) async {
    final token = await _messaging.getToken();
    if (token == null) return;

    await _client
        .from('push_subscriptions')
        .delete()
        .eq('profile_id', profileId)
        .eq('subscription->>token', token);
  }
}

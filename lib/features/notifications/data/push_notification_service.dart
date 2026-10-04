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

    debugPrint('Notification Authorization Status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Push notifications denied by user.');
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Check if APNs token is already present
      String? apnsToken = await _messaging.getAPNSToken();
      debugPrint('Initial APNs Token check: $apnsToken');

      int attempts = 0;
      while (apnsToken == null && attempts < 10) {
        await Future.delayed(const Duration(seconds: 1));
        apnsToken = await _messaging.getAPNSToken();
        attempts++;
        debugPrint('Waiting for APNs token... Attempt $attempts/10');
      }

      if (apnsToken == null) {
        debugPrint('❌ TIMEOUT: APNs token is null. This usually means:');
        debugPrint('1. You are running on a simulator (must use a physical device).');
        debugPrint('2. "Push Notifications" capability is missing in Xcode Signing & Capabilities.');
        debugPrint('3. Your provisioning profile does not support push notifications.');
        return;
      }
      debugPrint('✅ APNs Token obtained successfully: $apnsToken');
    }

    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    
    if (token != null) {
      await _upsertToken(profileId, token);
    }

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
    // For iOS on sign out, we can safely skip waiting for APNs if it's already cleared,
    // but we still want to grab the FCM token if available.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) return;
    }

    final token = await _messaging.getToken();
    if (token == null) return;

    await _client
        .from('push_subscriptions')
        .delete()
        .eq('profile_id', profileId)
        .eq('subscription->>token', token);
  }
}
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  PushNotificationService(this._client);

  final SupabaseClient _client;
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

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

    // 1. Configure iOS foreground presentation to show alert and play sound
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Create high priority notification channel for Android (plays sound on Android 8+)
    if (defaultTargetPlatform == TargetPlatform.android) {
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important ticket alerts.',
        importance: Importance.max,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
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
        debugPrint('❌ TIMEOUT: APNs token is null.');
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
        'subscription': {'fcm_token': token},
        'last_used_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'profile_id, platform',
    );
  }

  Future<void> removeTokenForCurrentDevice(String profileId) async {
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
        .eq('platform', defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');
  }
}
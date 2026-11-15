import 'dart:async';
import 'dart:js_interop';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  Future<AuthorizationStatus> requestPermission() async {
    if (kIsWeb) {
      try {
        final perm = await web.Notification.requestPermission().toDart;
        final status = switch (perm.toDart) {
          'granted' => AuthorizationStatus.authorized,
          'denied' => AuthorizationStatus.denied,
          _ => AuthorizationStatus.notDetermined,
        };
        debugPrint('Notification permission: ${status.name}');
        return status;
      } catch (e) {
        debugPrint('Web notification permission error: $e');
        return AuthorizationStatus.notDetermined;
      }
    }

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('Notification permission: ${settings.authorizationStatus.name}');
      return settings.authorizationStatus;
    } catch (e) {
      debugPrint('Notification permission error: $e');
      return AuthorizationStatus.notDetermined;
    }
  }

  Future<String?> getToken() async {
    try {
      debugPrint('FCM: Meminta token ke server Firebase...');
      final token = await _messaging
          .getToken(
            vapidKey: kIsWeb
                ? 'BDNTe7cuWQojg-Me9y6CdbxKjVtYfHUUSCkhdHrorUYmtBxvAl4MnFRnkNO0Pr0Vb_X1HFknpJVicYx3snG9LiY'
                : null,
          )
          .timeout(const Duration(seconds: 10));
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('FCM getToken error: $e');
      return null;
    }
  }

  void listenTokenRefresh(void Function(String token) onRefresh) {
    try {
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token diperbarui');
        onRefresh(newToken);
      });
    } catch (e) {
      debugPrint('FCM onTokenRefresh error: $e');
    }
  }

  Future<void> saveTokenToSupabase(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('device_tokens').upsert({
      'token': token,
      'user_id': user.id,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
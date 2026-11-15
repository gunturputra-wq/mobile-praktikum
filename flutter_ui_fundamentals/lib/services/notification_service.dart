import 'dart:async';
import 'dart:js_interop';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

import '../firebase_options.dart';
import '../main.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[BACKGROUND] ${message.notification?.title}');
  debugPrint('[BACKGROUND] ${message.notification?.body}');
}

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
          .timeout(const Duration(seconds: 30));
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

  Future<void> init() async {
    await requestPermission();

    final token = await getToken();
    if (token != null) {
      try {
        await saveTokenToSupabase(token);
      } catch (e) {
        debugPrint('Supabase saveToken skipped: $e');
      }
    }
    listenTokenRefresh((newToken) async {
      try {
        await saveTokenToSupabase(newToken);
      } catch (e) {
        debugPrint('Supabase saveToken refresh skipped: $e');
      }
    });

    if (!kIsWeb) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // FOREGROUND: aplikasi sedang terbuka
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FOREGROUND] Notification received');
      debugPrint('title: ${message.notification?.title}');
      debugPrint('body : ${message.notification?.body}');
      debugPrint('data : ${message.data}');

      final title = message.notification?.title ?? 'Notifikasi';
      final body = message.notification?.body ?? '';
      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('$title\n$body')),
      );
    });
  }
}
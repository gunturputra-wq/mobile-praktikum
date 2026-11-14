import 'dart:js_interop';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@JS('Notification.requestPermission')
external JSPromise<JSString> _webRequestNotificationPermission();

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<AuthorizationStatus> requestPermission() async {
    if (kIsWeb) {
      try {
        final result = (await _webRequestNotificationPermission().toDart).toDart;
        final status = switch (result) {
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
}
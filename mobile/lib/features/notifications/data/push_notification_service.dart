import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  PushNotificationService(this._client);

  final SupabaseClient _client;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: DarwinInitializationSettings());
    await _local.initialize(settings);
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken();
    if (token != null) await _registerToken(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _registerToken(String token) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('device_tokens').upsert({'user_id': userId, 'token': token, 'platform': 'android', 'last_seen_at': DateTime.now().toUtc().toIso8601String()}, onConflict: 'token');
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const details = NotificationDetails(android: AndroidNotificationDetails('task_updates', 'Task updates', channelDescription: 'Task and collaboration updates', importance: Importance.high, priority: Priority.high));
    await _local.show(notification.hashCode, notification.title, notification.body, details);
  }
}

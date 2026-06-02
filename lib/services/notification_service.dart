// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/mocktest_model.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final RxInt unreadCount = 0.obs;

  Future<void> initialize() async {
    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
    );

    // Setup local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel
    const channel = AndroidNotificationChannel(
      'suman_sir_academy_channel',
      'Suman Sir Academy',
      description: 'Notifications from Suman Sir English Academy',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Listen to FCM messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Get and save FCM token
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveToken(token);
    }

    _fcm.onTokenRefresh.listen(_saveToken);
  }

  Future<void> _saveToken(String token) async {
    // This will be called when user is logged in
    // Save in shared prefs for now, save to Firestore when user logs in
  }

  Future<void> saveTokenToFirestore(String userId) async {
    final token = await _fcm.getToken();
    if (token != null && userId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Suman Sir Academy',
        body: notification.body ?? '',
        payload: message.data['type'],
      );
    }
    unreadCount.value++;
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _navigateFromNotification(message.data['type']);
  }

  void _onNotificationTap(NotificationResponse response) {
    _navigateFromNotification(response.payload);
  }

  void _navigateFromNotification(String? type) {
    // Navigate based on notification type
    switch (type) {
      case 'live_class':
        Get.toNamed('/live-class');
        break;
      case 'mocktest':
        Get.toNamed('/mocktest-list');
        break;
      default:
        Get.toNamed('/notifications');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'suman_sir_academy_channel',
      'Suman Sir Academy',
      channelDescription: 'Notifications from Suman Sir English Academy',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  // Called by admin to send notification to all students
  Future<void> sendNotificationToTopic({
    required String title,
    required String body,
    required String type,
    String? topic,
  }) async {
    // This should be done via a Cloud Function or your backend
    // Storing in Firestore triggers the Cloud Function
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'type': type,
      'topic': topic ?? 'all_students',
      'isImportant': false,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  Stream<List<NotificationModel>> getNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationModel.fromFirestore).toList());
  }
}

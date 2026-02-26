import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for handling push notifications with professional UI
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Callback for when notification is tapped
  static Function(String? payload)? onNotificationTap;

  /// Android notification channel for high importance notifications
  static const AndroidNotificationChannel _highImportanceChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Android notification channel for general notifications
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'default_channel',
    'General Notifications',
    description: 'This channel is used for general notifications.',
    importance: Importance.defaultImportance,
    playSound: true,
  );

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize local notifications
    await _initializeLocalNotifications();

    // Create notification channels for Android
    await _createNotificationChannels();

    // Set up Firebase messaging handlers
    _setupFirebaseMessaging();

    debugPrint('NotificationService initialized');
  }

  /// Initialize flutter_local_notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings - use custom notification icon
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_highImportanceChannel);
        await androidPlugin.createNotificationChannel(_defaultChannel);
      }
    }
  }

  /// Set up Firebase messaging handlers
  void _setupFirebaseMessaging() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when app is opened from notification (background state)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Check if app was opened from a terminated state notification
    _checkInitialMessage();
  }

  /// Check if app was opened from a notification when terminated
  Future<void> _checkInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      _handleNotificationOpen(initialMessage);
    }
  }

  /// Handle foreground messages - show local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');

    final notification = message.notification;

    // Show local notification for foreground messages
    if (notification != null) {
      await showNotification(
        id: message.hashCode,
        title: notification.title ?? 'Picky Load',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
        isHighPriority: true,
      );
    }
  }

  /// Handle notification tap when app is in background
  void _handleNotificationOpen(RemoteMessage message) {
    debugPrint('Notification opened: ${message.messageId}');

    // Convert data to payload string
    final payload = jsonEncode(message.data);

    // Call the callback if set
    onNotificationTap?.call(payload);
  }

  /// Callback for local notification tap
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    onNotificationTap?.call(response.payload);
  }

  /// Callback for background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint('Background notification tapped: ${response.payload}');
    // This runs in isolate, can't directly call callbacks
    // The app will handle this via getInitialMessage or onMessageOpenedApp
  }

  /// Show a local notification with professional UI
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isHighPriority = false,
    String? imageUrl,
  }) async {
    // Android notification details
    final androidDetails = AndroidNotificationDetails(
      isHighPriority ? _highImportanceChannel.id : _defaultChannel.id,
      isHighPriority ? _highImportanceChannel.name : _defaultChannel.name,
      channelDescription: isHighPriority
          ? _highImportanceChannel.description
          : _defaultChannel.description,
      importance: isHighPriority ? Importance.high : Importance.defaultImportance,
      priority: isHighPriority ? Priority.high : Priority.defaultPriority,
      icon: '@drawable/ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/app_icon'),
      playSound: true,
      enableVibration: true,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
      ),
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      color: const Color(0xFF6200EE), // Your app's primary color
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Show a notification with big picture (for promotions, etc.)
  Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
    String? payload,
  }) async {
    final bigPictureStyle = BigPictureStyleInformation(
      const DrawableResourceAndroidBitmap('@mipmap/app_icon'),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/app_icon'),
      contentTitle: title,
      htmlFormatContentTitle: true,
    );

    final androidDetails = AndroidNotificationDetails(
      _highImportanceChannel.id,
      _highImportanceChannel.name,
      channelDescription: _highImportanceChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/app_icon'),
      styleInformation: bigPictureStyle,
      color: const Color(0xFF6200EE),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  /// Show a progress notification (for uploads, etc.)
  Future<void> showProgressNotification({
    required int id,
    required String title,
    required int progress,
    required int maxProgress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _defaultChannel.id,
      _defaultChannel.name,
      channelDescription: _defaultChannel.description,
      importance: Importance.low,
      priority: Priority.low,
      icon: '@drawable/ic_notification',
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      ongoing: progress < maxProgress,
      autoCancel: progress >= maxProgress,
    );

    await _localNotifications.show(
      id,
      title,
      progress >= maxProgress ? 'Completed' : 'In progress...',
      NotificationDetails(android: androidDetails),
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _localNotifications.pendingNotificationRequests();
    return pending.length;
  }
}

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Background messages are automatically shown by FCM on Android
  // For custom handling, you can process the message here
}

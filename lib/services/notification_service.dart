import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, debugPrint, TargetPlatform;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../l10n/l10n_lookup.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isSupported =>
      !kIsWeb &&
      defaultTargetPlatform != TargetPlatform.windows &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  NotificationService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (!isSupported) {
        debugPrint('Notifications not supported on this platform');
        return;
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await requestPermissions();
      _isInitialized = true;
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> showEarthquakeNotification({
    required double magnitude,
    required String place,
    required DateTime time,
  }) async {
    if (!_isInitialized || !isSupported) {
      debugPrint('Notification service not initialized');
      return;
    }

    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        debugPrint('No notification permission');
        return;
      }

      final channelName =
          await localizedString('notificationChannelName');
      final channelDesc =
          await localizedString('notificationChannelDesc');
      final title = await localizedString(
        'earthquakeTitle',
        {'magnitude': magnitude.toStringAsFixed(1)},
      );
      final body = await localizedString(
        'notificationMagnitudePlace',
        {
          'magnitude': magnitude.toStringAsFixed(1),
          'place': place,
        },
      );

      final androidDetails = AndroidNotificationDetails(
        'earthquake_channel',
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(body),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        time.millisecondsSinceEpoch % 100000,
        title,
        place,
        details,
      );

      debugPrint('Notification sent: M$magnitude at $place');
    } catch (e) {
      debugPrint('Notification show error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (!isSupported) {
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }

    return false;
  }
}

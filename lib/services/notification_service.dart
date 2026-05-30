import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._init();

  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    try {
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          // Handle notification click action
          print('Notification clicked: ${details.payload}');
        },
      );
      _isInitialized = true;
      print('Notification Service Initialized successfully.');
    } catch (e) {
      print('Failed to initialize local notifications (might be running on unsupported platform): $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    print('[NOTIFICATION TRIGGERED] ID: $id | Title: $title | Body: $body');

    if (!_isInitialized) {
      // Stub callback for testing/unsupported platform
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'makefit_reminders',
        'Make Fit Reminders',
        channelDescription: 'Hydration and workout alerts for Make Fit',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      print('Failed to display local notification: $e');
    }
  }

  Future<void> scheduleHydrationReminder() async {
    await showNotification(
      id: 999,
      title: 'Time to Hydrate! 💧',
      body: 'Keep your metabolism active. Drink 250ml of water now.',
    );
  }

  Future<void> scheduleWorkoutReminder() async {
    await showNotification(
      id: 998,
      title: 'Ready for your workout? 🏋️',
      body: 'Get active today! Log your exercise and keep your streak alive.',
    );
  }
}

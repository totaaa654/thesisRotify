import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showSpoilageNotification({
    required String container,
    required String prediction,
  }) async {
    String title = 'ROTIFY Alert';
    String body = '$container status: $prediction';

    if (prediction == 'MID') {
      title = 'ROTIFY Warning';
      body = '$container is nearing spoilage.';
    } else if (prediction == 'SPOILED') {
      title = 'ROTIFY Critical Alert';
      body = '$container is already spoiled.';
    } else {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'rotify_banner_alerts',
      'ROTIFY Alerts',
      channelDescription: 'Food spoilage alerts',
      importance: Importance.max, // required for banner
      priority: Priority.max, // required for banner
      playSound: true,
      enableVibration: true,
      ticker: 'ROTIFY ALERT',
      visibility: NotificationVisibility.public,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  static Future<void> showPollutionNotification({
    required String container,
    required int mq135Value,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'rotify_pollution_alerts',
      'ROTIFY Pollution Alerts',
      channelDescription: 'Pollution alerts from MQ135 sensor',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      ticker: 'ROTIFY Pollution Alert',
      visibility: NotificationVisibility.public,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'ROTIFY Pollution Alert',
      'Pollution detected in $container (MQ135: $mq135Value).',
      details,
    );
  }
}

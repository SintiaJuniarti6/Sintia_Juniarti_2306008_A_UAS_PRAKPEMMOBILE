import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    // Minta izin notifikasi (khusus Android 13+)
    await _notifications
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
  }
  static Future<void> showOrderSuccessNotification({
    required String orderId,
    required double total,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'order_channel',
      'Notifikasi Pesanan',
      channelDescription: 'Notifikasi saat pesanan berhasil dibuat',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Pesanan Berhasil Dibuat! 🎉',
      'Pesanan #${orderId.substring(0, 8)} sedang diproses',
      notifDetails,
    );
  }
}
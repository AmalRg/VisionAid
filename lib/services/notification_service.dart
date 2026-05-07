import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // Notification de scan sauvegarde
  Future<void> showScanSaved(String title) async {
    await _plugin.show(
      id: 1,
      title: 'VisionAid — Scan sauvegardé',
      body: 'Votre scan "$title" a été enregistré.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'scan_channel',
          'Scans sauvegardés',
          channelDescription: 'Notifications quand un scan est enregistré',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        ),
      ),
    );
  }

  // notification de test
  Future<void> showTestNotification() async {
    await _plugin.show(
      id: 99,
      title: 'VisionAid — Test notification',
      body: 'Les notifications fonctionnent correctement ! ✓',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Notifications de test',
          channelDescription: 'Canal de test',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // notification rappel quotidien
  Future<void> scheduleDaily() async {
    await _plugin.periodicallyShow(
      id: 2,
      title: 'VisionAid',
      body: 'N\'oubliez pas d\'utiliser VisionAid aujourd\'hui !',
      repeatInterval: RepeatInterval.daily,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Rappels quotidiens',
          channelDescription: 'Rappels d\'utilisation',
          importance: Importance.low,
          icon: '@mipmap/ic_launcher',
        ),
      ), androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

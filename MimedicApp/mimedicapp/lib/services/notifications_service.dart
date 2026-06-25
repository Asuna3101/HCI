import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderNotifId = 1001;

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Solicitar permisos en Android 13+
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  Future<void> programarRecordatorioDiario(TimeOfDay hora) async {
    await cancelarRecordatorioDiario();

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hora.hour, hora.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyReminderNotifId,
      '¡Hora de tus hábitos!',
      'No olvides completar tus hábitos del día para mantener tu racha.',
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habitos_diarios',
          'Recordatorios de hábitos',
          channelDescription: 'Recordatorio diario para completar tus hábitos',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelarRecordatorioDiario() async {
    await _plugin.cancel(_dailyReminderNotifId);
  }

  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }
}

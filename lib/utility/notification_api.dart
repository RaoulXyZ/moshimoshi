import 'package:basics/basics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotifPermissionResult { granted, denied, permanentlyDenied }

enum NotificationChannel { daily, weekly, lessons, diary }

class NotificationAPI {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Europe/Rome"));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _notifications.initialize(settings);

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          'mind_blooming_daily',
          'Notifiche giornaliere',
          description: 'Promemoria del daily screening',
          importance: Importance.max,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          'mind_blooming_weekly',
          'Attività settimanali',
          description: 'Promemoria del weekly screening',
          importance: Importance.max,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          'mind_blooming_lessons',
          'Lezioni',
          description: 'Promemoria delle lezioni dei tuoi moduli',
          importance: Importance.max,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          'mind_blooming_diary',
          'Promemoria diario',
          description: 'Promemoria delle note del diario',
          importance: Importance.max,
        ),
      );
    }

    _initialized = true;
  }

  static Future<NotifPermissionResult> requestPermissions() async {
    await init();

    final notif = await Permission.notification.request();

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await Permission.scheduleExactAlarm.request();
      } catch (_) {}
    }

    if (notif.isGranted) return NotifPermissionResult.granted;
    if (notif.isPermanentlyDenied) {
      return NotifPermissionResult.permanentlyDenied;
    }

    return NotifPermissionResult.denied;
  }

  static Future<bool> hasPermissions() async {
    final status = await Permission.notification.status;

    return status.isGranted;
  }

  static Future<bool> openSystemSettings() async {
    return openAppSettings();
  }

  static Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    required String payload,
    required NotificationChannel channel,
  }) async {
    await init();
    await _notifications.show(
      id,
      title,
      body,
      await _notificationDetails(channel),
      payload: payload,
    );
  }

  static Future<void> scheduleDaily({
    int id = 0,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationChannel channel,
  }) async {
    await init();
    final when = _scheduleDaily(hour, minute);
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        when,
        await _notificationDetails(channel),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        when,
        await _notificationDetails(channel),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    if (kDebugMode) {
      debugPrint(
        'scheduleDaily id=$id $hour:$minute → fires at $when (now=${tz.TZDateTime.now(tz.local)})',
      );
    }
  }

  /// Notifica singola (una tantum) a un istante preciso nel futuro.
  static Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required NotificationChannel channel,
  }) async {
    await init();
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    if (!tzWhen.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzWhen,
        await _notificationDetails(channel),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzWhen,
        await _notificationDetails(channel),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    if (kDebugMode) {
      debugPrint('scheduleOnce id=$id → fires at $tzWhen');
    }
  }

  static Future<void> scheduleWeeklyOccurrences({
    required int baseId,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    required NotificationChannel channel,
    int weeksAhead = 8,
  }) async {
    await init();
    final firstWhen = _scheduleWeekly(weekday, hour, minute);
    for (int i = 0; i < weeksAhead; i++) {
      final when = firstWhen.add(Duration(days: 7 * i));
      final id = baseId + i;
      try {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          when,
          await _notificationDetails(channel),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } on PlatformException {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          when,
          await _notificationDetails(channel),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }

    if (kDebugMode) {
      debugPrint(
        'scheduleWeeklyOccurrences baseId=$baseId weekday=$weekday $hour:$minute, $weeksAhead weeks → first=$firstWhen',
      );
    }
  }

  static Future<void> cancelWeeklyOccurrences(
    int baseId, {
    int weeksAhead = 8,
  }) async {
    await init();
    for (int i = 0; i < weeksAhead; i++) {
      await _notifications.cancel(baseId + i);
    }
  }

  static Future<List<PendingNotificationRequest>> pending() async {
    await init();

    return _notifications.pendingNotificationRequests();
  }

  static tz.TZDateTime _scheduleDaily(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduleDate.isBefore(now)) {
      scheduleDate =
          tz.TZDateTime.from(scheduleDate.addCalendarDays(1), tz.local);
    }

    return scheduleDate;
  }

  static tz.TZDateTime _scheduleWeekly(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    int delta = (weekday - now.weekday) % 7;
    if (delta < 0) delta += 7;

    var scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(days: delta));

    if (!scheduleDate.isAfter(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 7));
    }

    return scheduleDate;
  }

  static Future<NotificationDetails> _notificationDetails(
      NotificationChannel channel) async {
    final String channelId;
    final String channelName;
    final String channelDescription;

    switch (channel) {
      case NotificationChannel.daily:
        channelId = 'mind_blooming_daily';
        channelName = 'Notifiche giornaliere';
        channelDescription = 'Promemoria del daily screening';
      case NotificationChannel.weekly:
        channelId = 'mind_blooming_weekly';
        channelName = 'Attività settimanali';
        channelDescription = 'Promemoria del weekly screening';
      case NotificationChannel.lessons:
        channelId = 'mind_blooming_lessons';
        channelName = 'Lezioni';
        channelDescription = 'Promemoria delle lezioni dei tuoi moduli';
      case NotificationChannel.diary:
        channelId = 'mind_blooming_diary';
        channelName = 'Promemoria diario';
        channelDescription = 'Promemoria delle note del diario';
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(threadIdentifier: channelId),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await init();
    await _notifications.cancel(id);
  }
}

import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:murattel_qoraan_app/core/routes/app_routes.dart';

class NotificationServices {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      if (payload == 'morning') {
        Get.toNamed(Routes.azkar, arguments: 'morning');
      } else if (payload == 'evening') {
        Get.toNamed(Routes.azkar, arguments: 'evening');
      } else if (payload == 'reminder') {
        Get.offAllNamed(Routes.home);
      }
    }
  }

  static Future<void> scheduleDailySpiritualGoals() async {
    await _notificationsPlugin.cancelAll();

    // 1. Azkar Notifications
    await _scheduleAzkarNotifications();

    // 2. Random Reminders
    await _scheduleRandomReminders();
  }

  static Future<void> _scheduleAzkarNotifications() async {
    const AndroidNotificationDetails androidMorning =
        AndroidNotificationDetails(
          'azkar_channel',
          'الأذكار',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformMorning = NotificationDetails(
      android: androidMorning,
    );

    await _notificationsPlugin.zonedSchedule(
      id: 1,
      title: '☀️ أذكار الصباح',
      body: 'حان وقت أذكار الصباح ✨',
      scheduledDate: _nextInstanceOfTime(7, 0),
      notificationDetails: platformMorning,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'morning',
    );

    await _notificationsPlugin.zonedSchedule(
      id: 2,
      title: '🌙 أذكار المساء',
      body: 'حان وقت أذكار المساء 🌟',
      scheduledDate: _nextInstanceOfTime(17, 0),
      notificationDetails: platformMorning,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'evening',
    );
  }

  static Future<void> _scheduleRandomReminders() async {
    final random = Random();
    const AndroidNotificationDetails androidReminder =
        AndroidNotificationDetails(
          'reminders_channel',
          'التذكير بالورد',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformReminder = NotificationDetails(
      android: androidReminder,
    );

    final titles = ['📖 ورد التلاوة', '📿 ورد التسبيح', '✨ ذكر الله'];
    final msgs = [
      'لا تنسَ وردك اليومي 📖',
      'رطّب لسانك بذكر الله 📿',
      'وردك اليومي ينتظرك ✨',
    ];

    for (int day = 0; day < 7; day++) {
      final scheduledDateTime = DateTime.now().add(
        Duration(days: day, hours: 4 + random.nextInt(8)),
      );
      if (scheduledDateTime.isAfter(DateTime.now())) {
        await _notificationsPlugin.zonedSchedule(
          id: 10 + day,
          title: titles[random.nextInt(3)],
          body: msgs[random.nextInt(3)],
          scheduledDate: tz.TZDateTime.from(scheduledDateTime, tz.local),
          notificationDetails: platformReminder,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'reminder',
        );
      }
    }
  }

  static Future<void> schedulePrayerNotifications(
    Map<String, dynamic> timings,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'prayer_times_channel',
          'مواقيت الصلاة',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('athan'),
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
      sound: 'athan.mp3',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    final format = DateFormat('HH:mm');
    final prayers = {
      'Fajr': 'الفجر',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };

    int id = 100;
    prayers.forEach((key, name) async {
      final timeStr = timings[key];
      if (timeStr != null) {
        final time = format.parse(timeStr);
        var scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await _notificationsPlugin.zonedSchedule(
          id: id++,
          title: '🕌 صلاة $name',
          body: 'حان الآن موعد الأذن',
          scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails: platformDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    });
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> checkAppLaunchNotification() async {
    final details = await _notificationsPlugin
        .getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      final payload = details.notificationResponse?.payload;
      if (payload != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (payload == 'morning') {
            Get.toNamed(Routes.azkar, arguments: 'morning');
          } else if (payload == 'evening') {
            Get.toNamed(Routes.azkar, arguments: 'evening');
          } else if (payload == 'reminder') {
            Get.offAllNamed(Routes.home);
          }
        });
      }
    }
  }
}

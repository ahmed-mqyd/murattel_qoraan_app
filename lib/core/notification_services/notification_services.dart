import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:murattel_qoraan_app/core/routes/app_routes.dart';
import 'package:murattel_qoraan_app/core/utils/prayer_time_utils.dart';

/// نطاقات IDs الإشعارات المحجوزة لكل نوع، لتفادي تصادمها عند إضافة نوع جديد:
/// 1-2 الأذكار | 10-16 التذكيرات العشوائية | 100-104 الصلوات | 200 الختمة
class _NotificationIds {
  static const int azkarMorning = 1;
  static const int azkarEvening = 2;
  static const int reminderBase = 10; // 10..16 (7 أيام)
  static const int prayerBase = 100; // 100..104 (5 صلوات)
  static const int khatmah = 200;
}

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

    // طلب صلاحية الإشعارات على Android — مُغلَّفة بـ try/catch
    // لأن Context قد لا يكون جاهزاً تماماً عند أول تشغيل
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      try {
        await androidPlugin.requestNotificationsPermission();
      } catch (e) {
        // Context غير جاهز بعد — نُكمل التشغيل ونطلب الإذن لاحقاً
        Get.log('فشل طلب صلاحية الإشعارات: $e');
      }
      try {
        // طلب صلاحية الإشعارات الدقيقة (مطلوبة لأوقات الأذان)
        await androidPlugin.requestExactAlarmsPermission();
      } catch (e) {
        // تُتجاهَل إذا كانت الصلاحية غير مدعومة على هذا الإصدار
        Get.log('فشل طلب صلاحية التنبيهات الدقيقة: $e');
      }
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
      } else if (payload == 'prayer') {
        Get.offAllNamed(Routes.home);
      }
    }
  }

  static Future<void> scheduleDailySpiritualGoals() async {
    // إلغاء إشعارات الأذكار والتذكير فقط (ليس إشعارات الأذان)
    final idsToCancel = [
      _NotificationIds.azkarMorning,
      _NotificationIds.azkarEvening,
      ...List.generate(7, (i) => _NotificationIds.reminderBase + i),
    ];
    for (final notifId in idsToCancel) {
      await _notificationsPlugin.cancel(id: notifId);
    }

    // 1. إشعارات الأذكار
    await _scheduleAzkarNotifications();

    // 2. تذكيرات عشوائية
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
      id: _NotificationIds.azkarMorning,
      title: '☀️ أذكار الصباح',
      body: 'حان وقت أذكار الصباح ✨',
      scheduledDate: _nextInstanceOfTime(7, 0),
      notificationDetails: platformMorning,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'morning',
    );

    await _notificationsPlugin.zonedSchedule(
      id: _NotificationIds.azkarEvening,
      title: '🌙 أذكار المساء',
      body: 'حان وقت أذكار المساء 🌟',
      scheduledDate: _nextInstanceOfTime(17, 0),
      notificationDetails: platformMorning,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
          id: _NotificationIds.reminderBase + day,
          title: titles[random.nextInt(3)],
          body: msgs[random.nextInt(3)],
          scheduledDate: tz.TZDateTime.from(scheduledDateTime, tz.local),
          notificationDetails: platformReminder,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'reminder',
        );
      }
    }
  }

  /// إشعار يومي لخطة الختمة الذكية
  static Future<void> scheduleKhatmahDailyReminder(
    int dailyPages,
    int hour,
  ) async {
    // إلغاء الإشعار القديم أولاً
    await _notificationsPlugin.cancel(id: _NotificationIds.khatmah);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'khatmah_channel',
          'مخطط الختمة',
          importance: Importance.high,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: _NotificationIds.khatmah,
      title: '📖 ورد الختمة اليومي',
      body: 'تبقى لك $dailyPages صفحة لهدف اليوم، لا تفوّت الورد!',
      scheduledDate: _nextInstanceOfTime(hour, 0),
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'reminder',
    );
  }

  /// جدولة إشعارات أوقات الصلاة — مُصلَح بـ for loop بدلاً من forEach
  static Future<void> schedulePrayerNotifications(
    Map<String, String> timings,
  ) async {
    // إلغاء إشعارات الأذان القديمة أولاً
    for (
      int notifId = _NotificationIds.prayerBase;
      notifId <= _NotificationIds.prayerBase + 4;
      notifId++
    ) {
      await _notificationsPlugin.cancel(id: notifId);
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'prayer_times_channel',
          'مواقيت الصلاة',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('athan'),
          playSound: true,
          // تجميع إشعارات الصلاة معاً كمجموعة واحدة بدل إشعارات منفصلة متراكمة
          groupKey: 'prayer_notifications',
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

    // الصلوات مع IDs ثابتة
    final prayers = [
      {'key': 'Fajr', 'name': 'الفجر', 'id': _NotificationIds.prayerBase},
      {'key': 'Dhuhr', 'name': 'الظهر', 'id': _NotificationIds.prayerBase + 1},
      {'key': 'Asr', 'name': 'العصر', 'id': _NotificationIds.prayerBase + 2},
      {
        'key': 'Maghrib',
        'name': 'المغرب',
        'id': _NotificationIds.prayerBase + 3,
      },
      {'key': 'Isha', 'name': 'العشاء', 'id': _NotificationIds.prayerBase + 4},
    ];

    // استخدام for loop بدلاً من forEach لضمان انتظار كل await
    for (final prayer in prayers) {
      final timeStr = timings[prayer['key']];
      if (timeStr == null) continue;

      final cleanTimeStr = cleanPrayerTimeString(timeStr);

      DateTime parsedTime;
      try {
        parsedTime = format.parse(cleanTimeStr);
      } catch (_) {
        continue;
      }

      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      // إذا مضى الوقت اليوم، جدوله لليوم التالي
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id: prayer['id'] as int,
        title: '🕌 صلاة ${prayer['name']}',
        body: 'حان الآن موعد الأذان 📢',
        scheduledDate: tzScheduledDate,
        notificationDetails: platformDetails,
        // exactAllowWhileIdle لضمان الدقة حتى في وضع التوفير
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // تكرار يومي بنفس الوقت
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'prayer',
      );
    }
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
          } else if (payload == 'reminder' || payload == 'prayer') {
            Get.offAllNamed(Routes.home);
          }
        });
      }
    }
  }
}

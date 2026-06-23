import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/notification_services/notification_services.dart';
import '../../suluk_screen/controller/suluk_controller.dart';

class KhatmahController extends GetxController {
  // ── Constants ──────────────────────────────────────────────────
  static const int totalPages = 604; // صفحات القرآن الكريم الكاملة
  static const String _keyIsActive = 'khatmah_is_active';
  static const String _keyDays = 'khatmah_days';
  static const String _keyStartDate = 'khatmah_start_date';
  static const String _keyTotalPages = 'khatmah_total_pages';
  static const String _keyLastMarkDate = 'khatmah_last_mark_date';
  static const String _keyNotifyHour = 'khatmah_notify_hour';

  // ── State ──────────────────────────────────────────────────────
  final isActive = false.obs;
  final khatmahDays = 30.obs;
  final totalPagesRead = 0.obs;
  final pagesReadToday = 0.obs;
  final notifyHour = 20.obs; // 8 مساءً افتراضياً
  final isLoading = false.obs;

  DateTime? _startDate;

  // ── Computed ───────────────────────────────────────────────────
  int get dailyPagesTarget => (totalPages / khatmahDays.value).ceil();

  double get overallProgress =>
      (totalPagesRead.value / totalPages).clamp(0.0, 1.0);

  int get remainingPages =>
      (totalPages - totalPagesRead.value).clamp(0, totalPages);

  int get daysPassed {
    if (_startDate == null) return 0;
    return DateTime.now().difference(_startDate!).inDays + 1;
  }

  int get estimatedDaysLeft {
    if (totalPagesRead.value == 0) return khatmahDays.value;
    final pagesPerDay = totalPagesRead.value / daysPassed;
    if (pagesPerDay <= 0) return khatmahDays.value;
    return (remainingPages / pagesPerDay).ceil();
  }

  int get todayTarget => dailyPagesTarget - pagesReadToday.value;

  double get todayProgress =>
      (pagesReadToday.value / dailyPagesTarget).clamp(0.0, 1.0);

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
  }

  // ── Persistence ────────────────────────────────────────────────
  void _loadFromPrefs() {
    final prefs = Get.find<SharedPreferences>();
    isActive.value = prefs.getBool(_keyIsActive) ?? false;
    khatmahDays.value = prefs.getInt(_keyDays) ?? 30;
    totalPagesRead.value = prefs.getInt(_keyTotalPages) ?? 0;
    notifyHour.value = prefs.getInt(_keyNotifyHour) ?? 20;

    final startStr = prefs.getString(_keyStartDate);
    if (startStr != null) {
      _startDate = DateTime.tryParse(startStr);
    }

    // حساب الصفحات المقروءة اليوم
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final lastMarkDate = prefs.getString(_keyLastMarkDate);
    if (lastMarkDate == todayStr) {
      pagesReadToday.value = prefs.getInt('khatmah_pages_today') ?? 0;
    } else {
      pagesReadToday.value = 0;
    }
  }

  // ── Start Khatmah ──────────────────────────────────────────────
  Future<void> startKhatmah(int days, {int hour = 20}) async {
    isLoading.value = true;
    final prefs = Get.find<SharedPreferences>();

    khatmahDays.value = days;
    notifyHour.value = hour;
    totalPagesRead.value = 0;
    pagesReadToday.value = 0;
    _startDate = DateTime.now();

    await prefs.setBool(_keyIsActive, true);
    await prefs.setInt(_keyDays, days);
    await prefs.setInt(_keyTotalPages, 0);
    await prefs.setInt(_keyNotifyHour, hour);
    await prefs.setString(_keyStartDate, _startDate!.toIso8601String());

    isActive.value = true;

    // جدولة الإشعار اليومي
    await NotificationServices.scheduleKhatmahDailyReminder(
      dailyPagesTarget,
      hour,
    );

    isLoading.value = false;
  }

  // ── Mark Page Read ─────────────────────────────────────────────
  Future<void> markPageRead() async {
    if (!isActive.value) return;
    if (totalPagesRead.value >= totalPages) return;

    final prefs = Get.find<SharedPreferences>();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    totalPagesRead.value++;
    pagesReadToday.value++;

    await prefs.setInt(_keyTotalPages, totalPagesRead.value);
    await prefs.setString(_keyLastMarkDate, todayStr);
    await prefs.setInt('khatmah_pages_today', pagesReadToday.value);

    // تحديث SulukController لفحص وسام الختمة
    if (Get.isRegistered<SulukController>()) {
      final suluk = Get.find<SulukController>();
      suluk.loadStats();
      suluk.checkAchievementsPublic();
    }

    // هل اكتملت الختمة؟
    if (totalPagesRead.value >= totalPages) {
      _onKhatmahComplete(prefs);
    }
  }

  // ── Reset Khatmah ──────────────────────────────────────────────
  Future<void> resetKhatmah() async {
    final prefs = Get.find<SharedPreferences>();
    await prefs.setBool(_keyIsActive, false);
    await prefs.setInt(_keyTotalPages, 0);
    await prefs.remove(_keyStartDate);
    await prefs.remove(_keyLastMarkDate);
    await prefs.remove('khatmah_pages_today');

    isActive.value = false;
    totalPagesRead.value = 0;
    pagesReadToday.value = 0;
    _startDate = null;
  }

  void _onKhatmahComplete(SharedPreferences prefs) {
    // بعد اكتمال الختمة يتم عرض رسالة مبارك
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF003527),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🕌', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'مبارك عليك إتمام الختمة!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC5A059),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'بارك الله في رحلتك مع القرآن الكريم',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.back();
                  resetKhatmah();
                },
                child: const Text(
                  'بدء ختمة جديدة',
                  style: TextStyle(color: Color(0xFFC5A059)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

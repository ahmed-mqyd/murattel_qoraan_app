import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home_screen/controller/home_controller.dart';
import '../../suluk_screen/controller/suluk_controller.dart';

class SettingsController extends GetxController {
  late final SharedPreferences _prefs;

  final prayerTimeAlerts = true.obs;
  final dailyReadingAlerts = false.obs;
  final selectedReciter = 'alafasy'.obs;
  final audioQuality = 'high'.obs;
  final dailyGoal = 20.obs;

  static const String _prayerAlertsKey = 'settings_prayer_time_alerts';
  static const String _dailyAlertsKey = 'settings_daily_reading_alerts';
  static const String _reciterKey = 'settings_selected_reciter';
  static const String _qualityKey = 'settings_audio_quality';
  static const String _dailyGoalKey = 'settings_daily_goal';

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    _loadSettings();
  }

  void _loadSettings() {
    prayerTimeAlerts.value = _prefs.getBool(_prayerAlertsKey) ?? true;
    dailyReadingAlerts.value = _prefs.getBool(_dailyAlertsKey) ?? false;
    selectedReciter.value = _prefs.getString(_reciterKey) ?? 'alafasy';
    audioQuality.value = _prefs.getString(_qualityKey) ?? 'high';
    dailyGoal.value = _prefs.getInt(_dailyGoalKey) ?? 20;
  }

  Future<void> togglePrayerTimeAlerts(bool val) async {
    prayerTimeAlerts.value = val;
    await _prefs.setBool(_prayerAlertsKey, val);
  }

  Future<void> toggleDailyReadingAlerts(bool val) async {
    dailyReadingAlerts.value = val;
    await _prefs.setBool(_dailyAlertsKey, val);
  }

  Future<void> updateReciter(String reciterKey) async {
    selectedReciter.value = reciterKey;
    await _prefs.setString(_reciterKey, reciterKey);
  }

  Future<void> updateAudioQuality(String qualityKey) async {
    audioQuality.value = qualityKey;
    await _prefs.setString(_qualityKey, qualityKey);
  }

  Future<void> updateDailyGoal(int goal) async {
    dailyGoal.value = goal;
    await _prefs.setInt(_dailyGoalKey, goal);
    // Refresh Home and Suluk controllers if they exist
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshData();
    }
    if (Get.isRegistered<SulukController>()) {
      Get.find<SulukController>().loadStats();
    }
  }
}

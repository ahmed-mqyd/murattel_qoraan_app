import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murattel_qoraan_app/screens/settings_screen/controller/settings_controller.dart';

class SulukController extends GetxController {
  late final SharedPreferences _prefs;

  final streak = 0.obs;
  final totalVerses = 0.obs;
  final weeklyProgress = <double>[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0].obs;
  final activeDayIndex = (-1).obs;
  final achievements = <String, bool>{
    'streak_7': false,
    'verses_500': false,
    'juz_1': false,
    'early_riser': false,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    loadStats();
  }

  void loadStats() {
    streak.value = _prefs.getInt('suluk_streak') ?? 0;
    totalVerses.value = _prefs.getInt('total_verses_read') ?? 0;

    // Calculate weekly progress (Sat-Fri)
    final now = DateTime.now();
    final startOfWeek = _getStartOfWeek(now);
    
    final List<double> progress = [];
    final int goal = Get.isRegistered<SettingsController>() 
        ? Get.find<SettingsController>().dailyGoal.value 
        : 20;

    for (int i = 0; i < 7; i++) {
      final currentDay = startOfWeek.add(Duration(days: i));
      final dateStr = currentDay.toIso8601String().split('T')[0];
      final count = _prefs.getInt('verses_read_$dateStr') ?? 0;
      // Define daily goal dynamically
      final double val = (count / goal.toDouble()).clamp(0.0, 1.0);
      progress.add(val);
    }
    weeklyProgress.value = progress;

    int todayIdx = (now.weekday - DateTime.saturday) % 7;
    if (todayIdx < 0) todayIdx += 7;
    activeDayIndex.value = todayIdx;

    _checkAchievements();
  }

  void _checkAchievements() {
    achievements['streak_7'] = streak.value >= 7;
    achievements['verses_500'] = totalVerses.value >= 500;
    // For Juz 1, let's say 141 ayahs (Al-Baqarah 1-141 roughly) or just 200 for now
    achievements['juz_1'] = totalVerses.value >= 141;
    // Early riser could be a flag set in prefs if read before 7 AM
    achievements['early_riser'] = _prefs.getBool('achievement_early_riser') ?? false;
  }

  DateTime _getStartOfWeek(DateTime date) {
    int diff = date.weekday - DateTime.saturday;
    if (diff < 0) {
      diff += 7;
    }
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: diff));
  }
}

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murattel_qoraan_app/screens/settings_screen/controller/settings_controller.dart';

// بيانات الوسام
class AchievementBadge {
  final String key;
  final String title;
  final String subtitle;
  final String emoji;
  final String category; // 'streak' | 'tilawa' | 'hifz'
  final bool Function(int streak, int verses, int pages, int hifzSessions, double bestScore) isUnlocked;

  const AchievementBadge({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.category,
    required this.isUnlocked,
  });
}

class SulukController extends GetxController {
  late final SharedPreferences _prefs;

  final streak = 0.obs;
  final totalVerses = 0.obs;
  final totalPagesRead = 0.obs;
  final weeklyProgress = <double>[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0].obs;
  final activeDayIndex = (-1).obs;

  // Hifz stats
  final hifzSessionsCount = 0.obs;
  final bestHifzScore = 0.0.obs;

  // Achievement state
  final unlockedKeys = <String>{}.obs;
  final newlyUnlockedBadge = ''.obs; // trigger confetti

  // الأوسمة الـ 12
  static final List<AchievementBadge> allBadges = [
    // ── مسار الاستمرار ──────────────────────────────────────────
    AchievementBadge(
      key: 'streak_3',
      title: 'مثابر ×٣',
      subtitle: '٣ أيام متتالية',
      emoji: '🔥',
      category: 'streak',
      isUnlocked: (s, v, p, h, b) => s >= 3,
    ),
    AchievementBadge(
      key: 'streak_7',
      title: 'أسبوع الخير',
      subtitle: '٧ أيام متتالية',
      emoji: '⭐',
      category: 'streak',
      isUnlocked: (s, v, p, h, b) => s >= 7,
    ),
    AchievementBadge(
      key: 'streak_14',
      title: 'مداوم',
      subtitle: '١٤ يوماً متتالياً',
      emoji: '🌟',
      category: 'streak',
      isUnlocked: (s, v, p, h, b) => s >= 14,
    ),
    AchievementBadge(
      key: 'streak_30',
      title: 'شهر الإتقان',
      subtitle: '٣٠ يوماً متتالياً',
      emoji: '🏅',
      category: 'streak',
      isUnlocked: (s, v, p, h, b) => s >= 30,
    ),
    // ── مسار التلاوة ──────────────────────────────────────────
    AchievementBadge(
      key: 'verses_100',
      title: 'بداية النور',
      subtitle: 'قراءة ١٠٠ آية',
      emoji: '📖',
      category: 'tilawa',
      isUnlocked: (s, v, p, h, b) => v >= 100,
    ),
    AchievementBadge(
      key: 'verses_500',
      title: 'تالٍ متقن',
      subtitle: 'قراءة ٥٠٠ آية',
      emoji: '📚',
      category: 'tilawa',
      isUnlocked: (s, v, p, h, b) => v >= 500,
    ),
    AchievementBadge(
      key: 'verses_1000',
      title: 'راسخ القدم',
      subtitle: 'قراءة ١٠٠٠ آية',
      emoji: '💎',
      category: 'tilawa',
      isUnlocked: (s, v, p, h, b) => v >= 1000,
    ),
    AchievementBadge(
      key: 'khatmah',
      title: 'خاتم القرآن',
      subtitle: 'إتمام ختمة كاملة',
      emoji: '🕌',
      category: 'tilawa',
      isUnlocked: (s, v, p, h, b) => p >= 604,
    ),
    // ── مسار الحفظ ──────────────────────────────────────────────
    AchievementBadge(
      key: 'hifz_first',
      title: 'أول خطوة',
      subtitle: 'جلسة تسميع واحدة',
      emoji: '🎤',
      category: 'hifz',
      isUnlocked: (s, v, p, h, b) => h >= 1,
    ),
    AchievementBadge(
      key: 'hifz_10',
      title: 'حافظ نشيط',
      subtitle: '١٠ جلسات تسميع',
      emoji: '🎯',
      category: 'hifz',
      isUnlocked: (s, v, p, h, b) => h >= 10,
    ),
    AchievementBadge(
      key: 'hifz_score_80',
      title: 'ممتاز',
      subtitle: 'نتيجة فوق ٨٠٪',
      emoji: '🥇',
      category: 'hifz',
      isUnlocked: (s, v, p, h, b) => b >= 80.0,
    ),
    AchievementBadge(
      key: 'hifz_perfect',
      title: 'حفظ مثالي',
      subtitle: 'نتيجة ١٠٠٪ كاملة',
      emoji: '👑',
      category: 'hifz',
      isUnlocked: (s, v, p, h, b) => b >= 100.0,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    loadStats();
  }

  void loadStats() {
    streak.value = _prefs.getInt('suluk_streak') ?? 0;
    totalVerses.value = _prefs.getInt('total_verses_read') ?? 0;
    totalPagesRead.value = _prefs.getInt('khatmah_total_pages') ?? 0;
    hifzSessionsCount.value = _prefs.getInt('hifz_sessions_count') ?? 0;
    bestHifzScore.value = _prefs.getDouble('hifz_best_score') ?? 0.0;

    // تحميل حالة الأوسمة المكتسبة
    final saved = _prefs.getStringList('unlocked_badges') ?? [];
    unlockedKeys.assignAll(saved.toSet());

    // حساب التقدم الأسبوعي
    _calculateWeeklyProgress();

    // فحص الأوسمة الجديدة (بدون trigger confetti عند التحميل)
    _checkAchievements(triggerConfetti: false);
  }

  void _calculateWeeklyProgress() {
    final now = DateTime.now();
    final startOfWeek = _getStartOfWeek(now);
    final int goal = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().dailyGoal.value
        : 20;

    final List<double> progress = [];
    for (int i = 0; i < 7; i++) {
      final currentDay = startOfWeek.add(Duration(days: i));
      final dateStr = currentDay.toIso8601String().split('T')[0];
      final count = _prefs.getInt('verses_read_$dateStr') ?? 0;
      progress.add((count / goal.toDouble()).clamp(0.0, 1.0));
    }
    weeklyProgress.value = progress;

    int todayIdx = (now.weekday - DateTime.saturday) % 7;
    if (todayIdx < 0) todayIdx += 7;
    activeDayIndex.value = todayIdx;
  }

  void checkAchievementsPublic() {
    _checkAchievements(triggerConfetti: true);
  }

  void _checkAchievements({bool triggerConfetti = true}) {
    final s = streak.value;
    final v = totalVerses.value;
    final p = totalPagesRead.value;
    final h = hifzSessionsCount.value;
    final b = bestHifzScore.value;

    String? newBadge;

    for (final badge in allBadges) {
      final shouldBeUnlocked = badge.isUnlocked(s, v, p, h, b);
      if (shouldBeUnlocked && !unlockedKeys.contains(badge.key)) {
        unlockedKeys.add(badge.key);
        if (triggerConfetti && newBadge == null) {
          newBadge = badge.key;
        }
      }
    }

    // حفظ حالة الأوسمة
    _prefs.setStringList('unlocked_badges', unlockedKeys.toList());

    // إطلاق confetti للوسام الأول المكتسب حديثاً
    if (newBadge != null) {
      newlyUnlockedBadge.value = newBadge;
      // إعادة تعيين بعد ثانية لإتاحة إعادة الإطلاق لاحقاً
      Future.delayed(const Duration(seconds: 3), () {
        newlyUnlockedBadge.value = '';
      });
    }
  }

  bool isBadgeUnlocked(String key) => unlockedKeys.contains(key);

  DateTime _getStartOfWeek(DateTime date) {
    int diff = date.weekday - DateTime.saturday;
    if (diff < 0) diff += 7;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: diff));
  }
}

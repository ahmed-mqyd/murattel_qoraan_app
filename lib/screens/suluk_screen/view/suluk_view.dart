import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/suluk_controller.dart';
import '../controller/khatmah_controller.dart';
import '../../settings_screen/controller/settings_controller.dart';

class SulukView extends GetView<SulukController> {
  const SulukView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadStats();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? const Color(0xFF02160F)
        : const Color(0xFFFDFBF7);
    final Color cardBackgroundColor = isDark
        ? const Color(0xFF052219)
        : Colors.white;
    final Color outlineColor = isDark
        ? const Color(0xFF204F3F).withValues(alpha: 0.3)
        : const Color(0xFFBFC9C3).withValues(alpha: 0.4);
    final Color textColor = isDark
        ? const Color(0xFFE2E2E5)
        : const Color(0xFF1A1C1E);
    final Color primaryColor = isDark
        ? const Color(0xFFA0D1BC)
        : const Color(0xFF003527);
    final Color goldColor = const Color(0xFFC5A059);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMarginMobile.w,
                vertical: 16.h,
              ),
              child: Obx(() {
                final int streakVal = controller.streak.value;
                final int totalVersesVal = controller.totalVerses.value;
                final int hifzSessions = controller.hifzSessionsCount.value;
                final double bestScore = controller.bestHifzScore.value;

                final String streakString =
                    '${_toArabicNumbers(streakVal.toString())} يوم';

                final String versesString =
                    '${_toArabicNumbers(totalVersesVal.toString())} آية';

                String levelString;
                if (streakVal >= 30) {
                  levelString = 'خاتم متقن';
                } else if (streakVal >= 14) {
                  levelString = 'مداوم';
                } else if (streakVal >= 7) {
                  levelString = 'مواظب';
                } else if (streakVal > 0) {
                  levelString = 'مبتدئ';
                } else {
                  levelString = 'ابدأ اليوم';
                }

                final todayIndex = controller.activeDayIndex.value;
                final todayProgress =
                    (todayIndex >= 0 &&
                        todayIndex < controller.weeklyProgress.length)
                    ? controller.weeklyProgress[todayIndex]
                    : 0.0;

                final int goal = Get.isRegistered<SettingsController>()
                    ? Get.find<SettingsController>().dailyGoal.value
                    : 20;

                final int todayVersesCount = (todayProgress * goal).round();
                final int remaining = (goal - todayVersesCount).clamp(0, goal);

                final String remainingString = remaining > 0
                    ? 'متبقي $remaining آية للهدف'
                    : '✅ اكتمل ورد اليوم';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    TextApp(
                      text: 'إحصائيات التقدم',
                      color: primaryColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4.h),
                    TextApp(
                      text: 'رصد رحلتك مع كتاب الله',
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 12.sp,
                    ),
                    SizedBox(height: 24.h),

                    // 0. Khatmah Planner Card
                    _buildKhatmahCard(
                      primaryColor, goldColor, textColor, cardBackgroundColor, outlineColor, isDark,
                    ),
                    SizedBox(height: 16.h),

                    // 1. Streak Hero Card مع شعلة متحركة
                    _buildStreakHeroCard(
                      streakVal,
                      streakString,
                      levelString,
                      goldColor,
                      cardBackgroundColor,
                      outlineColor,
                      primaryColor,
                      textColor,
                      isDark,
                    ),
                    SizedBox(height: 16.h),

                    // 2. Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildBentoStatCard(
                            'الآيات المقروءة',
                            versesString,
                            remainingString,
                            Icons.menu_book,
                            primaryColor,
                            cardBackgroundColor,
                            outlineColor,
                            primaryColor,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildBentoStatCard(
                            'جلسات التسميع',
                            '${_toArabicNumbers(hifzSessions.toString())} جلسة',
                            bestScore > 0
                                ? 'أعلى نتيجة: ${bestScore.toInt()}٪'
                                : 'لم تبدأ بعد',
                            Icons.mic_rounded,
                            goldColor,
                            cardBackgroundColor,
                            outlineColor,
                            primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // 3. Weekly Progress Chart
                    _buildWeeklyChartCard(
                      controller.weeklyProgress,
                      controller.activeDayIndex.value,
                      cardBackgroundColor,
                      outlineColor,
                      primaryColor,
                      goldColor,
                      textColor,
                      isDark,
                    ),
                    SizedBox(height: 24.h),

                    // 4. Achievements section (12 ديناميكي)
                    _buildAchievementsSection(
                      primaryColor,
                      goldColor,
                      textColor,
                      cardBackgroundColor,
                      outlineColor,
                      isDark,
                    ),
                    SizedBox(height: 32.h),
                  ],
                );
              }),
            ),
          ),
        ),

        // Confetti overlay
        Obx(() {
          if (controller.newlyUnlockedBadge.value.isNotEmpty) {
            return _ConfettiOverlay(
              badge: SulukController.allBadges.firstWhere(
                (b) => b.key == controller.newlyUnlockedBadge.value,
                orElse: () => SulukController.allBadges.first,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // ── Khatmah Planner Card ───────────────────────────────────────
  Widget _buildKhatmahCard(
    Color primaryColor,
    Color goldColor,
    Color textColor,
    Color cardBg,
    Color outlineColor,
    bool isDark,
  ) {
    final khatmah = Get.find<KhatmahController>();
    return Obx(() {
      final active = khatmah.isActive.value;
      if (!active) {
        // حالة غير نشطة: دعوة لإنشاء خطة
        return GestureDetector(
          onTap: () => _showKhatmahWizard(khatmah, primaryColor, goldColor, textColor, cardBg, isDark),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF064E3B), const Color(0xFF003527)]
                    : [const Color(0xFFEAF7F2), const Color(0xFFFDFBF7)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 1.w),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goldColor.withValues(alpha: 0.15),
                    border: Border.all(color: goldColor.withValues(alpha: 0.3), width: 1.w),
                  ),
                  child: Center(child: Text('📖', style: TextStyle(fontSize: 26.sp))),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextApp(text: 'مخطط الختمة الذكي', color: primaryColor, fontSize: 15.sp, fontWeight: FontWeight.bold),
                      SizedBox(height: 2.h),
                      TextApp(text: 'ابدأ خطة ختمة واحفظ وردك يومياً', color: textColor.withValues(alpha: 0.6), fontSize: 11.sp),
                    ],
                  ),
                ),
                Icon(Icons.arrow_back_ios_new_rounded, color: goldColor, size: 16.r),
              ],
            ),
          ),
        );
      }

      // حالة نشطة: عرض التقدم
      final progress = khatmah.overallProgress;
      final todayProg = khatmah.todayProgress;
      final dailyTarget = khatmah.dailyPagesTarget;
      final todayRead = khatmah.pagesReadToday.value;
      final totalRead = khatmah.totalPagesRead.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [Color(0xFF003527), Color(0xFF064E3B)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: goldColor.withValues(alpha: 0.4), width: 1.w),
          boxShadow: [BoxShadow(color: goldColor.withValues(alpha: 0.12), blurRadius: 14.r)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('📖', style: TextStyle(fontSize: 20.sp)),
                SizedBox(width: 8.w),
                TextApp(text: 'خطة الختمة', color: goldColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
                const Spacer(),
                // زر إعادة تعيين
                GestureDetector(
                  onTap: () async {
                    await khatmah.resetKhatmah();
                  },
                  child: Icon(Icons.restart_alt_rounded, color: Colors.white38, size: 20.r),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                // دائرة التقدم الكلي
                SizedBox(
                  width: 70.w,
                  height: 70.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5.w,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextApp(
                            text: '${(progress * 100).toInt()}٪',
                            color: goldColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          TextApp(text: 'مجموع', color: Colors.white54, fontSize: 8.sp),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شريط تقدم اليوم
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextApp(text: 'هدف اليوم', color: Colors.white70, fontSize: 11.sp),
                          TextApp(
                            text: '$todayRead / $dailyTarget صفحة',
                            color: todayRead >= dailyTarget ? const Color(0xFF4CAF50) : goldColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: todayProg,
                          minHeight: 6.h,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            todayRead >= dailyTarget ? const Color(0xFF4CAF50) : goldColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      TextApp(
                        text: 'مجموع المقروء: $totalRead / ${KhatmahController.totalPages} صفحة',
                        color: Colors.white60,
                        fontSize: 10.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // زر تسجيل صفحة
                GestureDetector(
                  onTap: () => khatmah.markPageRead(),
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: goldColor,
                      boxShadow: [BoxShadow(color: goldColor.withValues(alpha: 0.4), blurRadius: 8.r)],
                    ),
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 26.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showKhatmahWizard(
    KhatmahController khatmah,
    Color primaryColor,
    Color goldColor,
    Color textColor,
    Color cardBg,
    bool isDark,
  ) {
    final options = [
      {'days': 10, 'label': '١٠ أيام', 'subtitle': '~٦٠ صفحة/يوم', 'emoji': '⚡'},
      {'days': 30, 'label': '٣٠ يوماً', 'subtitle': '~٢٠ صفحة/يوم', 'emoji': '🌙'},
      {'days': 60, 'label': '٦٠ يوماً', 'subtitle': '~١٠ صفحات/يوم', 'emoji': '⭐'},
      {'days': 90, 'label': '٩٠ يوماً', 'subtitle': '~٧ صفحات/يوم', 'emoji': '🌿'},
    ];

    final selectedDays = RxInt(khatmah.khatmahDays.value);

    Get.bottomSheet(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF052219) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r))),
              SizedBox(height: 16.h),
              TextApp(text: '📖 اختر مدة الختمة', color: primaryColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
              SizedBox(height: 8.h),
              TextApp(text: 'القرآن الكريم = ٦٠٤ صفحة', color: textColor.withValues(alpha: 0.6), fontSize: 12.sp),
              SizedBox(height: 20.h),
              Obx(() => Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: options.map((opt) {
                  final days = opt['days'] as int;
                  final isSelected = selectedDays.value == days;
                  return GestureDetector(
                    onTap: () => selectedDays.value = days,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF003527) : (isDark ? const Color(0xFF02160F) : const Color(0xFFF5F5F0)),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: isSelected ? goldColor : Colors.transparent, width: 1.5.w),
                      ),
                      child: Column(
                        children: [
                          Text(opt['emoji'] as String, style: TextStyle(fontSize: 24.sp)),
                          SizedBox(height: 4.h),
                          TextApp(text: opt['label'] as String, color: isSelected ? goldColor : textColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
                          TextApp(text: opt['subtitle'] as String, color: isSelected ? Colors.white70 : textColor.withValues(alpha: 0.5), fontSize: 10.sp),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await khatmah.startKhatmah(selectedDays.value);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: TextApp(
                    text: 'ابدأ الختمة في ${selectedDays.value} يوماً ✨',
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Streak Hero Card ────────────────────────────────────────────
  Widget _buildStreakHeroCard(
    int streakVal,
    String streakString,
    String levelString,
    Color goldColor,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color textColor,
    bool isDark,
  ) {
    final bool hasStreak = streakVal > 0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: hasStreak
              ? [const Color(0xFF003527), const Color(0xFF064E3B)]
              : (isDark
                  ? [const Color(0xFF052219), const Color(0xFF02160F)]
                  : [Colors.white, const Color(0xFFF5F5F0)]),
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasStreak ? goldColor.withValues(alpha: 0.4) : outlineColor,
          width: 1.w,
        ),
        boxShadow: hasStreak
            ? [
                BoxShadow(
                  color: goldColor.withValues(alpha: 0.15),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.h),
                ),
              ]
            : AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          // Animated Flame
          _AnimatedFlame(streakVal: streakVal, goldColor: goldColor),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: 'سلسلة الحفظ',
                  color: hasStreak ? goldColor.withValues(alpha: 0.8) : textColor.withValues(alpha: 0.6),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4.h),
                TextApp(
                  text: hasStreak ? streakString : 'ابدأ رحلتك اليوم',
                  color: hasStreak ? Colors.white : textColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: hasStreak ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextApp(
                    text: levelString,
                    color: hasStreak ? goldColor : textColor.withValues(alpha: 0.6),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Daily progress indicator
          SizedBox(
            width: 52.w,
            height: 52.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Obx(() {
                  final todayIndex = controller.activeDayIndex.value;
                  final weeklyProg = controller.weeklyProgress;
                  final todayProg = (todayIndex >= 0 && todayIndex < weeklyProg.length)
                      ? weeklyProg[todayIndex]
                      : 0.0;
                  return CircularProgressIndicator(
                    value: todayProg.clamp(0.0, 1.0),
                    strokeWidth: 4.w,
                    backgroundColor: goldColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                  );
                }),
                Icon(Icons.menu_book_rounded, color: hasStreak ? Colors.white70 : textColor.withValues(alpha: 0.4), size: 20.r),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Card ──────────────────────────────────────────────────
  Widget _buildBentoStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 36.r),
          SizedBox(height: 8.h),
          TextApp(
            text: title,
            color: primaryColor.withValues(alpha: 0.7),
            fontSize: 11.sp,
          ),
          SizedBox(height: 2.h),
          TextApp(
            text: value,
            color: primaryColor,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 4.h),
          TextApp(
            text: subtitle,
            color: iconColor,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Weekly Chart ───────────────────────────────────────────────
  Widget _buildWeeklyChartCard(
    List<double> progressList,
    int activeIndex,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    final weeklyDays = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextApp(text: 'التقدم الأسبوعي', color: primaryColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF003527) : const Color(0xFFF3F3F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextApp(text: 'آخر ٧ أيام', color: textColor, fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 180.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final double val = progressList[index];
                final bool active = index == activeIndex;
                final Color barColor = active
                    ? goldColor
                    : (isDark ? const Color(0xFF003527) : const Color(0xFFBCEDD8));

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          heightFactor: val.clamp(0.01, 1.0),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextApp(
                        text: weeklyDays[index],
                        color: active ? primaryColor : textColor.withValues(alpha: 0.6),
                        fontSize: 11.sp,
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── 12 Dynamic Achievements ────────────────────────────────────
  Widget _buildAchievementsSection(
    Color primaryColor,
    Color goldColor,
    Color textColor,
    Color cardBg,
    Color outlineColor,
    bool isDark,
  ) {
    final categories = [
      {'key': 'streak', 'label': '🔥 الاستمرار'},
      {'key': 'tilawa', 'label': '📖 التلاوة'},
      {'key': 'hifz', 'label': '🎤 الحفظ'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextApp(text: 'الأوسمة والإنجازات', color: primaryColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
        SizedBox(height: 4.h),
        TextApp(
          text: 'اكتسب الأوسمة بمواصلة رحلتك مع القرآن الكريم',
          color: textColor.withValues(alpha: 0.55),
          fontSize: 11.sp,
        ),
        SizedBox(height: 16.h),

        // لكل فئة صف من الأوسمة
        ...categories.map((cat) {
          final catBadges = SulukController.allBadges
              .where((b) => b.category == cat['key'])
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextApp(text: cat['label']!, color: textColor.withValues(alpha: 0.7), fontSize: 13.sp, fontWeight: FontWeight.bold),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: catBadges.map((badge) {
                  return Obx(() {
                    final unlocked = controller.isBadgeUnlocked(badge.key);
                    return _buildBadge(badge, unlocked, goldColor, textColor, cardBg, outlineColor, isDark);
                  });
                }).toList(),
              ),
              SizedBox(height: 20.h),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBadge(
    AchievementBadge badge,
    bool unlocked,
    Color goldColor,
    Color textColor,
    Color cardBg,
    Color outlineColor,
    bool isDark,
  ) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: unlocked
                ? const LinearGradient(
                    colors: [Color(0xFFC5A059), Color(0xFFE8C47A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: unlocked ? null : (isDark ? const Color(0xFF052219) : const Color(0xFFF0F0EC)),
            border: Border.all(
              color: unlocked ? goldColor : outlineColor,
              width: unlocked ? 2.w : 1.w,
            ),
            boxShadow: unlocked
                ? [BoxShadow(color: goldColor.withValues(alpha: 0.35), blurRadius: 12.r, spreadRadius: 1.r)]
                : null,
          ),
          child: Center(
            child: unlocked
                ? Text(badge.emoji, style: TextStyle(fontSize: 28.sp))
                : Icon(Icons.lock_rounded, color: textColor.withValues(alpha: 0.25), size: 22.r),
          ),
        ),
        SizedBox(height: 6.h),
        SizedBox(
          width: 68.w,
          child: TextApp(
            text: badge.title,
            color: unlocked ? goldColor : textColor.withValues(alpha: 0.4),
            fontSize: 9.5.sp,
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }
}

// ── Animated Flame Widget ──────────────────────────────────────────
class _AnimatedFlame extends StatefulWidget {
  final int streakVal;
  final Color goldColor;
  const _AnimatedFlame({required this.streakVal, required this.goldColor});

  @override
  State<_AnimatedFlame> createState() => _AnimatedFlameState();
}

class _AnimatedFlameState extends State<_AnimatedFlame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStreak = widget.streakVal > 0;
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, __) => Transform.scale(
        scale: hasStreak ? _scaleAnim.value : 1.0,
        child: Text(
          hasStreak ? '🔥' : '💤',
          style: TextStyle(fontSize: 48.sp),
        ),
      ),
    );
  }
}

// ── Confetti Overlay ───────────────────────────────────────────────
class _ConfettiOverlay extends StatefulWidget {
  final AchievementBadge badge;
  const _ConfettiOverlay({required this.badge});

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Path _drawStar(Size size) {
    final path = Path();
    const int points = 5;
    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius / 2.5;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Confetti from top center
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              gravity: 0.25,
              colors: const [
                Color(0xFFC5A059),
                Color(0xFF064E3B),
                Color(0xFFE8C47A),
                Colors.white,
              ],
              createParticlePath: _drawStar,
            ),
          ),
          // Toast مبارك!
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF003527),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFC5A059), width: 1.5.w),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24.r),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.badge.emoji, style: TextStyle(fontSize: 48.sp)),
                    SizedBox(height: 8.h),
                    Text(
                      'مبارك! وسام جديد 🎉',
                      style: TextStyle(
                        color: const Color(0xFFC5A059),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.badge.title,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Hexagon clipper (للتوافق مع الكود القديم إذا وُجد)
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.25, 0);
    path.lineTo(size.width * 0.75, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width * 0.75, size.height);
    path.lineTo(size.width * 0.25, size.height);
    path.lineTo(0, size.height * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

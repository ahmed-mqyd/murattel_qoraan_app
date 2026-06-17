import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/suluk_controller.dart';
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

    return Scaffold(
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

            final String streakString =
                '${_toArabicNumbers(streakVal.toString())} يوم';

            final String versesString =
                '${_toArabicNumbers(totalVersesVal.toString())} آية';

            String levelString;
            if (streakVal >= 30) {
              levelString = 'خاتم متقن';
            } else if (streakVal >= 15) {
              levelString = 'حريص';
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
                : 'اكتمل ورد اليوم';

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

                // 1. Bento Stats Grid: Streak & Total Verses
                Row(
                  children: [
                    Expanded(
                      child: _buildBentoStatCard(
                        'سلسلة الحفظ',
                        streakString,
                        levelString,
                        Icons.local_fire_department,
                        goldColor,
                        cardBackgroundColor,
                        outlineColor,
                        primaryColor,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildBentoStatCard(
                        'الآيات المحفوظة',
                        versesString,
                        remainingString,
                        Icons.menu_book,
                        primaryColor,
                        cardBackgroundColor,
                        outlineColor,
                        primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // 2. Weekly Progress Chart Section
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

                // 3. Achievements section
                _buildAchievementsSection(primaryColor, goldColor, textColor),

                SizedBox(height: 16.h),
              ],
            );
          }),
        ),
      ),
    );
  }

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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 44.r),
          SizedBox(height: 12.h),
          Text(
            title,
            style: GoogleFonts.getFont(
              'Noto Naskh Arabic',
              textStyle: TextStyle(
                color: primaryColor.withValues(alpha: 0.7),
                fontSize: 13.sp,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.getFont(
              'Noto Naskh Arabic',
              textStyle: TextStyle(
                color: primaryColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: GoogleFonts.getFont(
              'Noto Naskh Arabic',
              textStyle: TextStyle(
                color: iconColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    final weeklyDays = [
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];

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
              TextApp(
                text: 'التقدم الأسبوعي',
                color: primaryColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF003527)
                      : const Color(0xFFF3F3F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextApp(
                  text: 'آخر 7 أيام',
                  color: textColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
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
                    : (isDark
                          ? const Color(0xFF003527)
                          : const Color(0xFFBCEDD8));

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
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(6.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        weeklyDays[index],
                        style: GoogleFonts.getFont(
                          'Noto Naskh Arabic',
                          textStyle: TextStyle(
                            color: active
                                ? primaryColor
                                : textColor.withValues(alpha: 0.6),
                            fontSize: 11.sp,
                            fontWeight: active
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
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

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  Widget _buildAchievementsSection(
    Color primaryColor,
    Color goldColor,
    Color textColor,
  ) {
    final badges = [
      {'title': 'سلسلة 7 أيام', 'icon': Icons.calendar_month},
      {'title': '500 آية', 'icon': Icons.auto_stories},
      {'title': 'إتقان الجزء 1', 'icon': Icons.workspace_premium},
      {'title': 'المبكر', 'icon': Icons.wb_sunny},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: TextApp(
            text: 'الأوسمة المحققة',
            color: primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: badges.map((badge) {
            return Column(
              children: [
                ClipPath(
                  clipper: HexagonClipper(),
                  child: Container(
                    width: 64.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF003527), Color(0xFF064E3B)],
                      ),
                      border: Border.all(color: goldColor, width: 2.w),
                    ),
                    child: Center(
                      child: Icon(
                        badge['icon'] as IconData,
                        color: Colors.white,
                        size: 26.r,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  badge['title'] as String,
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 11.sp,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Flat-topped Hexagon Custom Clipper matching Stitch CSS clip-path
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

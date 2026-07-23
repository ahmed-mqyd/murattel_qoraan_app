import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import 'package:murattel_qoraan_app/core/images/images_const.dart';
import 'package:murattel_qoraan_app/core/routes/app_routes.dart';
import 'package:murattel_qoraan_app/screens/main_screen/controller/main_controller.dart';
import 'package:murattel_qoraan_app/screens/settings_screen/controller/settings_controller.dart';
import '../controller/home_controller.dart';
import 'package:murattel_qoraan_app/screens/azkar_screen/controller/azkar_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.refreshData();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Background colors matching Stitch designs
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar
              _buildTopBar(
                isDark,
                primaryColor,
                cardBackgroundColor,
                outlineColor,
              ),
              SizedBox(height: 20.h),

              // 2. Greeting Section
              _buildGreeting(primaryColor, textColor),
              SizedBox(height: 16.h),

              // 2.5. Family Moons Section (Al-Maqeed) - Moved to top
              _buildFamilyMoonsSection(
                primaryColor,
                goldColor,
                textColor,
                isDark,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
              SizedBox(height: 20.h),

              // 3. Bento Grid: Daily Goal & Continue Reading
              _buildBentoGrid(
                context,
                isDark,
                cardBackgroundColor,
                outlineColor,
                primaryColor,
                goldColor,
                textColor,
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),
              SizedBox(height: 24.h),

              // 4. Quick Actions
              _buildQuickActionsHeader(primaryColor, goldColor),
              SizedBox(height: 12.h),
              _buildQuickActionsGrid(
                cardBackgroundColor,
                outlineColor,
                primaryColor,
                goldColor,
                textColor,
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),
              SizedBox(height: 24.h),

              // 4.5. Favorites Section
              _buildFavoritesSection(
                cardBackgroundColor,
                outlineColor,
                primaryColor,
                goldColor,
                textColor,
              ),
              Obx(() => controller.favoriteAyahsList.isNotEmpty || controller.favoriteAzkarList.isNotEmpty
                  ? SizedBox(height: 24.h)
                  : const SizedBox.shrink()),

              // 5. Daily Ayah Card
              _buildDailyAyahCard(
                cardBackgroundColor,
                outlineColor,
                primaryColor,
                goldColor,
                textColor,
              ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.05, end: 0),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildTopBar(
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color outlineColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Drawer menu button placeholder (empty for now)
            IconButton(
              icon: Icon(Icons.menu, color: primaryColor, size: 24.r),
              onPressed: () {
                // Keep blank/drawer functionality placeholder
              },
            ),
            SizedBox(width: 8.w),
            // Logo and App Title
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4.r,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Image.asset(appLogo, fit: BoxFit.contain),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            TextApp(
              text: "مرتل القرأن",
              color: primaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search, color: primaryColor, size: 24.r),
              onPressed: () {
                HapticFeedback.selectionClick();
              },
            ),
            SizedBox(width: 4.w),
            // Profile image placeholder
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 1.w,
                ),
                color: primaryColor.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.person, color: primaryColor, size: 20.r),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreeting(Color primaryColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextApp(
          text: 'يومك مبارك بذكر الله.',
          color: primaryColor,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  Widget _buildBentoGrid(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
  ) {
    return Column(
      children: [
        // 1. Redesigned Bento Dashboard Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextApp(
              text: 'الورد اليومي',
              color: primaryColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            Obx(() {
              int completed = 0;
              final int dailyGoal = Get.isRegistered<SettingsController>()
                  ? Get.find<SettingsController>().dailyGoal.value
                  : 20;
              if (controller.todayReadCount.value >= dailyGoal) completed++;
              if (controller.isMorningAzkarDone.value) completed++;
              if (controller.isEveningAzkarDone.value) completed++;
              if (controller.dailyTasbeehCount.value >= 100) completed++;
              if (controller.isWasiyaDone.value) completed++;
              return TextApp(
                text: 'أنجزت $completed من ٥ أوراد',
                color: goldColor,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
              );
            }),
          ],
        ),
        SizedBox(height: 12.h),

        // 2. Redesigned overall progress card banner
        _buildOverallProgressCard(
          isDark,
          cardBg,
          outlineColor,
          primaryColor,
          goldColor,
          textColor,
        ),
        SizedBox(height: 14.h),

        // 3. Redesigned daily goal grid of Bento tiles
        _buildDailyGoalsGrid(
          isDark,
          cardBg,
          outlineColor,
          primaryColor,
          goldColor,
          textColor,
        ),
        SizedBox(height: 18.h),

        // 4. Continue Reading Card
        Obx(() {
          final hasBookmark = controller.bookmarkSurahId.value != -1;
          final String titleText = hasBookmark
              ? controller.bookmarkSurahName.value
              : 'سورة الكهف';
          final String infoText = hasBookmark
              ? 'الآية ${_toLanguageNumber(controller.bookmarkAyahIndex.value + 1)}'
              : 'الآية ٢٥ — الصفحة ٢٩٦';
          final int destId = hasBookmark
              ? controller.bookmarkSurahId.value
              : 18;
          final String destName = hasBookmark
              ? controller.bookmarkSurahName.value
              : 'الكهف';
          final int destAyahIndex = hasBookmark
              ? controller.bookmarkAyahIndex.value
              : -1;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B), // Emerald accent fill
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: AppTheme.shadowMd,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -16.w,
                  top: -16.h,
                  child: Opacity(
                    opacity: 0.08,
                    child: Icon(
                      Icons.menu_book,
                      size: 100.r,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          color: goldColor.withValues(alpha: 0.8),
                          size: 18.r,
                        ),
                        SizedBox(width: 8.w),
                        TextApp(
                          text: 'تابع القراءة',
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    TextApp(
                      text: titleText,
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4.h),
                    TextApp(
                      text: infoText,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(
                          Routes.mushafReader,
                          arguments: {
                            'id': destId,
                            'name': destName,
                            'initialAyahIndex': destAyahIndex,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                      ),
                      icon: Icon(Icons.arrow_back, size: 16.r),
                      label: TextApp(
                        text: 'الذهاب إلى المصحف',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOverallProgressCard(
    bool isDark,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
  ) {
    return Obx(() {
      final overallProgress = controller.overallGoalProgress.value;
      final overallPercentage = controller.overallGoalPercentage.value;

      String statusTitle = 'حافظ على وردك اليومي';
      String statusSubtitle = 'خطوات بسيطة يومياً تصنع فارقاً عظيماً في حياتك';
      if (overallProgress == 0.0) {
        statusTitle = 'ابدأ وردك اليومي';
        statusSubtitle = 'خير الأعمال أدومها وإن قل، ابدأ بوردك الآن';
      } else if (overallProgress < 0.5) {
        statusTitle = 'بداية مباركة!';
        statusSubtitle = 'واصل إكمال أورادك المتبقية لتنال بركتها';
      } else if (overallProgress < 1.0) {
        statusTitle = 'أوشكت على الانتهاء!';
        statusSubtitle = 'لم يتبق الكثير لإنجاز كامل وردك اليومي، استمر';
      } else {
        statusTitle = 'مبارك الإنجاز!';
        statusSubtitle = 'تقبل الله طاعاتك وأدام عليك النور والبركة في يومك';
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF032B20), const Color(0xFF011C14)]
                : [const Color(0xFFE6F4EA), Colors.white],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? const Color(0xFF1B4D3E) : const Color(0xFFCEEAD6),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextApp(
                    text: statusTitle,

                    color: isDark
                        ? const Color(0xFFA0D1BC)
                        : const Color(0xFF003527),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 6.h),
                  TextApp(
                    text: statusSubtitle,
                    color: isDark
                        ? const Color(0xFFB3C5BE)
                        : const Color(0xFF476257),
                    fontSize: 11.sp,
                    height: 1.45,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Stack(
              alignment: Alignment.center,
              children: [
                if (isDark)
                  Container(
                    width: 76.w,
                    height: 76.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: goldColor.withValues(alpha: 0.15),
                          blurRadius: 16.r,
                          spreadRadius: 2.r,
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: 70.w,
                  height: 70.w,
                  child: CircularProgressIndicator(
                    value: overallProgress,
                    strokeWidth: 6.w,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                  ),
                ),
                Text(
                  overallPercentage,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      color: textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDailyGoalsGrid(
    bool isDark,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
  ) {
    return Obx(() {
      final int dailyGoal = Get.isRegistered<SettingsController>()
          ? Get.find<SettingsController>().dailyGoal.value
          : 20;
      final quranProgress =
          (controller.todayReadCount.value / dailyGoal.toDouble()).clamp(
            0.0,
            1.0,
          );
      final tasbeehProgress = (controller.dailyTasbeehCount.value / 100.0)
          .clamp(0.0, 1.0);

      return Column(
        children: [
          _buildGoalCard(
            icon: Icons.menu_book,
            title: 'ورد التلاوة اليومي',
            subtitle:
                '${_toLanguageNumber(controller.todayReadCount.value)} / ${_toLanguageNumber(dailyGoal)} آية',
            progress: quranProgress,
            isCompleted: quranProgress >= 1.0,
            accentColor: const Color(0xFF0F9D58),
            onTap: () {
              HapticFeedback.lightImpact();
              Get.find<MainController>().changePage(1);
            },
            isDark: isDark,
            cardBg: cardBg,
            textColor: textColor,
            goldColor: goldColor,
            fullWidth: true,
          ),
          SizedBox(height: 12.h),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildGoalCard(
                    icon: Icons.wb_sunny_outlined,
                    title: 'أذكار الصباح',
                    subtitle: controller.isMorningAzkarDone.value
                        ? 'مكتملة'
                        : 'لم تبدأ بعد',
                    isCompleted: controller.isMorningAzkarDone.value,
                    accentColor: const Color(0xFFF4B400),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(Routes.azkar, arguments: 'morning');
                    },
                    isDark: isDark,
                    cardBg: cardBg,
                    textColor: textColor,
                    goldColor: goldColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildGoalCard(
                    icon: Icons.nights_stay_outlined,
                    title: 'أذكار المساء',
                    subtitle: controller.isEveningAzkarDone.value
                        ? 'مكتملة'
                        : 'لم تبدأ بعد',
                    isCompleted: controller.isEveningAzkarDone.value,
                    accentColor: const Color(0xFF3F51B5),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(Routes.azkar, arguments: 'evening');
                    },
                    isDark: isDark,
                    cardBg: cardBg,
                    textColor: textColor,
                    goldColor: goldColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildGoalCard(
                    icon: Icons.fingerprint,
                    title: 'ورد التسبيح والاستغفار',
                    subtitle:
                        '${_toLanguageNumber(controller.dailyTasbeehCount.value)} / ١٠٠',
                    progress: tasbeehProgress,
                    isCompleted: controller.dailyTasbeehCount.value >= 100,
                    accentColor: const Color(0xFF00ACC1),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(Routes.tasbeeh);
                    },
                    isDark: isDark,
                    cardBg: cardBg,
                    textColor: textColor,
                    goldColor: goldColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildGoalCard(
                    icon: Icons.assignment_outlined,
                    title: 'وصية إبراهيم المقيد',
                    subtitle: controller.isWasiyaDone.value
                        ? 'مكتملة'
                        : 'وصية أبو خضر',
                    isCompleted: controller.isWasiyaDone.value,
                    accentColor: const Color(0xFFC5A059),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(Routes.wasiya);
                    },
                    isDark: isDark,
                    cardBg: cardBg,
                    textColor: textColor,
                    goldColor: goldColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required String subtitle,
    double? progress,
    required bool isCompleted,
    required Color accentColor,
    required VoidCallback onTap,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color goldColor,
    bool fullWidth = false,
  }) {
    final cardColor = isCompleted
        ? (isDark ? const Color(0xFF0A2E22) : const Color(0xFFEAF5F0))
        : (isDark
              ? accentColor.withValues(alpha: 0.05)
              : accentColor.withValues(alpha: 0.03));

    final borderColor = isCompleted
        ? (isDark ? const Color(0xFF2E6F59) : const Color(0xFFA3D9C9))
        : (isDark
              ? accentColor.withValues(alpha: 0.15)
              : accentColor.withValues(alpha: 0.12));

    final iconBgColor = isCompleted
        ? goldColor.withValues(alpha: 0.15)
        : accentColor.withValues(alpha: 0.1);

    final iconColor = isCompleted
        ? goldColor
        : (isDark ? accentColor.withValues(alpha: 0.8) : accentColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: 1.2.w),
            boxShadow: isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.1 : 0.03,
                      ),
                      blurRadius: 8.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, color: iconColor, size: 20.r),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? goldColor
                            : textColor.withValues(alpha: 0.25),
                        width: 1.5.w,
                      ),
                      color: isCompleted ? goldColor : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 12.r)
                        : null,
                  ),
                ],
              ),
              SizedBox(height: fullWidth ? 12.h : 18.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextApp(
                    text: title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: isCompleted
                        ? (isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : textColor.withValues(alpha: 0.6))
                        : textColor,
                    fontSize: fullWidth ? 13.5.sp : 12.5.sp,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  SizedBox(height: 2.h),
                  TextApp(
                    text: subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: isCompleted
                        ? (isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : textColor.withValues(alpha: 0.4))
                        : textColor.withValues(alpha: 0.6),
                    fontSize: 10.sp,
                  ),
                ],
              ),
              if (progress != null) ...[
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4.h,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? goldColor : accentColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyMoonsSection(
    Color primaryColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextApp(
                text: "تطبيق مرتل القرأن صدقة جارية عن أقمار عائلة المقيد",
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.auto_awesome, color: goldColor, size: 20.r),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 250.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                key: const ValueKey('moon_slider'),
                // استخدام ValueKey لضمان التفرد ومنع تعارض الـ ScrollController
                controller: controller.moonPageController,
                itemCount: controller.familyMoons.length,
                onPageChanged: (index) {
                  controller.currentMoonIndex.value = index;
                },
                itemBuilder: (context, index) {
                  final moon = controller.familyMoons[index];
                  return AnimatedBuilder(
                    animation: controller.moonPageController,
                    builder: (context, child) {
                      double value = 1.0;
                      // التحقق من أن الـ Controller مرتبط بـ View واحد فقط قبل الوصول لبياناته
                      // نستخدم try-catch للتعامل مع استثناء "multiple scroll views"
                      if (controller.moonPageController.hasClients) {
                        try {
                          if (controller
                              .moonPageController
                              .position
                              .haveDimensions) {
                            value = controller.moonPageController.page! - index;
                            value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                          }
                        } catch (e) {
                          // في حالة وجود تعارض في الـ ScrollController نثبت القيمة مؤقتاً
                          value = 1.0;
                        }
                      }
                      return Center(
                        child: SizedBox(
                          height: Curves.easeOut.transform(value) * 250.h,
                          width: double.infinity,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF052219) : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12.r,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 1. Blurred Background to fill the section
                            Image.asset(moon['image']!, fit: BoxFit.cover),
                            // Dark overlay for background
                            Container(
                              color: Colors.black.withValues(alpha: 0.5),
                            ),

                            // 2. The actual image with contain to show the full face
                            Padding(
                              padding: EdgeInsets.only(bottom: 45.h),
                              child: Image.asset(
                                moon['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),

                            // Inner Border for elegance
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: goldColor.withValues(alpha: 0.3),
                                  width: 1.w,
                                ),
                              ),
                            ),

                            // 3. Gradient and Text
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.95),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                              ),
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextApp(
                                    text: moon['name']!,

                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    shadowColor: Colors.black,
                                    blurRadius: 4.r,
                                    offset: const Offset(0, 2),
                                  ),

                                  TextApp(
                                    text: moon['name']!.contains("حسن")
                                        ? "حفظه الله وامده الله بتمام الصحة والعافية "
                                        : "رحمه الله وأسكنه فسيح جناته",
                                    color: goldColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Arrows
              Positioned(
                right: 0,
                child: IconButton(
                  onPressed: () => controller.nextMoon(),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: goldColor.withValues(alpha: 0.5),
                    size: 20.r,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: () => controller.previousMoon(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: goldColor.withValues(alpha: 0.5),
                    size: 20.r,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Indicators
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.familyMoons.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                height: 8.h,
                width: controller.currentMoonIndex.value == index ? 20.w : 8.w,
                decoration: BoxDecoration(
                  color: controller.currentMoonIndex.value == index
                      ? goldColor
                      : goldColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsHeader(Color primaryColor, Color goldColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextApp(
          text: 'الوصول السريع',

          color: primaryColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
        TextButton(
          onPressed: () {},
          child: TextApp(
            text: 'الكل',
            color: goldColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
  ) {
    final actions = [
      {
        'title': 'تسميع ذكي',
        'desc': 'تحقق من حفظك بالصوت',
        'icon': Icons.mic_none,
        'color': primaryColor,
      },
      {
        'title': 'القبلة',
        'desc': 'تحديد اتجاه الصلاة',
        'icon': Icons.explore_outlined,
        'color': goldColor,
      },
      {
        'title': 'آية اليوم',
        'desc': 'تأملات يومية مختارة',
        'icon': Icons.today,
        'color': Colors.blueGrey,
      },
      {
        'title': 'مواقيت الصلاة',
        'desc': 'صلاة الفجر: ٠٤:٣٠ ص',
        'icon': Icons.schedule,
        'color': primaryColor,
      },
      {
        'title': "حصن المسلم",
        'desc': "الأذكار اليومية والتحصين",
        'icon': Icons.shield_moon_outlined,
        'color': goldColor,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        final actColor = action['color'] as Color;
        return Material(
          color: cardBg,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              final String title = action['title'] as String;
              if (title == 'القبلة') {
                Get.toNamed(Routes.qibla);
              } else if (title == 'تسميع ذكي') {
                Get.find<MainController>().changePage(
                  0,
                ); // Switch to Hifz view (index 0)
              } else if (title == 'مواقيت الصلاة') {
                Get.toNamed(Routes.prayerTimes);
              } else if (title == "حصن المسلم") {
                Get.toNamed(Routes.azkarLibrary);
              } else {
                Get.snackbar(
                  action['title'] as String,
                  action['desc'] as String,
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: primaryColor.withValues(alpha: 0.9),
                  colorText: Colors.white,
                );
              }
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: outlineColor, width: 1.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: actColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: actColor,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextApp(
                    text: action['title'] as String,
                    color: textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 2.h),
                  TextApp(
                    text: action['desc'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 10.sp,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyAyahCard(
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
  ) {
    return Obx(() {
      final text = controller.dailyAyahText.value;
      final translation = controller.dailyAyahTranslation.value;
      final surahName = controller.dailyAyahSurahName.value;
      final ayahNum = controller.dailyAyahNumber.value;

      final String refText = '$surahName — ${_toLanguageNumber(ayahNum)}';

      final bool isSavedVal = controller.isSaved.value;
      final bool playing = controller.isPlaying.value;
      final bool loadingAudio = controller.isAudioLoading.value;

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(
            Routes.mushafReader,
            arguments: {
              'id': controller.dailyAyahSurahId.value,
              'name': controller.dailyAyahSurahName.value,
              'initialAyahIndex': controller.dailyAyahNumber.value - 1,
            },
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: goldColor.withValues(alpha: 0.3),
              width: 1.w,
            ),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: [
              Icon(
                Icons.format_quote,
                color: goldColor.withValues(alpha: 0.3),
                size: 40.r,
              ),
              SizedBox(height: 8.h),

              // Arabic Text
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    textStyle: TextStyle(
                      color: textColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Translation Text (Bilingual support)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  translation,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: 13.sp,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Citation/Reference
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20.w,
                    height: 1.h,
                    color: textColor.withValues(alpha: 0.3),
                  ),
                  SizedBox(width: 8.w),
                  TextApp(
                    text: refText,
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 20.w,
                    height: 1.h,
                    color: textColor.withValues(alpha: 0.3),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Share Button
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: textColor.withValues(alpha: 0.8),
                      size: 20.r,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      controller.copyToClipboard();
                    },
                  ),
                  SizedBox(width: 12.w),

                  // Bookmark/Save Button
                  IconButton(
                    icon: Icon(
                      isSavedVal ? Icons.bookmark : Icons.bookmark_add,
                      color: isSavedVal
                          ? goldColor
                          : textColor.withValues(alpha: 0.8),
                      size: 20.r,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      controller.toggleSaveAyah();
                    },
                  ),
                  SizedBox(width: 16.w),

                  // Listen Button
                  if (loadingAudio)
                    SizedBox(
                      width: 110.w,
                      height: 44.h,
                      child: Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goldColor,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.togglePlay();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF064E3B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                      icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        size: 18.r,
                      ),
                      label: TextApp(
                        text: playing ? 'إيقاف' : 'استماع',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  String _toLanguageNumber(int number) {
    final String numStr = number.toString();

    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var temp = numStr;
    for (var i = 0; i < english.length; i++) {
      temp = temp.replaceAll(english[i], arabic[i]);
    }
    return temp;
  }

  Widget _buildFavoritesSection(
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
  ) {
    return Obx(() {
      final hasAyahs = controller.favoriteAyahsList.isNotEmpty;
      final hasAzkar = controller.favoriteAzkarList.isNotEmpty;

      if (!hasAyahs && !hasAzkar) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: goldColor, size: 22.r),
              SizedBox(width: 8.w),
              TextApp(
                text: 'مفضلتي',
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          if (hasAyahs) ...[
            TextApp(
              text: 'الآيات والسور المفضلة',
              color: textColor.withValues(alpha: 0.7),
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 75.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.favoriteAyahsList.length,
                itemBuilder: (context, index) {
                  final item = controller.favoriteAyahsList[index];
                  final surahId = item['surahId'] as int;
                  final surahName = item['surahName'] as String;
                  final ayahIndex = item['ayahIndex'] as int;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(
                        '/mushaf-reader',
                        arguments: {
                          'id': surahId,
                          'name': surahName,
                          'initialAyahIndex': ayahIndex,
                        },
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 10.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: outlineColor, width: 1.w),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: primaryColor, size: 18.r),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextApp(
                                text: surahName,
                                color: textColor,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(height: 2.h),
                              TextApp(
                                text: 'الآية ${_toLanguageNumber(ayahIndex + 1)}',
                                color: goldColor,
                                fontSize: 11.sp,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
          ],
          
          if (hasAzkar) ...[
            TextApp(
              text: 'الأذكار المفضلة',
              color: textColor.withValues(alpha: 0.7),
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 85.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.favoriteAzkarList.length,
                itemBuilder: (context, index) {
                  final item = controller.favoriteAzkarList[index];
                  final String text = item['text'] as String;
                  final String category = item['category'] as String;
                  final String categoryName = item['categoryName'] as String;

                  final String displayText = text.length > 30 ? '${text.substring(0, 30)}...' : text;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed('/azkar', arguments: category);
                      
                      if (Get.isRegistered<AzkarController>()) {
                        Get.find<AzkarController>().setCategory(category);
                      }
                    },
                    child: Container(
                      width: 200.w,
                      margin: EdgeInsets.only(left: 10.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: outlineColor, width: 1.w),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, color: goldColor, size: 18.r),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextApp(
                                  text: categoryName,
                                  color: primaryColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  displayText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.amiri(
                                    fontSize: 13.sp,
                                    color: textColor,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      );
    });
  }
}

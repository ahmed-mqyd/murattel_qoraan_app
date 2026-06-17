import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import 'package:murattel_qoraan_app/core/images/images_const.dart';
import '../controller/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Header Logo
              _buildHeaderIcon(primaryColor),

              SizedBox(height: 16.h),

              // 3. Quick Theme Toggle Row
              _buildThemeToggleRow(
                context,
                cardBackgroundColor,
                outlineColor,
                goldColor,
                textColor,
                isDark,
              ),
              SizedBox(height: 16.h),

              // 4. Notifications Card Section
              _buildNotificationsCard(
                cardBackgroundColor,
                outlineColor,
                primaryColor,
                textColor,
              ),
              SizedBox(height: 16.h),

          
 

              // 5.5. Daily Goal Card Section
              _buildDailyGoalCard(
                context,
                cardBackgroundColor,
                outlineColor,
                primaryColor,
                goldColor,
                textColor,
              ),
              SizedBox(height: 16.h),

              // 6. Audio Section Card
              _buildAudioCard(
                context,
                cardBackgroundColor,
                outlineColor,
                primaryColor,
                goldColor,
                textColor,
              ),
              SizedBox(height: 16.h),

              // 7. Visual Theme Grid Selection
              _buildThemeSelectionCard(
                cardBackgroundColor,
                outlineColor,
                primaryColor,
                textColor,
                goldColor,
                isDark,
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(Color primaryColor) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Image.asset(appLogo, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildThemeToggleRow(
    BuildContext context,
    Color cardBg,
    Color outlineColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goldColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: goldColor,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextApp(
                    text: 'وضع المظهر',

                    color: textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 2.h),
                  TextApp(
                    text: isDark ? 'الوضع الداكن مفعل' : 'الوضع الفاتح مفعل',

                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 11.sp,
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isDark,
            activeThumbColor: goldColor,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              if (value) {
                Get.changeThemeMode(ThemeMode.dark);
              } else {
                Get.changeThemeMode(ThemeMode.light);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.notifications, color: primaryColor, size: 20.r),
                SizedBox(width: 8.w),
                TextApp(
                  text: 'التنبيهات',
                  color: textColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            return SwitchListTile(
              title: TextApp(
                text: 'أوقات الصلاة',
                color: textColor,
                fontSize: 14.sp,
              ),

              value: controller.prayerTimeAlerts.value,
              activeThumbColor: primaryColor,
              onChanged: controller.togglePrayerTimeAlerts,
            );
          }),
          Obx(() {
            return SwitchListTile(
              title: TextApp(
                text: 'ورد القراءة اليومي',
                color: textColor,
                fontSize: 14.sp,
              ),

              value: controller.dailyReadingAlerts.value,
              activeThumbColor: primaryColor,
              onChanged: controller.toggleDailyReadingAlerts,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(
    BuildContext context,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.track_changes, color: primaryColor, size: 20.r),
                SizedBox(width: 8.w),
                TextApp(
                  text: "الورد اليومي",

                  color: textColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            return ListTile(
              title: TextApp(
                text: "هدف القراءة اليومي",
                color: textColor,
                fontSize: 14.sp,
              ),

              subtitle: TextApp(
                text: "${controller.dailyGoal.value} آية",
                color: goldColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),

              trailing: Icon(
                Icons.chevron_left,
                color: textColor.withValues(alpha: 0.5),
              ),
              onTap: () {
                _showDailyGoalDialog(context);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAudioCard(
    BuildContext context,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.volume_up, color: primaryColor, size: 20.r),
                SizedBox(width: 8.w),
                TextApp(
                  text: 'الصوتيات',
                  color: textColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            return ListTile(
              title: TextApp(
                text: 'القارئ الافتراضي',
                color: textColor,
                fontSize: 14.sp,
              ),
              subtitle: TextApp(
                text: _getReciterName(controller.selectedReciter.value),
                color: goldColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),

              trailing: Icon(
                Icons.chevron_left,
                color: textColor.withValues(alpha: 0.5),
              ),
              onTap: () {
                _showReciterDialog(context);
              },
            );
          }),
          const Divider(height: 1),
          Obx(() {
            return ListTile(
              title: TextApp(
                text: 'جودة الصوت',
                color: textColor,
                fontSize: 14.sp,
              ),

              subtitle: TextApp(
                text: _getQualityName(controller.audioQuality.value),
                color: goldColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
              trailing: Icon(
                Icons.chevron_left,
                color: textColor.withValues(alpha: 0.5),
              ),
              onTap: () {
                _showQualityDialog(context);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildThemeSelectionCard(
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color textColor,
    Color goldColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.palette, color: primaryColor, size: 20.r),
                SizedBox(width: 8.w),
                TextApp(
                  text: 'اختيار المظهر',
                  color: textColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.changeThemeMode(ThemeMode.dark);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? goldColor : Colors.transparent,
                          width: 2.w,
                        ),
                        color: isDark
                            ? goldColor.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF02160F),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Container(
                                width: 40.w,
                                height: 6.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextApp(
                            text: 'داكن',
                            color: textColor,
                            fontSize: 13.sp,
                            fontWeight: isDark
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.changeThemeMode(ThemeMode.light);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: !isDark ? goldColor : Colors.transparent,
                          width: 2.w,
                        ),
                        color: !isDark
                            ? goldColor.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDFBF7),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.05),
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Container(
                                width: 40.w,
                                height: 6.h,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextApp(
                            text: 'فاتح',
                            color: textColor,
                            fontSize: 13.sp,
                            fontWeight: !isDark
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getReciterName(String key) {
    switch (key) {
      case 'alafasy':
        return 'مشاري راشد العفاسي';
      case 'abdulbasit':
        return 'عبد الباسط عبد الصمد';
      case 'almuaiqly':
        return 'ماهر المعيقلي';
      case 'ghamdi':
        return 'سعد الغامدي';
      default:
        return '';
    }
  }

  String _getQualityName(String key) {
    switch (key) {
      case 'high':
        return 'عالية (HD)';
      case 'medium':
        return 'متوسطة';
      case 'low':
        return 'منخفضة';
      default:
        return '';
    }
  }

  void _showDailyGoalDialog(BuildContext context) {
    final goals = [10, 20, 30, 50, 100];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextApp(
            text: "اختر هدف القراءة اليومي",
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: goals.map((goal) {
                return ListTile(
                  title: TextApp(
                    text: "$goal آية",
                    fontSize: 14.sp,
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    controller.updateDailyGoal(goal);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showReciterDialog(BuildContext context) {
    final reciters = [
      {'key': 'alafasy', 'name': 'مشاري راشد العفاسي'},
      {'key': 'abdulbasit', 'name': 'عبد الباسط عبد الصمد'},
      {'key': 'almuaiqly', 'name': 'ماهر المعيقلي'},
      {'key': 'ghamdi', 'name': 'سعد الغامدي'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextApp(
            text: 'اختر القارئ الافتراضي',
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: reciters.map((reciter) {
                return ListTile(
                  title: TextApp(
                    text: reciter['name']!,
                    fontSize: 14.sp,
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    controller.updateReciter(reciter['key']!);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showQualityDialog(BuildContext context) {
    final qualities = [
      {'key': 'high', 'name': 'عالية (HD)'},
      {'key': 'medium', 'name': 'متوسطة'},
      {'key': 'low', 'name': 'منخفضة'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextApp(
            text: 'اختر جودة الصوت',
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: qualities.map((quality) {
                return ListTile(
                  title: TextApp(
                    text: quality['name']!,
                    fontSize: 14.sp,
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    controller.updateAudioQuality(quality['key']!);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

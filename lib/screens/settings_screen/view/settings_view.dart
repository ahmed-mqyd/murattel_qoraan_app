import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import 'package:murattel_qoraan_app/core/images/images_const.dart';
import 'package:murattel_qoraan_app/core/theme/theme_service.dart';
import '../controller/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);
    final backgroundColor = colors.backgroundColor;
    final cardBackgroundColor = colors.cardBackgroundColor;
    final outlineColor = colors.outlineColor;
    final textColor = colors.textColor;
    final primaryColor = colors.primaryColor;
    final goldColor = colors.goldColor;

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
  ) {
    final themeController = Get.find<ThemeController>();
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
            child: Obx(() {
              final activeMode = themeController.themeModeString;
              return Column(
                children: [
                  Row(
                    children: [
                      // 1. Light Theme
                      Expanded(
                        child: _buildThemeItem(
                          title: 'فاتح',
                          mode: 'light',
                          activeMode: activeMode,
                          goldColor: goldColor,
                          textColor: textColor,
                          previewColor: const Color(0xFFFDFBF7),
                          previewSubColor: Colors.black.withValues(alpha: 0.1),
                          onTap: () => themeController.setThemeMode('light'),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // 2. Dark Theme
                      Expanded(
                        child: _buildThemeItem(
                          title: 'داكن',
                          mode: 'dark',
                          activeMode: activeMode,
                          goldColor: goldColor,
                          textColor: textColor,
                          previewColor: const Color(0xFF02160F),
                          previewSubColor: Colors.white.withValues(alpha: 0.2),
                          onTap: () => themeController.setThemeMode('dark'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      // 3. Sepia Theme (Warm Paper)
                      Expanded(
                        child: _buildThemeItem(
                          title: 'ورقي دافئ',
                          mode: 'sepia',
                          activeMode: activeMode,
                          goldColor: goldColor,
                          textColor: textColor,
                          previewColor: const Color(0xFFF4ECD8),
                          previewSubColor: const Color(0xFF3E2723).withValues(alpha: 0.15),
                          onTap: () => themeController.setThemeMode('sepia'),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // 4. System Theme
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            themeController.setThemeMode('system');
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: activeMode == 'system' ? goldColor : Colors.transparent,
                                width: 2.w,
                              ),
                              color: activeMode == 'system'
                                  ? goldColor.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.04),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.black.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF02160F),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(7.r),
                                              bottomRight: Radius.circular(7.r),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 18.w,
                                              height: 4.h,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(2.r),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFDFBF7),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(7.r),
                                              bottomLeft: Radius.circular(7.r),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 18.w,
                                              height: 4.h,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(2.r),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                TextApp(
                                  text: 'تلقائي',
                                  color: textColor,
                                  fontSize: 13.sp,
                                  fontWeight: activeMode == 'system'
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
                ],
              );
            }),
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
      case 'faresabbad':
        return 'فارس عباد';
      case 'yasser':
        return 'ياسر الدوسري';
      case 'islamsobhi':
        return 'إسلام صبحي';
      case 'ahmedshafei':
        return 'أحمد الشافعي';
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
      {'key': 'faresabbad', 'name': 'فارس عباد'},
      {'key': 'yasser', 'name': 'ياسر الدوسري'},
      {'key': 'islamsobhi', 'name': 'إسلام صبحي'},
      {'key': 'ahmedshafei', 'name': 'أحمد الشافعي'},
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

  Widget _buildThemeItem({
    required String title,
    required String mode,
    required String activeMode,
    required Color goldColor,
    required Color textColor,
    required Color previewColor,
    required Color previewSubColor,
    required VoidCallback onTap,
  }) {
    final bool isActive = activeMode == mode;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive ? goldColor : Colors.transparent,
            width: 2.w,
          ),
          color: isActive
              ? goldColor.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),
        child: Column(
          children: [
            Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: previewColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1.w,
                ),
              ),
              child: Center(
                child: Container(
                  width: 40.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: previewSubColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TextApp(
              text: title,
              color: textColor,
              fontSize: 13.sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ],
        ),
      ),
    );
  }
}

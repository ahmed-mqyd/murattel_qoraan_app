import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/images/images_const.dart';
import 'package:murattel_qoraan_app/core/routes/app_routes.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/utils/app_links.dart';

class _DrawerItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

/// القائمة الجانبية — تستضيف الخدمات الثانوية التي لا تحتاج ظهورًا دائمًا
/// على الشاشة الرئيسية (القبلة، المواقيت، المسبحة، الوصية، التنزيلات)
/// لتخفيف الازدحام هناك مع إبقائها في متناول اليد من أي شاشة.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? const Color(0xFF02160F)
        : const Color(0xFFFDFBF7);
    final Color textColor = isDark
        ? const Color(0xFFE2E2E5)
        : const Color(0xFF1A1C1E);
    final Color primaryColor = isDark
        ? const Color(0xFFA0D1BC)
        : const Color(0xFF003527);
    const Color goldColor = Color(0xFFC5A059);

    final items = <_DrawerItem>[
      _DrawerItem(
        icon: Icons.explore_outlined,
        title: 'القبلة',
        subtitle: 'تحديد اتجاه الصلاة',
        onTap: () => Get.toNamed(Routes.qibla),
      ),
      _DrawerItem(
        icon: Icons.schedule,
        title: 'مواقيت الصلاة',
        subtitle: 'أوقات الصلوات الخمس',
        onTap: () => Get.toNamed(Routes.prayerTimes),
      ),
      _DrawerItem(
        icon: Icons.shield_moon_outlined,
        title: 'حصن المسلم',
        subtitle: 'مكتبة الأذكار والأدعية الكاملة',
        onTap: () => Get.toNamed(Routes.azkarLibrary),
      ),
      _DrawerItem(
        icon: Icons.fingerprint,
        title: 'المسبحة',
        subtitle: 'التسبيح والاستغفار',
        onTap: () => Get.toNamed(Routes.tasbeeh),
      ),
      _DrawerItem(
        icon: Icons.assignment_outlined,
        title: 'الوصية',
        subtitle: 'وصية إبراهيم المقيد',
        onTap: () => Get.toNamed(Routes.wasiya),
      ),
      _DrawerItem(
        icon: Icons.download_outlined,
        title: 'التنزيلات',
        subtitle: 'التلاوات المحفوظة للاستماع دون اتصال',
        onTap: () => Get.toNamed(Routes.downloads),
      ),
      _DrawerItem(
        icon: Icons.star_rounded,
        title: 'قيّم التطبيق',
        subtitle: 'ادعمنا بتقييمك على متجر Play',
        onTap: () => rateApp(),
      ),
      _DrawerItem(
        icon: Icons.share_rounded,
        title: 'شارك التطبيق',
        subtitle: 'انشر الأجر وشارك التطبيق مع أحبابك',
        onTap: () => shareApp(),
      ),
    ];

    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: goldColor, width: 1.5.w),
                    ),
                    child: Image.asset(appLogo, fit: BoxFit.contain),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: TextApp(
                      text: 'مرتل القرآن',
                      color: isDark ? const Color(0xFF003527) : Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: 6.h),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14.r),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Get.back(); // إغلاق القائمة الجانبية أولاً
                        item.onTap();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 10.w,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42.w,
                              height: 42.w,
                              decoration: BoxDecoration(
                                color: goldColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                color: goldColor,
                                size: 22.r,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextApp(
                                    text: item.title,
                                    color: textColor,
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(height: 2.h),
                                  TextApp(
                                    text: item.subtitle,
                                    color: textColor.withValues(alpha: 0.6),
                                    fontSize: 11.5.sp,
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
            ),
          ],
        ),
      ),
    );
  }
}

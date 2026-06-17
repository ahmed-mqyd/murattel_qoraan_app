import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/prayer_times_controller.dart';

class PrayerTimesView extends GetView<PrayerTimesController> {
  const PrayerTimesView({super.key});

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
    final Color primaryColor = isDark
        ? const Color(0xFFA0D1BC)
        : const Color(0xFF003527);
    final Color goldColor = const Color(0xFFC5A059);
    final Color textColor = isDark
        ? const Color(0xFFE2E2E5)
        : const Color(0xFF1A1C1E);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: TextApp(
          text: "مواقيت الصلاة",
          color: primaryColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: primaryColor),
            tooltip: 'تحديث الموقع',
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.fetchPrayerTimes(forceRefresh: true);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: goldColor));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Next Prayer Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: Column(
                  children: [
                    TextApp(
                      text:
                          "الصلاة القادمة: ${controller.nextPrayerName.value}",
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      controller.nextPrayerTime.value,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: goldColor,
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: goldColor.withValues(alpha: 0.8),
                          size: 16.r,
                        ),
                        SizedBox(width: 4.w),
                        TextApp(
                          text: controller.locationName.value,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Prayer Times List
              ...controller.prayerTimes.entries.map(
                (entry) => _buildPrayerItem(
                  entry.key,
                  entry.value,
                  cardBackgroundColor,
                  primaryColor,
                  goldColor,
                  textColor,
                  controller.nextPrayerName.value == entry.key,
                ),
              ),

              SizedBox(height: 32.h),
              Text(
                "قَالَ رَسُولُ اللَّهِ ﷺ: «أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ الصَّلاةُ عَلَى وَقْتِهَا»",
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  textStyle: TextStyle(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 16.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPrayerItem(
    String name,
    String time,
    Color bg,
    Color primary,
    Color gold,
    Color text,
    bool isNext,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isNext ? gold : gold.withValues(alpha: 0.1),
          width: isNext ? 1.5.w : 1.w,
        ),
        boxShadow: isNext
            ? [BoxShadow(color: gold.withValues(alpha: 0.1), blurRadius: 8.r)]
            : AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getIconForPrayer(name),
                color: isNext ? gold : primary.withValues(alpha: 0.7),
                size: 24.r,
              ),
              SizedBox(width: 16.w),
              TextApp(
                text: name,
                color: text,
                fontSize: 16.sp,
                fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              ),
            ],
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              textStyle: TextStyle(
                color: isNext ? gold : text,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPrayer(String name) {
    switch (name) {
      case 'الفجر':
        return Icons.wb_twilight;
      case 'الشروق':
        return Icons.wb_sunny_outlined;
      case 'الظهر':
        return Icons.wb_sunny;
      case 'العصر':
        return Icons.wb_cloudy_outlined;
      case 'المغرب':
        return Icons.nightlight_round;
      case 'العشاء':
        return Icons.bedtime;
      default:
        return Icons.schedule;
    }
  }
}

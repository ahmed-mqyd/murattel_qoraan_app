import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/qibla_controller.dart';

class QiblaView extends GetView<QiblaController> {
  const QiblaView({super.key});

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cardBackgroundColor,
            border: Border.all(color: outlineColor, width: 1.w),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: primaryColor,
              size: 16.r,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Get.back();
            },
          ),
        ),
        title: Text(
          'القبلة',
          style: GoogleFonts.getFont(
            'Noto Naskh Arabic',
            textStyle: TextStyle(
              color: primaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMarginMobile.w,
                  vertical: 12.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. City selection and angle readout
                    _buildCitySelector(
                      context,
                      cardBackgroundColor,
                      outlineColor,
                      textColor,
                      primaryColor,
                      goldColor,
                    ),
                    SizedBox(height: 20.h),

                    // 2. Alignment status banner
                    _buildStatusBanner(
                      primaryColor,
                      goldColor,
                      textColor,
                      isDark,
                    ),
                    SizedBox(height: 24.h),

                    // 3. Interactive Compass
                    _buildInteractiveCompass(
                      context,
                      cardBackgroundColor,
                      outlineColor,
                      primaryColor,
                      goldColor,
                      textColor,
                      isDark,
                    ),
                    SizedBox(height: 24.h),

                    // 4. Instructions and Information card
                    _buildInfoCard(
                      cardBackgroundColor,
                      outlineColor,
                      textColor,
                      primaryColor,
                      goldColor,
                      isDark,
                    ),
                    SizedBox(height: 24.h),

                    // 5. Simulated Auto-rotate (demo purposes)
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.toggleAutoRotate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.autoRotate.value
                            ? goldColor
                            : primaryColor,
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
                        controller.autoRotate.value
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        size: 18.r,
                      ),
                      label: Text(controller.autoRotate.value
                            ? 'إيقاف المحاكاة'
                            : 'بدء المحاكاة',
                        style: GoogleFonts.getFont(
                          'Noto Naskh Arabic',
                          textStyle: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
              if (controller.isLoadingLocation.value)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 20.h,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: outlineColor),
                        boxShadow: AppTheme.shadowMd,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: goldColor),
                          SizedBox(height: 16.h),
                          Text('جاري تحديد موقعك عبر GPS...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              'Noto Naskh Arabic',
                              textStyle: TextStyle(
                                color: textColor,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCitySelector(
    BuildContext context,
    Color cardBg,
    Color outlineColor,
    Color textColor,
    Color primaryColor,
    Color goldColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المدينة الحالية',
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 11.sp,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(() {
                  final String cityKey = controller.selectedCity.value;
                  final String coords = controller.gpsCoords.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getCityName(cityKey),
                        style: GoogleFonts.getFont(
                          'Noto Naskh Arabic',
                          textStyle: TextStyle(
                            color: textColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (coords.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(coords,
                          style: GoogleFonts.getFont(
                            'Outfit',
                            textStyle: TextStyle(
                              color: textColor.withValues(alpha: 0.5),
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showCityPicker(
              context,
              primaryColor,
              cardBg,
              textColor,
              goldColor,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor.withValues(alpha: 0.08),
              foregroundColor: primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 1.w,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('تغيير الموقع',
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.location_on_rounded, size: 14.r),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(
    Color primaryColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    final bool aligned = controller.isAligned.value;
    final Color bannerColor = aligned
        ? const Color(0xFF064E3B).withValues(alpha: isDark ? 0.4 : 0.08)
        : goldColor.withValues(alpha: isDark ? 0.3 : 0.08);
    final Color borderCol = aligned
        ? const Color(0xFF10B981).withValues(alpha: 0.4)
        : goldColor.withValues(alpha: 0.4);
    final Color textCol = aligned
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
        : goldColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderCol, width: 1.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            aligned ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: textCol,
            size: 20.r,
          ),
          SizedBox(width: 8.w),
          Text(aligned
                ? 'متحاذي مع القبلة'
                : 'أدر الهاتف باتجاه الكعبة',
            style: GoogleFonts.getFont(
              'Noto Naskh Arabic',
              textStyle: TextStyle(
                color: textCol,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCompass(
    BuildContext context,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    return Obx(() {
      final double heading = controller.currentHeading.value;
      final double qibla = controller.qiblaAngle.value;
      final bool aligned = controller.isAligned.value;

      return GestureDetector(
        onPanUpdate: (details) {
          // Allow manual orientation dragging to simulate phone rotation
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final Offset localPos = renderBox.globalToLocal(
              details.globalPosition,
            );
            final double centerX = renderBox.size.width / 2;
            final double centerY = renderBox.size.height / 2;
            final double dx = localPos.dx - centerX;
            final double dy = localPos.dy - centerY;
            final double angleRad = atan2(dy, dx);
            double angleDeg = angleRad * 180 / pi;
            // Map 0 to top (North) instead of East (right)
            double heading = (angleDeg + 90 + 360) % 360;
            controller.updateHeading(heading);
          }
        },
        child: Container(
          width: 280.w,
          height: 280.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cardBg,
            border: Border.all(
              color: aligned ? const Color(0xFF10B981) : outlineColor,
              width: aligned ? 3.w : 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: aligned
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                blurRadius: 20.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Compass dial degree lines (Rotates based on heading)
              Transform.rotate(
                angle: -heading * pi / 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dial markings
                    ...List.generate(12, (index) {
                      final double deg = index * 30.0;
                      final bool isCardinal = deg % 90 == 0;
                      return Transform.rotate(
                        angle: deg * pi / 180,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 8.h),
                            width: isCardinal ? 3.w : 1.w,
                            height: isCardinal ? 12.h : 8.h,
                            color: isCardinal
                                ? goldColor
                                : textColor.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    }),
                    // Cardinal labels (Arabic/English cardinal values)
                    _buildCardinalLabel(
                      0,
                      'شمال',
                      textColor,
                      goldColor,
                    ),
                    _buildCardinalLabel(
                      90,
                      'شرق',
                      textColor,
                      goldColor,
                    ),
                    _buildCardinalLabel(
                      180,
                      'جنوب',
                      textColor,
                      goldColor,
                    ),
                    _buildCardinalLabel(
                      270,
                      'غرب',
                      textColor,
                      goldColor,
                    ),

                    // 2. Kaaba Icon placed exactly at the Qibla angle relative to the dial
                    Transform.rotate(
                      angle: qibla * pi / 180,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.only(top: 24.h),
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: goldColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mosque_rounded,
                            color: const Color(0xFF003527),
                            size: 20.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Central Phone pointer (Stays static pointing straight up, representing phone heading)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: aligned ? const Color(0xFF10B981) : goldColor,
                    size: 36.r,
                  ),
                ),
              ),

              // 4. Center readout hub
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF02160F)
                      : const Color(0xFFF9F8F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: outlineColor, width: 2.w),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${controller.toArabicNumbers(heading.toStringAsFixed(0))}°',
                      style: GoogleFonts.getFont(
                        'Outfit',
                        textStyle: TextStyle(
                          color: aligned ? const Color(0xFF10B981) : textColor,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(aligned
                          ? 'جاهز'
                          : 'غير دقيق',
                      style: GoogleFonts.getFont(
                        'Noto Naskh Arabic',
                        textStyle: TextStyle(
                          color: aligned
                              ? const Color(0xFF10B981)
                              : textColor.withValues(alpha: 0.5),
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCardinalLabel(
    double angle,
    String text,
    Color textColor,
    Color goldColor,
  ) {
    return Transform.rotate(
      angle: angle * pi / 180,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 22.h),
          child: Text(text,
            style: GoogleFonts.getFont(
              'Noto Naskh Arabic',
              textStyle: TextStyle(
                color: angle == 0
                    ? goldColor
                    : textColor.withValues(alpha: 0.6),
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    Color cardBg,
    Color outlineColor,
    Color textColor,
    Color primaryColor,
    Color goldColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: outlineColor, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Obx(() {
        final double qibla = controller.qiblaAngle.value;
        final String angleStr = '${controller.toArabicNumbers(qibla.toStringAsFixed(0))}° شمالاً شرقاً';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.explore, color: goldColor, size: 20.r),
                SizedBox(width: 8.w),
                Text('تفاصيل القبلة',
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      color: textColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('زاوية القبلة', angleStr, textColor),
            _buildInfoRow(
              'المسافة إلى الكعبة',
              controller.distanceToKaaba.value,
              textColor,
            ),
            _buildInfoRow(
              'حالة البوصلة',
              'جاهزة',
              textColor,
            ),
            const Divider(height: 24),
            Text('ملاحظة: للحصول على أفضل دقة، ضع الهاتف بشكل مسطح وابتعد عن الأجهزة المغناطيسية.',
              style: GoogleFonts.getFont(
                'Noto Naskh Arabic',
                textStyle: TextStyle(
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 11.sp,
                  height: 1.5,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(String title, String val, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style: GoogleFonts.getFont(
              'Noto Naskh Arabic',
              textStyle: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 13.sp,
              ),
            ),
          ),
          Text(val,
            style: GoogleFonts.getFont(
              'Outfit',
              textStyle: TextStyle(
                color: textColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCityPicker(
    BuildContext context,
    Color primaryColor,
    Color cardBg,
    Color textColor,
    Color goldColor,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text('اختر المدينة',
              style: GoogleFonts.getFont(
                'Noto Naskh Arabic',
                textStyle: TextStyle(
                  color: primaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            ...controller.cities.map((city) {
              final String key = city['key'] as String;
              final double angle = controller.getAngleForCity(city);
              final String distance = controller.getDistanceForCity(city);

              return ListTile(
                title: Text(_getCityName(key),
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(color: textColor, fontSize: 14.sp),
                  ),
                ),
                subtitle: Text(key == 'gpsCurrentLocation' &&
                          controller.selectedCity.value != 'gpsCurrentLocation'
                      ? 'استخدام موقعك الحالي عبر GPS لمزيد من الدقة'
                      : 'الزاوية: ${controller.toArabicNumbers(angle.toStringAsFixed(0))}° - المسافة: $distance',
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 11.sp,
                    ),
                  ),
                ),
                trailing: Obx(
                  () => controller.selectedCity.value == key
                      ? Icon(Icons.check_circle_rounded, color: goldColor)
                      : const SizedBox.shrink(),
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.setCity(key);
                  Get.back();
                },
              );
            }),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _getCityName(String key) {
    switch (key) {
      case 'jerusalem':
        return 'القدس الشريف';
      case 'mecca':
        return 'مكة المكرمة';
      case 'gpsCurrentLocation':
        return 'موقعي الحالي (GPS)';
      default:
        return '';
    }
  }
}

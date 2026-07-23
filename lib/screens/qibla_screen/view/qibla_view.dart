import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
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
    final Color warningColor = const Color(0xFFDC6803);

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
        title: TextApp(
          text: 'القبلة',
          color: primaryColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
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
                      warningColor,
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
                      warningColor,
                      isDark,
                    ),
                    SizedBox(height: 24.h),

                    // 4.5. Qibla Calibration Card
                    _buildCalibrationCard(
                      cardBackgroundColor,
                      outlineColor,
                      textColor,
                      goldColor,
                      isDark,
                    ),
                    SizedBox(height: 24.h),

                    // 5. دوران تلقائي تجريبي — بديل فقط عند غياب بوصلة حقيقية
                    // (لو فيه بوصلة شغّالة فهي مصدر الحقيقة، وده هيتعارض معاها)
                    if (!controller.hasRealCompassSensor.value) ...[
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
                        label: TextApp(
                          text: controller.autoRotate.value
                              ? 'إيقاف المحاكاة'
                              : 'بدء المحاكاة',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
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
                          TextApp(
                            text: 'جاري تحديد موقعك عبر GPS...',
                            textAlign: TextAlign.center,
                            color: textColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
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
                TextApp(
                  text: 'المدينة الحالية',
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 11.sp,
                ),
                SizedBox(height: 4.h),
                Obx(() {
                  final String cityKey = controller.selectedCity.value;
                  final String coords = controller.gpsCoords.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextApp(
                        text: _getCityName(cityKey),
                        color: textColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      if (coords.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          coords,
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
                TextApp(
                  text: 'تغيير الموقع',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
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
    Color warningColor,
    Color textColor,
    bool isDark,
  ) {
    final bool unavailable = controller.compassUnavailable.value;
    final bool aligned = controller.isAligned.value;

    final Color bannerColor = unavailable
        ? warningColor.withValues(alpha: isDark ? 0.25 : 0.1)
        : aligned
        ? const Color(0xFF064E3B).withValues(alpha: isDark ? 0.4 : 0.08)
        : goldColor.withValues(alpha: isDark ? 0.3 : 0.08);
    final Color borderCol = unavailable
        ? warningColor.withValues(alpha: 0.5)
        : aligned
        ? const Color(0xFF10B981).withValues(alpha: 0.4)
        : goldColor.withValues(alpha: 0.4);
    final Color textCol = unavailable
        ? warningColor
        : aligned
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
            unavailable
                ? Icons.warning_amber_rounded
                : aligned
                ? Icons.check_circle_rounded
                : Icons.explore_rounded,
            color: textCol,
            size: 20.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextApp(
              text: unavailable
                  ? 'بوصلة الجهاز غير متوفرة — استخدم السحب اليدوي على القرص لتحديد اتجاهك'
                  : controller.getTurnInstruction(),
              color: textCol,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
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
          // البوصلة الحقيقية هي مصدر الحقيقة أثناء عملها — نتجاهل السحب
          // اليدوي وقتها لأنه هيتبلع فوراً بأول قراءة حقيقية جاية.
          if (controller.hasRealCompassSensor.value) return;
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
            double heading = (angleDeg + 90 + 360) % 360;
            controller.updateHeading(heading);
          }
        },
        child: Container(
          width: 300.w,
          height: 300.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cardBg.withValues(alpha: 0.85),
            border: Border.all(
              color: aligned ? const Color(0xFF10B981) : outlineColor,
              width: aligned ? 4.w : 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: aligned
                    ? const Color(0xFF10B981).withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                blurRadius: 24.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: -heading * pi / 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(36, (index) {
                      final double deg = index * 10.0;
                      final bool isCardinal = deg % 90 == 0;
                      final bool isSubCardinal = deg % 30 == 0 && !isCardinal;
                      return Transform.rotate(
                        angle: deg * pi / 180,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 10.h),
                            width: isCardinal
                                ? 3.w
                                : (isSubCardinal ? 2.w : 1.w),
                            height: isCardinal
                                ? 14.h
                                : (isSubCardinal ? 10.h : 6.h),
                            color: isCardinal
                                ? goldColor
                                : (isSubCardinal
                                      ? textColor.withValues(alpha: 0.5)
                                      : textColor.withValues(alpha: 0.25)),
                          ),
                        ),
                      );
                    }),
                    _buildCardinalLabel(0, 'شمال', textColor, goldColor),
                    _buildCardinalLabel(90, 'شرق', textColor, goldColor),
                    _buildCardinalLabel(180, 'جنوب', textColor, goldColor),
                    _buildCardinalLabel(270, 'غرب', textColor, goldColor),
                    Transform.rotate(
                      angle: qibla * pi / 180,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.only(top: 26.h),
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: goldColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mosque_rounded,
                            color: const Color(0xFF003527),
                            size: 16.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: (qibla - heading) * pi / 180,
                child: SizedBox(
                  width: 200.w,
                  height: 200.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.only(top: 28.h),
                          width: 4.w,
                          height: 72.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC5A059), Color(0xFFF9E8A2)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(2.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFC5A059,
                                ).withValues(alpha: 0.4),
                                blurRadius: 4.r,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14.h,
                        child: Icon(
                          Icons.navigation_rounded,
                          color: const Color(0xFFC5A059),
                          size: 24.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF02160F).withValues(alpha: 0.9)
                      : const Color(0xFFFDFBF7).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: aligned ? const Color(0xFF10B981) : outlineColor,
                    width: 2.w,
                  ),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${controller.toArabicNumbers(heading.toStringAsFixed(0))}°',
                      style: GoogleFonts.getFont(
                        'Outfit',
                        textStyle: TextStyle(
                          color: aligned ? const Color(0xFF10B981) : textColor,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextApp(
                      text: aligned ? 'متحاذي' : 'أدر الهاتف',
                      color: aligned
                          ? const Color(0xFF10B981)
                          : textColor.withValues(alpha: 0.5),
                      fontSize: 9.sp,
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
          padding: EdgeInsets.only(top: 26.h),
          child: TextApp(
            text: text,
            color: angle == 0 ? goldColor : textColor.withValues(alpha: 0.6),
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
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
    Color warningColor,
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
        final String directionName = controller.getCardinalDirectionName(qibla);
        final String angleStr =
            '${controller.toArabicNumbers(qibla.toStringAsFixed(0))}° $directionName';

        final bool unavailable = controller.compassUnavailable.value;
        final bool sensorReady = controller.hasRealCompassSensor.value;
        final String compassStatusText = unavailable
            ? 'غير متوفرة'
            : (sensorReady ? 'جاهزة' : 'جارٍ الكشف...');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.explore, color: goldColor, size: 20.r),
                SizedBox(width: 8.w),
                TextApp(
                  text: 'تفاصيل القبلة',
                  color: textColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
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
              compassStatusText,
              textColor,
              valueColor: unavailable ? warningColor : null,
            ),
            const Divider(height: 24),
            TextApp(
              text:
                  'ملاحظة: للحصول على أفضل دقة، ضع الهاتف بشكل مسطح وابتعد عن الأجهزة المغناطيسية.',
              color: textColor.withValues(alpha: 0.5),
              fontSize: 11.sp,
              height: 1.5,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCalibrationCard(
    Color cardBg,
    Color outlineColor,
    Color textColor,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.screen_rotation_rounded, color: goldColor, size: 20.r),
              SizedBox(width: 8.w),
              TextApp(
                text: 'طريقة معايرة البوصلة',
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextApp(
                  text:
                      'للحصول على أفضل دقة وتجنب التداخل المغناطيسي، يرجى تدوير الهاتف في الهواء على شكل الرقم 8 (♾️) مرتين أو ثلاث مرات، مع إبقائه في وضع أفقي مسطح.',
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                  height: 1.6,
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.all_inclusive_rounded,
                    color: goldColor,
                    size: 32.r,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String val,
    Color textColor, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextApp(
            text: title,
            color: textColor.withValues(alpha: 0.7),
            fontSize: 13.sp,
          ),
          Text(
            val,
            style: GoogleFonts.getFont(
              'Outfit',
              textStyle: TextStyle(
                color: valueColor ?? textColor,
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
            TextApp(
              text: 'اختر المدينة',
              color: primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            ...controller.cities.map((city) {
              final String key = city['key'] as String;
              final double angle = controller.getAngleForCity(city);
              final String distance = controller.getDistanceForCity(city);

              return ListTile(
                title: TextApp(
                  text: _getCityName(key),
                  color: textColor,
                  fontSize: 14.sp,
                ),
                subtitle: TextApp(
                  text:
                      key == 'gpsCurrentLocation' &&
                          controller.selectedCity.value != 'gpsCurrentLocation'
                      ? 'استخدام موقعك الحالي عبر GPS لمزيد من الدقة'
                      : 'الزاوية: ${controller.toArabicNumbers(angle.toStringAsFixed(0))}° - المسافة: $distance',
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 11.sp,
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
      case 'gaza':
        return 'غزة الأبية';
      case 'cairo':
        return 'القاهرة';
      case 'madinah':
        return 'المدينة المنورة';
      case 'riyadh':
        return 'الرياض';
      case 'mecca':
        return 'مكة المكرمة';
      case 'gpsCurrentLocation':
        return 'موقعي الحالي (GPS)';
      default:
        return '';
    }
  }
}

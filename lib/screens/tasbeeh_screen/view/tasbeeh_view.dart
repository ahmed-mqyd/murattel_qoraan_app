import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/tasbeeh_controller.dart';

class TasbeehView extends GetView<TasbeehController> {
  const TasbeehView({super.key});

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
        title: Text(
          'المسبحة الإلكترونية',
          style: GoogleFonts.getFont(
            'Noto Naskh Arabic',
            textStyle: TextStyle(
              color: primaryColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),

            // 1. Zikr Selector horizontal chips
            _buildZikrSelector(
              primaryColor,
              goldColor,
              cardBackgroundColor,
              outlineColor,
              textColor,
            ),

            SizedBox(height: 20.h),

            // 2. Target Selector Row
            _buildTargetSelector(
              primaryColor,
              goldColor,
              cardBackgroundColor,
              outlineColor,
              textColor,
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3. Cycle Counter Indicator
                  Obx(() {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: goldColor.withValues(alpha: 0.3),
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        'الدورات: ${_toArabicNumbers(controller.cycleCount.value.toString())}',
                        style: GoogleFonts.getFont(
                          'Noto Naskh Arabic',
                          textStyle: TextStyle(
                            color: goldColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: 24.h),

                  // 4. Large Interactive Tap Button
                  _buildInteractiveButton(
                    primaryColor,
                    goldColor,
                    cardBackgroundColor,
                    outlineColor,
                    textColor,
                    isDark,
                  ),
                ],
              ),
            ),

            // 5. Daily Total Progress Card & Control Buttons
            _buildBottomControls(
              primaryColor,
              goldColor,
              cardBackgroundColor,
              outlineColor,
              textColor,
              isDark,
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildZikrSelector(
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
  ) {
    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: controller.zikrList.length,
        itemBuilder: (context, index) {
          final zikr = controller.zikrList[index];
          return Obx(() {
            final isSelected = controller.selectedZikrIndex.value == index;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                controller.selectZikr(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? primary : cardBg,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isSelected ? primary : outline,
                    width: 1.w,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  zikr.text,
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      color: isSelected ? Colors.white : text,
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildTargetSelector(
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تحديد الهدف اليومي:',
            style: GoogleFonts.getFont(
              'Noto Naskh Arabic',
              textStyle: TextStyle(
                color: text.withValues(alpha: 0.7),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: controller.targetOptions.map((target) {
              return Obx(() {
                final isSelected = controller.targetCount.value == target;
                final String label = target == 0
                    ? 'حر'
                    : _toArabicNumbers(target.toString());
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.setTarget(target);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 6.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? gold : cardBg,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected ? gold : outline,
                        width: 1.w,
                      ),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.getFont(
                        'Noto Naskh Arabic',
                        textStyle: TextStyle(
                          color: isSelected ? Colors.white : text,
                          fontSize: 12.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveButton(
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
    bool isDark,
  ) {
    final scale = 1.0.obs;

    return GestureDetector(
      onTapDown: (_) {
        scale.value = 0.92;
        HapticFeedback.mediumImpact();
        controller.increment();
      },
      onTapUp: (_) {
        scale.value = 1.0;
      },
      onTapCancel: () {
        scale.value = 1.0;
      },
      child: Obx(() {
        final countStr = _toArabicNumbers(
          controller.currentCount.value.toString(),
        );
        final targetStr = controller.targetCount.value == 0
            ? '∞'
            : _toArabicNumbers(controller.targetCount.value.toString());

        return AnimatedScale(
          scale: scale.value,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 250.w,
            height: 250.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardBg,
              border: Border.all(color: gold, width: 4.w),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.15),
                  blurRadius: 24.r,
                  spreadRadius: 4.r,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner concentric circle
                Container(
                  width: 234.w,
                  height: 234.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.1),
                      width: 2.w,
                    ),
                  ),
                ),

                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Chosen Zikr
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        controller.currentZikr.text,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.amiri(
                          textStyle: TextStyle(
                            color: primary,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Counter
                    Text(
                      countStr,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: text,
                          fontSize: 52.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    // Separator line
                    Container(
                      width: 60.w,
                      height: 1.5.h,
                      color: gold.withValues(alpha: 0.4),
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                    ),

                    // Target
                    Text(
                      targetStr,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: text.withValues(alpha: 0.4),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomControls(
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: outline, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          // Daily Total Row
          Obx(() {
            final dailyVal = controller.dailyTotalCount.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: gold, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      'مجموع التسبيحات اليوم:',
                      style: GoogleFonts.getFont(
                        'Noto Naskh Arabic',
                        textStyle: TextStyle(
                          color: text,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_toArabicNumbers(dailyVal.toString())} / ١٠٠',
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      color: gold,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }),

          SizedBox(height: 8.h),

          // Daily progress bar
          Obx(() {
            final dailyVal = controller.dailyTotalCount.value;
            final progress = (dailyVal / 100.0).clamp(0.0, 1.0);
            return ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(gold),
              ),
            );
          }),

          SizedBox(height: 16.h),

          // Control buttons (Reset)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showResetDialog();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.red.shade600,
                    size: 18.r,
                  ),
                  label: Text(
                    'إعادة ضبط',
                    style: GoogleFonts.getFont(
                      'Noto Naskh Arabic',
                      textStyle: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    Get.defaultDialog(
      title: 'إعادة تعيين العداد',
      titleStyle: GoogleFonts.getFont(
        'Noto Naskh Arabic',
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      middleText: 'هل تريد تصفير العداد الحالي أم إعادة تعيين كل البيانات؟',
      middleTextStyle: GoogleFonts.getFont('Noto Naskh Arabic'),
      backgroundColor: Colors.white,
      radius: 16.r,
      textConfirm: 'تصفير العداد',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF003527),
      textCancel: 'إلغاء',
      cancelTextColor: const Color(0xFF003527),
      onConfirm: () {
        controller.resetCurrent();
        Get.back();
      },
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

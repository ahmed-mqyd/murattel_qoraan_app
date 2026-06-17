import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/azkar_controller.dart';

class AzkarView extends GetView<AzkarController> {
  const AzkarView({super.key});

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
        title: TextApp(
          text: "أذكار المسلم",
          color: primaryColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: () => _showResetConfirmDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final azkarList = controller.currentAzkar;
          final currentIndex = controller.selectedDhikrIndex.value;
          final isCategoryDone = controller.isCompleted.value;

          return Stack(
            children: [
              Column(
                children: [
                  // 1. Category selector
                  _buildCategorySelector(primaryColor, goldColor, textColor, isDark),
                  SizedBox(height: 10.h),

                  if (azkarList.isNotEmpty) ...[
                    // 2. Step Selector (Chips matching Wasiya screen)
                    _buildStepSelector(
                      azkarList,
                      currentIndex,
                      primaryColor,
                      goldColor,
                      cardBackgroundColor,
                      outlineColor,
                      textColor,
                    ),
                    SizedBox(height: 20.h),

                    // 3. Central Content Area
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Dhikr text card (styled like Wasiya reading card)
                          _buildDhikrTextCard(
                            azkarList[currentIndex],
                            cardBackgroundColor,
                            outlineColor,
                            textColor,
                            goldColor,
                          ),
                          SizedBox(height: 24.h),

                          // Concentric counter button (styled like Wasiya counter button)
                          _buildConcentricCounterButton(
                            azkarList[currentIndex],
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

                    // 4. Bottom progress display & Navigation Arrows (styled like Wasiya bottom controls)
                    _buildBottomProgressAndControls(
                      azkarList,
                      currentIndex,
                      primaryColor,
                      goldColor,
                      cardBackgroundColor,
                      outlineColor,
                      textColor,
                      isDark,
                    ),
                    SizedBox(height: 16.h),
                  ] else ...[
                    const Expanded(
                      child: Center(
                        child: TextApp(
                          text: "لا توجد أذكار متوفرة حالياً",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Success overlay
              if (isCategoryDone)
                _buildSuccessBanner(backgroundColor, primaryColor, goldColor),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategorySelector(
    Color primary,
    Color gold,
    Color text,
    bool isDark,
  ) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildCategoryItem('morning', 'أذكار الصباح', Icons.wb_sunny_outlined, primary, gold, text),
          _buildCategoryItem('evening', 'أذكار المساء', Icons.nightlight_round_outlined, primary, gold, text),
          _buildCategoryItem('after_prayer', 'بعد الصلاة', Icons.mosque_outlined, primary, gold, text),
          _buildCategoryItem('sleep', 'أذكار النوم', Icons.bedtime_outlined, primary, gold, text),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String id,
    String label,
    IconData icon,
    Color primary,
    Color gold,
    Color text,
  ) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == id;
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          controller.setCategory(id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.only(left: 10.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isSelected ? primary : primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: isSelected ? gold : Colors.transparent,
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? gold : primary, size: 18.r),
              SizedBox(width: 8.w),
              TextApp(
                text: label,
                color: isSelected ? Colors.white : primary,
                fontSize: 12.5.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStepSelector(
    List<Dhikr> azkarList,
    int currentIndex,
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
  ) {
    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: azkarList.length,
        itemBuilder: (context, index) {
          final isSelected = currentIndex == index;
          final dhikr = azkarList[index];
          final isStepDone = dhikr.isFinished.value;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              controller.selectDhikr(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: isSelected ? primary : cardBg,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? primary
                      : (isStepDone ? gold.withValues(alpha: 0.6) : outline),
                  width: 1.2.w,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  if (isStepDone) ...[
                    Icon(
                      Icons.check_circle,
                      color: isSelected ? Colors.white : gold,
                      size: 13.r,
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    'الذكر ${_toArabicNumbers((index + 1).toString())}',
                    style: GoogleFonts.getFont(
                      'Noto Naskh Arabic',
                      textStyle: TextStyle(
                        color: isSelected ? Colors.white : text,
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDhikrTextCard(
    Dhikr dhikr,
    Color bg,
    Color outline,
    Color text,
    Color gold,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: outline, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Stack(
        children: [
          // Text content
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                dhikr.text,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  textStyle: TextStyle(
                    color: text,
                    fontSize: 20.sp,
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          
          // Favorite Star Button in top-right corner
          Positioned(
            left: 0,
            top: 0,
            child: Obx(() {
              final isFav = controller.isDhikrFavorite(dhikr.text);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  color: gold,
                  size: 24.r,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  controller.toggleFavoriteDhikr(dhikr.text);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildConcentricCounterButton(
    Dhikr dhikr,
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
    bool isDark,
  ) {
    final scale = 1.0.obs;
    final isDone = dhikr.isFinished.value;

    return GestureDetector(
      onTapDown: (_) {
        if (!isDone) {
          scale.value = 0.92;
          HapticFeedback.mediumImpact();
          controller.incrementDhikr(dhikr);
        }
      },
      onTapUp: (_) => scale.value = 1.0,
      onTapCancel: () => scale.value = 1.0,
      child: Obx(() {
        final countStr = _toArabicNumbers(dhikr.currentCount.value.toString());
        final targetStr = _toArabicNumbers(dhikr.targetCount.toString());

        return AnimatedScale(
          scale: scale.value,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 170.w,
            height: 170.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardBg,
              border: Border.all(
                color: isDone ? const Color(0xFF064E3B) : gold,
                width: 4.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDone
                      ? const Color(0xFF064E3B).withValues(alpha: 0.15)
                      : gold.withValues(alpha: 0.15),
                  blurRadius: 20.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 156.w,
                  height: 156.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.08),
                      width: 2.w,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDone ? Icons.check_circle : Icons.fingerprint,
                      color: isDone
                          ? const Color(0xFF064E3B)
                          : primary.withValues(alpha: 0.4),
                      size: 22.r,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      countStr,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: text,
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: 40.w,
                      height: 1.5.h,
                      color: gold.withValues(alpha: 0.4),
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                    ),
                    Text(
                      targetStr,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: text.withValues(alpha: 0.4),
                          fontSize: 12.sp,
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

  Widget _buildBottomProgressAndControls(
    List<Dhikr> azkarList,
    int currentIndex,
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
    bool isDark,
  ) {
    final int completedSteps = azkarList.where((d) => d.isFinished.value).length;
    final progress = (completedSteps / azkarList.length.toDouble()).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: outline, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.stars, color: gold, size: 18.r),
                  SizedBox(width: 8.w),
                  Text(
                    'تقدم الأذكار اليوم:',
                    style: GoogleFonts.getFont(
                      'Noto Naskh Arabic',
                      textStyle: TextStyle(
                        color: text,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '${_toArabicNumbers(completedSteps.toString())} / ${_toArabicNumbers(azkarList.length.toString())} خطوات',
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    color: gold,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.h,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(gold),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: primary, size: 20.r),
                onPressed: currentIndex > 0
                    ? () {
                        HapticFeedback.selectionClick();
                        controller.previousDhikr();
                      }
                    : null,
              ),
              TextApp(
                text: 'الخطوة ${_toArabicNumbers((currentIndex + 1).toString())}',
                color: text.withValues(alpha: 0.6),
                fontSize: 12.sp,
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios_rounded, color: primary, size: 20.r),
                onPressed: currentIndex < azkarList.length - 1
                    ? () {
                        HapticFeedback.selectionClick();
                        controller.nextDhikr();
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(Color bg, Color primary, Color gold) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: gold, size: 40.r),
            SizedBox(height: 12.h),
            Text(
              'تقبل الله طاعتكم',
              style: GoogleFonts.getFont(
                'Noto Naskh Arabic',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'تم إتمام جميع خطوات الأذكار لهذا القسم بنجاح',
              style: GoogleFonts.getFont(
                'Noto Naskh Arabic',
                textStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 12.h),
              ),
              child: Text(
                'العودة للرئيسية',
                style: GoogleFonts.getFont(
                  'Noto Naskh Arabic',
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'إعادة ضبط الأذكار',
      titleStyle: GoogleFonts.getFont(
        'Noto Naskh Arabic',
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      middleText: 'هل تريد إعادة تصفير عدادات الأذكار للقسم الحالي للبدء من جديد؟',
      middleTextStyle: GoogleFonts.getFont('Noto Naskh Arabic'),
      backgroundColor: Colors.white,
      radius: 16.r,
      textConfirm: 'نعم، إعادة ضبط',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF003527),
      textCancel: 'إلغاء',
      cancelTextColor: const Color(0xFF003527),
      onConfirm: () {
        controller.resetAll();
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

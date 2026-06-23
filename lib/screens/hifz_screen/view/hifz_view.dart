import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/hifz_controller.dart';

class HifzView extends GetView<HifzController> {
  const HifzView({super.key});

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
    final Color errorColor = const Color(0xFFBA1A1A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMarginMobile.w,
            vertical: 16.h,
          ),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                TextApp(
                  text: controller.hasResult.value
                      ? 'تقرير نتائج التسميع المطور'
                      : "التسميع الذكي",
                  color: primaryColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 24.h),

                if (!controller.hasResult.value) ...[
                  _buildSurahSelector(
                    primaryColor,
                    goldColor,
                    textColor,
                    isDark,
                  ),
                  SizedBox(height: 12.h),
                  _buildVerseRangeSelector(
                    primaryColor,
                    goldColor,
                    textColor,
                    isDark,
                  ),
                  SizedBox(height: 20.h),
                  _buildRecordingSection(
                    primaryColor,
                    goldColor,
                    textColor,
                    isDark,
                  ),
                ] else ...[
                  // 1. Score section circular progress indicator
                  _buildScoreCircle(
                    controller.score.value / 100,
                    primaryColor,
                    goldColor,
                    textColor,
                    isDark,
                  ),
                  SizedBox(height: 32.h),

                  // 1.5. Text transcription card (what the app heard)
                  _buildTranscriptionCard(
                    controller.transcription.value,
                    cardBackgroundColor,
                    outlineColor,
                    primaryColor,
                    goldColor,
                    textColor,
                    isDark,
                  ),
                  if (controller.transcription.value.isNotEmpty)
                    SizedBox(height: 20.h),

                  // 2. Transcription evaluation card
                  _buildEvaluationCard(
                    controller.surahName.value,
                    controller.ayahRange.value,
                    controller.evaluationWords,
                    cardBackgroundColor,
                    outlineColor,
                    primaryColor,
                    goldColor,
                    textColor,
                    errorColor,
                    isDark,
                  ),
                  SizedBox(height: 20.h),

                  // 3. Tips list section
                  _buildTipsCard(controller.tips, goldColor, textColor, isDark),
                  SizedBox(height: 28.h),

                  // 4. Action buttons
                  _buildActionButtons(goldColor, primaryColor),
                ],

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahSelector(
    Color primaryColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF052219) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: goldColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.list, color: goldColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "اختر السورة للحفظ:",
              style: GoogleFonts.notoKufiArabic(
                fontSize: 14.sp,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: Obx(
              () => DropdownButton<String>(
                value:
                    controller.availableSurahs.contains(
                      controller.surahName.value,
                    )
                    ? controller.surahName.value
                    : controller.availableSurahs.first,
                dropdownColor: isDark ? const Color(0xFF052219) : Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: goldColor),
                items: controller.availableSurahs.map((String surah) {
                  return DropdownMenuItem<String>(
                    value: surah,
                    child: Text(
                      surah,
                      style: GoogleFonts.amiri(
                        fontSize: 16.sp,
                        color: textColor,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectSurah(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection(
    Color primaryColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF052219) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: AppTheme.shadowMd,
          ),
          child: Column(
            children: [
              Text(
                controller.surahName.value,
                style: GoogleFonts.amiri(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                "الآيات: ${controller.ayahRange.value}",
                style: GoogleFonts.notoKufiArabic(
                  fontSize: 14.sp,
                  color: textColor.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 40.h),
              Obx(
                () => GestureDetector(
                  onTap: () {
                    if (controller.isRecording.value) {
                      controller.stopRecording();
                    } else {
                      controller.startRecording();
                    }
                  },
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: controller.isRecording.value
                          ? Colors.red.withValues(alpha: 0.1)
                          : goldColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: controller.isRecording.value
                            ? Colors.red
                            : goldColor,
                        width: 4.w,
                      ),
                    ),
                    child: Icon(
                      controller.isRecording.value ? Icons.stop : Icons.mic,
                      size: 48.r,
                      color: controller.isRecording.value
                          ? Colors.red
                          : goldColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Obx(
                () => Text(
                  controller.isRecording.value
                      ? "جارِ الاستماع... اضغط للإيقاف"
                      : "اضغط على الميكروفون وابدأ التسميع",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 14.sp,
                    color: textColor,
                  ),
                ),
              ),
              Obx(() {
                if (!controller.isRecording.value || controller.liveText.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: EdgeInsets.only(top: 24.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF00150F) : const Color(0xFFF7F5F0),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.25),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.record_voice_over, color: Colors.red, size: 16),
                          SizedBox(width: 6.w),
                          TextApp(
                            text: 'يتلو القارئ الآن:',
                            color: goldColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        controller.liveText.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          textStyle: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        if (controller.isLoading.value)
          Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: const CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildScoreCircle(
    double scoreProgress,
    Color primaryColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      width: 170.w,
      height: 170.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF052219) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppTheme.shadowMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 154.w,
            height: 154.w,
            child: CircularProgressIndicator(
              value: scoreProgress,
              strokeWidth: 8.w,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(goldColor),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(scoreProgress * 100).toInt()}%',
                style: GoogleFonts.notoSerif(
                  textStyle: TextStyle(
                    color: primaryColor,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextApp(
                text: 'درجة الدقة العامة',
                color: textColor.withValues(alpha: 0.6),
                fontSize: 12.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(
    String surah,
    String range,
    List<EvaluationWord> words,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
    Color errorColor,
    bool isDark,
  ) {
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF003527)
                      : const Color(0xFFBCEDD8),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TextApp(
                  text: '$surah : $range',
                  color: isDark
                      ? const Color(0xFFBCEDD8)
                      : const Color(0xFF002117),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.menu_book, color: primaryColor, size: 20.r),
            ],
          ),
          SizedBox(height: 20.h),
          Directionality(
            textDirection: TextDirection.rtl,
            child: RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                style: GoogleFonts.amiri(
                  textStyle: TextStyle(
                    color: textColor,
                    fontSize: 22.sp,
                    height: 2.0,
                  ),
                ),
                children: words.map((word) {
                  final String wordText = word.text;
                  final String displayText = wordText.endsWith(' ') ? wordText : '$wordText ';
                  
                  if (word.isCorrect) {
                    return TextSpan(text: displayText);
                  } else {
                    return WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: errorColor.withValues(alpha: 0.1),
                          border: Border(
                            bottom: BorderSide(color: errorColor, width: 2.w),
                          ),
                        ),
                        child: Text(
                          wordText.trim(),
                          style: GoogleFonts.amiri(
                            textStyle: TextStyle(
                              color: errorColor,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(
    List<String> tips,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: goldColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: goldColor.withValues(alpha: 0.2), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: goldColor, size: 22.r),
              SizedBox(width: 8.w),
              TextApp(
                text: 'كيف يمكنك التحسن',
                color: goldColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...tips.map(
            (tip) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _buildTipItem(tip, goldColor, textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, Color bulletColor, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 8.h, right: 4.w, left: 10.w),
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(color: bulletColor, shape: BoxShape.circle),
        ),
        Expanded(
          child: TextApp(
            text: tip,
            color: textColor.withValues(alpha: 0.8),
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color goldColor, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.reset();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: goldColor,
                side: BorderSide(color: goldColor, width: 1.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              icon: Icon(Icons.refresh, size: 18.r),
              label: TextApp(
                text: 'حاول مرة أخرى',
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.nextAyahRange();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextApp(
                    text: 'الآية التالية',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_back, size: 16.r), // points left in RTL
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerseRangeSelector(
    Color primaryColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF052219) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: goldColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.unfold_more_rounded, color: goldColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start Ayah Dropdown
                Row(
                  children: [
                    Text(
                      "من الآية: ",
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 13.sp,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: controller.startAyah.value,
                        dropdownColor: isDark
                            ? const Color(0xFF052219)
                            : Colors.white,
                        icon: Icon(Icons.arrow_drop_down, color: goldColor),
                        items:
                            List.generate(
                              controller.totalVerses.value,
                              (i) => i + 1,
                            ).map((int val) {
                              return DropdownMenuItem<int>(
                                value: val,
                                child: Text(
                                  _toArabicNumbers(val.toString()),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: textColor,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            controller.startAyah.value = newValue;
                            if (controller.endAyah.value < newValue) {
                              controller.endAyah.value = newValue;
                            }
                            controller.updateRange();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                // Vertical Divider
                Container(
                  width: 1.w,
                  height: 20.h,
                  color: goldColor.withValues(alpha: 0.3),
                ),
                // End Ayah Dropdown
                Row(
                  children: [
                    Text(
                      "إلى الآية: ",
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 13.sp,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: controller.endAyah.value,
                        dropdownColor: isDark
                            ? const Color(0xFF052219)
                            : Colors.white,
                        icon: Icon(Icons.arrow_drop_down, color: goldColor),
                        items:
                            List.generate(
                              controller.totalVerses.value -
                                  controller.startAyah.value +
                                  1,
                              (i) => controller.startAyah.value + i,
                            ).map((int val) {
                              return DropdownMenuItem<int>(
                                value: val,
                                child: Text(
                                  _toArabicNumbers(val.toString()),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: textColor,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            controller.endAyah.value = newValue;
                            controller.updateRange();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
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

  Widget _buildTranscriptionCard(
    String text,
    Color cardBg,
    Color outlineColor,
    Color primaryColor,
    Color goldColor,
    Color textColor,
    bool isDark,
  ) {
    if (text.isEmpty) return const SizedBox.shrink();
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
            children: [
              Icon(Icons.mic, color: goldColor, size: 20.r),
              SizedBox(width: 8.w),
              TextApp(
                text: 'النص المسموع (تسميعك المكتوب)',
                color: goldColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                textStyle: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : textColor.withValues(alpha: 0.85),
                  fontSize: 20.sp,
                  height: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

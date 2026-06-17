import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/mushaf_reader_controller.dart';

class MushafReaderView extends GetView<MushafReaderController> {
  const MushafReaderView({super.key});

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
        title: TextApp(
          text: controller.surahName,
          color: primaryColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardBackgroundColor,
              border: Border.all(color: outlineColor, width: 1.w),
            ),
            child: IconButton(
              icon: Icon(
                Icons.text_fields_rounded,
                color: primaryColor,
                size: 18.r,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                _showTypographyBottomSheet(
                  context,
                  cardBackgroundColor,
                  outlineColor,
                  textColor,
                  primaryColor,
                  goldColor,
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitThreeBounce(color: goldColor, size: 32.w),
                  SizedBox(height: 16.h),
                  TextApp(
                    text: 'جاري تحميل آيات السورة الكريمة...',
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 13.sp,
                  ),
                ],
              ),
            );
          }

          if (controller.hasError.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.red.withValues(alpha: 0.6),
                      size: 48.r,
                    ),
                    SizedBox(height: 16.h),
                    TextApp(
                      text: 'لا يوجد اتصال بالانترنت',
                      textAlign: TextAlign.center,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () => controller.retryFetch(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: TextApp(text: 'إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              // Scrollable Continuous Verses View
              SingleChildScrollView(
                controller: controller.scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: AppTheme.spacingMarginMobile.w,
                  right: AppTheme.spacingMarginMobile.w,
                  top: 16.h,
                  bottom: 250.h, // Leave space for the dashboard card
                ),
                child: Column(
                  children: [
                    // Surah Header Card
                    _buildSurahHeader(
                      context,
                      primaryColor,
                      goldColor,
                      cardBackgroundColor,
                      outlineColor,
                      textColor,
                    ),
                    SizedBox(height: 20.h),

                    // Basmalah Calligraphy
                    if (controller.surahId != 1 && controller.surahId != 9) ...[
                      Center(
                        child: Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            textStyle: TextStyle(
                              color: primaryColor,
                              fontSize: (controller.arFontSize.value + 4).sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Continuous Paragraph
                    Obx(() {
                      final List<InlineSpan> spans = [];
                      for (int i = 0; i < controller.arVerses.length; i++) {
                        final int index = i;
                        final bool isSelected =
                            controller.selectedAyahIndex.value == index;
                        final bool isPlaying =
                            controller.playingAyahIndex.value == index;

                        final text = controller.getCleanArText(index);

                        spans.add(
                          TextSpan(
                            text: text,
                            style: TextStyle(
                              backgroundColor: isPlaying
                                  ? goldColor.withValues(alpha: 0.24)
                                  : (isSelected
                                        ? goldColor.withValues(alpha: 0.12)
                                        : Colors.transparent),
                              color: isPlaying
                                  ? goldColor
                                  : (isSelected ? primaryColor : textColor),
                              fontWeight: (isPlaying || isSelected)
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                HapticFeedback.lightImpact();
                                controller.selectedAyahIndex.value = index;
                              },
                          ),
                        );

                        // Add Ayah marker ﴿index+1﴾
                        final markerText =
                            ' ﴿${_toArabicNumbers((index + 1).toString())}﴾ ';
                        spans.add(
                          TextSpan(
                            text: markerText,
                            style: TextStyle(
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                HapticFeedback.lightImpact();
                                controller.selectedAyahIndex.value = index;
                              },
                          ),
                        );
                      }

                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: outlineColor, width: 1.w),
                          ),
                          child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              children: spans,
                              style: GoogleFonts.amiri(
                                textStyle: TextStyle(
                                  color: textColor,
                                  fontSize: controller.arFontSize.value.sp,
                                  height: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Bottom Verse Control Dashboard
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
                child: Obx(() {
                  final selectedIdx = controller.selectedAyahIndex.value;
                  if (selectedIdx < 0 ||
                      selectedIdx >= controller.arVerses.length) {
                    return const SizedBox.shrink();
                  }

                  final isBookmarked =
                      controller.isAyahFavorite(selectedIdx);
                  final isPlayingThis =
                      controller.playingAyahIndex.value == selectedIdx;
                  final String enTranslationText =
                      controller.enVerses.isNotEmpty &&
                          selectedIdx < controller.enVerses.length
                      ? (controller.enVerses[selectedIdx]['text'] ?? '')
                      : '';

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: goldColor.withValues(alpha: 0.4),
                        width: 1.2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 18.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header line (Selected Verse Info & Bookmark & Play Actions)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    color: goldColor,
                                    size: 16.r,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                TextApp(
                                  text:
                                      '${controller.surahName} • الآية: ${_toArabicNumbers((selectedIdx + 1).toString())}',
                                  color: primaryColor,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: goldColor,
                                size: 22.r,
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                controller.toggleBookmark(selectedIdx);
                              },
                            ),
                          ],
                        ),

                        const Divider(height: 12, thickness: 0.5),

                        // Translation Display Area
                        Container(
                          constraints: BoxConstraints(maxHeight: 70.h),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                enTranslationText,
                                textAlign: TextAlign.left,
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    color: textColor.withValues(alpha: 0.85),
                                    fontSize: controller.enFontSize.value.sp,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Media controls row (Skip Prev - Play/Pause - Skip Next)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Left navigation button
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left_rounded,
                                color: primaryColor,
                                size: 32.r,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                controller.selectNextAyah();
                              },
                            ),
                            SizedBox(width: 20.w),

                            // Play/Pause Button
                            Obx(() {
                              final bool isLoadingAudio =
                                  controller.isAudioLoading.value &&
                                  isPlayingThis;
                              if (isLoadingAudio) {
                                return SizedBox(
                                  width: 46.w,
                                  height: 46.w,
                                  child: Padding(
                                    padding: EdgeInsets.all(10.w),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        goldColor,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final bool isPlayingThisAyah =
                                  controller.isPlaying.value && isPlayingThis;
                              return Container(
                                width: 46.w,
                                height: 46.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: goldColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: goldColor.withValues(alpha: 0.4),
                                      blurRadius: 8.r,
                                      offset: Offset(0, 3.h),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isPlayingThisAyah
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28.r,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    if (isPlayingThis) {
                                      controller.togglePlayPause();
                                    } else {
                                      controller.playAyah(selectedIdx);
                                    }
                                  },
                                ),
                              );
                            }),
                            SizedBox(width: 20.w),

                            // Right navigation button
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                color: primaryColor,
                                size: 32.r,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                controller.selectPreviousAyah();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showTypographyBottomSheet(
    BuildContext context,
    Color cardBg,
    Color outlineColor,
    Color textColor,
    Color primaryColor,
    Color goldColor,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Obx(() {
          return Column(
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
              SizedBox(height: 20.h),
              TextApp(
                text: 'تخصيص حجم الخطوط',
                color: primaryColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 20.h),

              // Arabic Font Size
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextApp(
                    text: 'حجم الخط العربي:',
                    color: textColor,
                    fontSize: 13.sp,
                  ),
                  Text(
                    controller.arFontSize.value.toStringAsFixed(0),
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        color: goldColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: controller.arFontSize.value,
                min: 18.0,
                max: 36.0,
                activeColor: goldColor,
                inactiveColor: goldColor.withValues(alpha: 0.15),
                onChanged: (size) => controller.updateArFontSize(size),
              ),
              SizedBox(height: 16.h),

              // English Font Size (only relevant if translation is rendered)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextApp(
                    text: 'حجم خط الترجمة:',
                    color: textColor,
                    fontSize: 13.sp,
                  ),

                  Text(
                    controller.enFontSize.value.toStringAsFixed(0),
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        color: goldColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: controller.enFontSize.value,
                min: 12.0,
                max: 24.0,
                activeColor: goldColor,
                inactiveColor: goldColor.withValues(alpha: 0.15),
                onChanged: (size) => controller.updateEnFontSize(size),
              ),
              SizedBox(height: 16.h),
            ],
          );
        }),
      ),
      isScrollControlled: true,
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

  Widget _buildSurahHeader(
    BuildContext context,
    Color primaryColor,
    Color goldColor,
    Color cardBg,
    Color outlineColor,
    Color textColor,
  ) {
    final int totalVerses = controller.arVerses.length;

    final bool isMedinan = const {
      2,
      3,
      4,
      5,
      8,
      9,
      13,
      22,
      24,
      33,
      47,
      48,
      49,
      57,
      58,
      59,
      60,
      61,
      62,
      63,
      64,
      65,
      66,
      76,
      98,
      99,
      110,
    }.contains(controller.surahId);

    final String typeText = isMedinan ? 'مدنية' : 'مكية';
    final String versesText = '${_toArabicNumbers(totalVerses.toString())} آيات';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.4),
          width: 1.5.w,
        ),
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.12),
            primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Elegant Surah Name
          TextApp(
            text: controller.surahName,
            textAlign: TextAlign.center,
            color: goldColor,
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 8.h),

          // Divider decoration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40.w,
                height: 1.h,
                color: goldColor.withValues(alpha: 0.5),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Icon(Icons.star_rounded, color: goldColor, size: 12.r),
              ),
              Container(
                width: 40.w,
                height: 1.h,
                color: goldColor.withValues(alpha: 0.5),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Details: Revelation & Verses
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextApp(
                text: typeText,
                color: textColor.withValues(alpha: 0.8),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goldColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
              TextApp(
                text: versesText,
                color: textColor.withValues(alpha: 0.8),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

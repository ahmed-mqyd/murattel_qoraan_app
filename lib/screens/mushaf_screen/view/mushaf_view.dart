import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import 'package:murattel_qoraan_app/core/routes/app_routes.dart';
import '../controller/mushaf_controller.dart';

class MushafView extends GetView<MushafController> {
  const MushafView({super.key});

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
        child: Column(
          children: [
            // Header Search & Filters
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMarginMobile.w,
                vertical: 16.h,
              ),
              child: Column(
                children: [
                  TextApp(
                    text: 'فهرس السور',
                    color: primaryColor,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 16.h),
                  // Search Bar
                  Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF052219)
                          : const Color(0xFFF3F3F6),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: outlineColor, width: 1.w),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      style: GoogleFonts.getFont(
                        'Noto Naskh Arabic',
                        textStyle: TextStyle(color: textColor, fontSize: 14.sp),
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن سورة...',
                        hintStyle: GoogleFonts.getFont(
                          'Noto Naskh Arabic',
                          textStyle: TextStyle(
                            color: textColor.withValues(alpha: 0.5),
                            fontSize: 14.sp,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: textColor.withValues(alpha: 0.5),
                          size: 20.r,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Filters Row
                  Obx(() {
                    final activeMode = controller.filterMode.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFilterButton(
                          'السور',
                          activeMode == MushafFilterMode.surah,
                          goldColor,
                          isDark,
                          () => controller.filterMode.value =
                              MushafFilterMode.surah,
                        ),
                        SizedBox(width: 8.w),
                        _buildFilterButton(
                          'حسب الجزء',
                          activeMode == MushafFilterMode.juz,
                          goldColor,
                          isDark,
                          () => controller.filterMode.value =
                              MushafFilterMode.juz,
                        ),
                        SizedBox(width: 8.w),
                        _buildFilterButton(
                          'حسب الصفحة',
                          activeMode == MushafFilterMode.page,
                          goldColor,
                          isDark,
                          () => controller.filterMode.value =
                              MushafFilterMode.page,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // Index Display based on Filter Mode (Reactive using Obx)
            Expanded(
              child: Obx(() {
                final activeMode = controller.filterMode.value;
                if (activeMode == MushafFilterMode.surah) {
                  return _buildSurahIndex(
                    context,
                    isDark,
                    textColor,
                    primaryColor,
                    goldColor,
                    outlineColor,
                    cardBackgroundColor,
                  );
                } else if (activeMode == MushafFilterMode.juz) {
                  return _buildJuzIndex(
                    context,
                    isDark,
                    textColor,
                    primaryColor,
                    goldColor,
                    outlineColor,
                    cardBackgroundColor,
                  );
                } else {
                  return _buildPageIndex(
                    context,
                    isDark,
                    textColor,
                    primaryColor,
                    goldColor,
                    outlineColor,
                    cardBackgroundColor,
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    bool isActive,
    Color goldColor,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? goldColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: goldColor.withValues(alpha: 0.4),
            width: 1.w,
          ),
        ),
        child: TextApp(
          text: label,
          color: isActive ? Colors.white : goldColor,
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSurahIndex(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color primaryColor,
    Color goldColor,
    Color outlineColor,
    Color cardBackgroundColor,
  ) {
    final filteredSurahs = controller.filteredSurahs;
    if (filteredSurahs.isEmpty) {
      return Center(
        child: TextApp(
          text: 'لا توجد نتائج بحث تطابق استعلامك',
          color: textColor.withValues(alpha: 0.6),
          fontSize: 14.sp,
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMarginMobile.w),
      itemCount: filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = filteredSurahs[index];
        final double progress = surah['progress'] as double;
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: outlineColor, width: 1.w),
            boxShadow: AppTheme.shadowSm,
          ),
          child: ListTile(
            onTap: () {
              HapticFeedback.selectionClick();
              Get.toNamed(
                Routes.mushafReader,
                arguments: {
                  'id': surah['id'],
                  'name': surah['name'],
                  'initialAyahIndex': -1,
                },
              );
            },
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            leading: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: goldColor.withValues(alpha: 0.08),
              ),
              child: Center(
                child: TextApp(
                  text: _toArabicNumber(surah['id']),
                  color: primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: surah['name'] as String,
                  color: primaryColor,
                  fontSize: 18.sp,
                ),
                if (progress > 0) ...[
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: SizedBox(
                      width: 120.w,
                      height: 4.h,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: SizedBox(
              width: 80.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: TextApp(
                      text: 'صفحة ${_toArabicNumber(surah['page'])}',

                      color: goldColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextApp(
                    text: '${_toArabicNumber(surah['verses'])} آية',
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 10.sp,
                  ),
                  TextApp(
                    text: (surah['type'] as String) == 'مكية'
                        ? 'مكية'
                        : 'مدنية',

                    color: textColor.withValues(alpha: 0.5),
                    fontSize: 10.sp,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJuzIndex(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color primaryColor,
    Color goldColor,
    Color outlineColor,
    Color cardBackgroundColor,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMarginMobile.w),
      itemCount: controller.juzs.length,
      itemBuilder: (context, index) {
        final juz = controller.juzs[index];
        final juzNum = juz['juz'] as int;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: outlineColor, width: 1.w),
            boxShadow: AppTheme.shadowSm,
          ),
          child: ListTile(
            onTap: () {
              HapticFeedback.selectionClick();
              Get.toNamed(
                Routes.mushafReader,
                arguments: {
                  'id': juz['surahId'],
                  'name': juz['surahName'],
                  'initialAyahIndex': juz['ayahIndex'],
                },
              );
            },
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            leading: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: goldColor.withValues(alpha: 0.08),
              ),
              child: Center(
                child: TextApp(
                  text: _toArabicNumber(juzNum),

                  color: primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: TextApp(
              text: 'الجزء ${_toArabicNumber(juzNum)}',
              color: primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: TextApp(
                text: 'يبدأ من سورة ${juz['surahName']}',
                color: textColor.withValues(alpha: 0.6),
                fontSize: 12.sp,
              ),
            ),
            trailing: TextApp(
              text: 'صفحة ${_toArabicNumber(juz['page'])}',
              color: goldColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndex(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color primaryColor,
    Color goldColor,
    Color outlineColor,
    Color cardBackgroundColor,
  ) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMarginMobile.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.0,
      ),
      itemCount: 604,
      itemBuilder: (context, index) {
        final pageNum = index + 1;
        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            final surahMap = controller.getSurahForPage(pageNum);
            Get.toNamed(
              Routes.mushafReader,
              arguments: {
                'id': surahMap['id'],
                'name': surahMap['name'],
                'initialAyahIndex': surahMap['initialAyahIndex'],
              },
            );
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: outlineColor, width: 1.w),
            ),
            child: Center(
              child: Text(
                _toArabicNumber(pageNum),
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    color: primaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _toArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    var temp = number.toString();
    for (var i = 0; i < english.length; i++) {
      temp = temp.replaceAll(english[i], arabic[i]);
    }
    return temp;
  }
}

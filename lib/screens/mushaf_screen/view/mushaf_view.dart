import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
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
                      style: TextApp.style(color: textColor, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن سورة...',
                        hintStyle: TextApp.style(
                          color: textColor.withValues(alpha: 0.5),
                          fontSize: 14.sp,
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
                ],
              ),
            ),

            // Index Display (Reactive using Obx to update on search query changes)
            Expanded(
              child: Obx(() {
                return _buildSurahIndex(
                  context,
                  isDark,
                  textColor,
                  primaryColor,
                  goldColor,
                  outlineColor,
                  cardBackgroundColor,
                );
              }),
            ),
          ],
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

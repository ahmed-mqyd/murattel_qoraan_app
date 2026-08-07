import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/data/azkar_library_data.dart';
import 'package:murattel_qoraan_app/core/routes/app_routes.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';

/// مكتبة الأذكار والأدعية — شبكة أقسام تفتح مشغّل الأذكار على القسم المختار.
/// شاشة عرض فقط تقرأ من [AzkarLibrary] مباشرة، فلا تحتاج Controller.
class AzkarLibraryView extends StatelessWidget {
  const AzkarLibraryView({super.key});

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
    const Color goldColor = Color(0xFFC5A059);

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
          text: 'مكتبة الأذكار والأدعية',
          color: primaryColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMarginMobile.w,
            vertical: 12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'الأذكار اليومية',
                Icons.today_outlined,
                primaryColor,
                goldColor,
              ),
              _buildCategoryGrid(
                AzkarLibrary.byGroup(AzkarGroup.daily),
                cardBackgroundColor,
                outlineColor,
                textColor,
                primaryColor,
                goldColor,
              ),
              SizedBox(height: 20.h),
              _buildSectionHeader(
                'المكتبة',
                Icons.local_library_outlined,
                primaryColor,
                goldColor,
              ),
              _buildCategoryGrid(
                AzkarLibrary.byGroup(AzkarGroup.library),
                cardBackgroundColor,
                outlineColor,
                textColor,
                primaryColor,
                goldColor,
              ),
              SizedBox(height: 20.h),
              _buildSectionHeader(
                'حصن المسلم',
                Icons.shield_outlined,
                primaryColor,
                goldColor,
              ),
              _buildCategoryGrid(
                AzkarLibrary.byGroup(AzkarGroup.hisn),
                cardBackgroundColor,
                outlineColor,
                textColor,
                primaryColor,
                goldColor,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color primaryColor,
    Color goldColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, right: 4.w),
      child: Row(
        children: [
          Icon(icon, color: goldColor, size: 20.r),
          SizedBox(width: 8.w),
          TextApp(
            text: title,
            color: primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(
    List<AzkarCategoryData> categories,
    Color cardBg,
    Color outlineColor,
    Color textColor,
    Color primaryColor,
    Color goldColor,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        // هامش ارتفاع إضافي للعناوين الطويلة التي تلتف لسطرين (مثل عناوين حصن المسلم)
        childAspectRatio: 1.75,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Get.toNamed(Routes.azkar, arguments: category.key);
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: outlineColor, width: 1.w),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, color: goldColor, size: 20.r),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextApp(
                        text: category.title,
                        color: textColor,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      TextApp(
                        text:
                            '${_toArabicNumbers(category.items.length.toString())} ${category.items.length > 2 ? 'أذكار' : 'ذكر'}',
                        color: textColor.withValues(alpha: 0.5),
                        fontSize: 10.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
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

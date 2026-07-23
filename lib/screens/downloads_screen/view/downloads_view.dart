import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/models/reciter.dart';
import 'package:murattel_qoraan_app/core/models/surah_meta.dart';
import 'package:murattel_qoraan_app/core/services/audio_download_service.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/downloads_controller.dart';

class DownloadsView extends GetView<DownloadsController> {
  const DownloadsView({super.key});

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
    const Color successColor = Color(0xFF10B981);
    const Color errorColor = Color(0xFFBA1A1A);

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
          text: 'تحميل التلاوات',
          color: primaryColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMarginMobile.w,
                vertical: 12.h,
              ),
              child: _buildHeaderCard(
                context,
                cardBackgroundColor,
                outlineColor,
                textColor,
                primaryColor,
                goldColor,
                isDark,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingStates.value &&
                    controller.surahStates.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: goldColor),
                  );
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMarginMobile.w,
                    vertical: 4.h,
                  ),
                  itemCount: SurahMetas.all.length,
                  itemBuilder: (context, index) {
                    final surah = SurahMetas.all[index];
                    return _buildSurahTile(
                      surah,
                      cardBackgroundColor,
                      outlineColor,
                      textColor,
                      primaryColor,
                      goldColor,
                      successColor,
                      errorColor,
                      isDark,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
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
        final reciter = controller.reciter.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.record_voice_over_rounded,
                    color: goldColor,
                    size: 22.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextApp(
                        text: 'تلاوات القارئ',
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 11.sp,
                      ),
                      SizedBox(height: 2.h),
                      TextApp(
                        text: reciter.arabicName,
                        color: textColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _showReciterPicker(context, isDark),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                  ),
                  child: TextApp(
                    text: 'تغيير',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(
                  Icons.download_done_rounded,
                  'المحمّلة: ${controller.toArabicNumbers(controller.downloadedCount.toString())} سورة',
                  textColor,
                  goldColor,
                ),
                _buildStatChip(
                  Icons.sd_storage_rounded,
                  'المساحة: ${controller.formatBytes(controller.usedBytes.value)}',
                  textColor,
                  goldColor,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String label,
    Color textColor,
    Color goldColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: goldColor, size: 16.r),
        SizedBox(width: 6.w),
        TextApp(
          text: label,
          color: textColor.withValues(alpha: 0.75),
          fontSize: 12.sp,
        ),
      ],
    );
  }

  Widget _buildSurahTile(
    SurahMeta surah,
    Color cardBg,
    Color outlineColor,
    Color textColor,
    Color primaryColor,
    Color goldColor,
    Color successColor,
    Color errorColor,
    bool isDark,
  ) {
    return Obx(() {
      final state =
          controller.surahStates[surah.id] ?? SurahDownloadState.notDownloaded;
      final bool isThisDownloading =
          controller.downloadingSurahId.value == surah.id;

      return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isThisDownloading
                ? goldColor.withValues(alpha: 0.6)
                : outlineColor,
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            // رقم السورة
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  controller.toArabicNumbers(surah.id.toString()),
                  style: GoogleFonts.getFont(
                    TextApp.arabicFontFamily,
                    textStyle: TextStyle(
                      color: primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextApp(
                    text: 'سورة ${surah.arabicName}',
                    color: textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 2.h),
                  TextApp(
                    text: _subtitleFor(state, surah, isThisDownloading),
                    color: state == SurahDownloadState.partial
                        ? goldColor
                        : textColor.withValues(alpha: 0.5),
                    fontSize: 11.sp,
                  ),
                ],
              ),
            ),
            _buildTrailing(
              surah,
              state,
              isThisDownloading,
              goldColor,
              successColor,
              errorColor,
              textColor,
            ),
          ],
        ),
      );
    });
  }

  String _subtitleFor(
    SurahDownloadState state,
    SurahMeta surah,
    bool isThisDownloading,
  ) {
    if (isThisDownloading) {
      final pct = (controller.downloadProgress.value * 100).toInt();
      return 'جارِ التحميل... ${controller.toArabicNumbers('$pct%')}';
    }
    switch (state) {
      case SurahDownloadState.downloaded:
        return 'محمّلة — متاحة دون اتصال';
      case SurahDownloadState.partial:
        return 'تحميل غير مكتمل — اضغط للإكمال';
      case SurahDownloadState.notDownloaded:
        return '${controller.toArabicNumbers(surah.verseCount.toString())} آية';
    }
  }

  Widget _buildTrailing(
    SurahMeta surah,
    SurahDownloadState state,
    bool isThisDownloading,
    Color goldColor,
    Color successColor,
    Color errorColor,
    Color textColor,
  ) {
    if (isThisDownloading) {
      // مؤشر تقدم + إلغاء بالضغط
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.cancelDownload();
        },
        child: SizedBox(
          width: 36.w,
          height: 36.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: controller.downloadProgress.value > 0
                    ? controller.downloadProgress.value
                    : null,
                strokeWidth: 3.w,
                color: goldColor,
                backgroundColor: goldColor.withValues(alpha: 0.15),
              ),
              Icon(Icons.close_rounded, color: textColor, size: 14.r),
            ],
          ),
        ),
      );
    }

    switch (state) {
      case SurahDownloadState.downloaded:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: successColor, size: 22.r),
            SizedBox(width: 4.w),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: errorColor.withValues(alpha: 0.8),
                size: 20.r,
              ),
              onPressed: () => _confirmDelete(surah),
            ),
          ],
        );
      case SurahDownloadState.partial:
      case SurahDownloadState.notDownloaded:
        return IconButton(
          icon: Icon(
            state == SurahDownloadState.partial
                ? Icons.downloading_rounded
                : Icons.download_rounded,
            color: goldColor,
            size: 24.r,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            controller.downloadSurah(surah.id);
          },
        );
    }
  }

  void _confirmDelete(SurahMeta surah) {
    Get.defaultDialog(
      title: 'حذف التلاوة',
      titleStyle: TextApp.style(fontWeight: FontWeight.bold, fontSize: 16.sp),
      middleText:
          'هل تريد حذف تلاوة سورة ${surah.arabicName} المحمّلة لهذا القارئ؟',
      middleTextStyle: TextApp.style(fontSize: 13.sp, height: 1.6),
      textConfirm: 'حذف',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFBA1A1A),
      onConfirm: () {
        Get.back();
        controller.deleteSurah(surah.id);
      },
    );
  }

  void _showReciterPicker(BuildContext context, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF052219) : Colors.white;
    final Color textColor = isDark
        ? const Color(0xFFE2E2E5)
        : const Color(0xFF1A1C1E);
    const Color goldColor = Color(0xFFC5A059);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        constraints: BoxConstraints(maxHeight: 0.7.sh),
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
              text: 'اختر القارئ لإدارة تحميلاته',
              color: textColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: Reciters.all.map((reciter) {
                    return Obx(
                      () => ListTile(
                        title: TextApp(
                          text: reciter.arabicName,
                          color: textColor,
                          fontSize: 14.sp,
                        ),
                        subtitle: reciter.isFullSurah
                            ? TextApp(
                                text: 'ملف واحد لكل سورة',
                                color: textColor.withValues(alpha: 0.5),
                                fontSize: 11.sp,
                              )
                            : null,
                        trailing: controller.reciter.value.key == reciter.key
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: goldColor,
                              )
                            : null,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Get.back();
                          controller.switchReciter(reciter);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

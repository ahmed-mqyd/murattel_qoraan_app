import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import '../../controller/mushaf_reader_controller.dart';

/// ثيمات بطاقات الآيات
class CardTheme {
  final String name;
  final String emoji;
  final List<Color> gradientColors;
  final Color textColor;
  final Color numberColor;
  final Color surahColor;

  const CardTheme({
    required this.name,
    required this.emoji,
    required this.gradientColors,
    required this.textColor,
    required this.numberColor,
    required this.surahColor,
  });
}

const List<CardTheme> ayahCardThemes = [
  CardTheme(
    name: 'الزمرد الملكي',
    emoji: '💎',
    gradientColors: [Color(0xFF003527), Color(0xFF064E3B), Color(0xFF065F46)],
    textColor: Colors.white,
    numberColor: Color(0xFFC5A059),
    surahColor: Color(0xFFC5A059),
  ),
  CardTheme(
    name: 'الليل الداكن',
    emoji: '🌙',
    gradientColors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
    textColor: Colors.white,
    numberColor: Color(0xFF94A3B8),
    surahColor: Color(0xFF38BDF8),
  ),
  CardTheme(
    name: 'الذهب الخالص',
    emoji: '✨',
    gradientColors: [Color(0xFF78350F), Color(0xFF92400E), Color(0xFF78350F)],
    textColor: Colors.white,
    numberColor: Color(0xFFFCD34D),
    surahColor: Color(0xFFFCD34D),
  ),
  CardTheme(
    name: 'البنفسجي الملكي',
    emoji: '👑',
    gradientColors: [Color(0xFF4C1D95), Color(0xFF6D28D9), Color(0xFF4C1D95)],
    textColor: Colors.white,
    numberColor: Color(0xFFDDD6FE),
    surahColor: Color(0xFFDDD6FE),
  ),
  CardTheme(
    name: 'الفجر الوردي',
    emoji: '🌸',
    gradientColors: [Color(0xFF831843), Color(0xFF9D174D), Color(0xFF831843)],
    textColor: Colors.white,
    numberColor: Color(0xFFFCE7F3),
    surahColor: Color(0xFFFCE7F3),
  ),
  CardTheme(
    name: 'الفيروزي الناعم',
    emoji: '🌊',
    gradientColors: [Color(0xFF134E4A), Color(0xFF0F766E), Color(0xFF134E4A)],
    textColor: Colors.white,
    numberColor: Color(0xFF99F6E4),
    surahColor: Color(0xFF99F6E4),
  ),
  CardTheme(
    name: 'السماء الليلية',
    emoji: '🌌',
    gradientColors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF1E1B4B)],
    textColor: Colors.white,
    numberColor: Color(0xFFC7D2FE),
    surahColor: Color(0xFFC7D2FE),
  ),
];

/// Bottom Sheet لإنشاء ومشاركة بطاقة آية
class AyahCardSheet extends StatefulWidget {
  final int ayahIndex;
  final MushafReaderController controller;

  const AyahCardSheet({
    super.key,
    required this.ayahIndex,
    required this.controller,
  });

  @override
  State<AyahCardSheet> createState() => _AyahCardSheetState();
}

class _AyahCardSheetState extends State<AyahCardSheet> {
  int _selectedTheme = 0;
  bool _isSharing = false;
  final GlobalKey _cardKey = GlobalKey();

  String get _ayahText => widget.controller.getCleanArText(widget.ayahIndex);
  String get _surahName => widget.controller.surahName;
  int get _ayahNumber => widget.ayahIndex + 1;

  @override
  Widget build(BuildContext context) {
    final theme = ayahCardThemes[_selectedTheme];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF052219)
              : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              TextApp(
                text: '🎨 بطاقة الآية',
                color: const Color(0xFF003527),
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 16.h),

              // Card Preview (RepaintBoundary for capture)
              RepaintBoundary(
                key: _cardKey,
                child: _buildAyahCard(theme),
              ),
              SizedBox(height: 20.h),

              // Theme selector
              TextApp(
                text: 'اختر ثيماً',
                color: const Color(0xFF003527),
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 70.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ayahCardThemes.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) {
                    final t = ayahCardThemes[i];
                    final isSelected = i == _selectedTheme;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTheme = i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: t.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFC5A059)
                                : Colors.transparent,
                            width: 2.5.w,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: const Color(0xFFC5A059).withValues(alpha: 0.4), blurRadius: 8.r)]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(t.emoji, style: TextStyle(fontSize: 20.sp)),
                            SizedBox(height: 2.h),
                            Text(
                              t.name.split(' ').first,
                              style: TextStyle(
                                color: t.textColor,
                                fontSize: 8.sp,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),

              // Share button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _captureAndShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A059),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  icon: _isSharing
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.share_rounded, size: 20.r),
                  label: TextApp(
                    text: _isSharing ? 'جارٍ التصدير...' : 'مشاركة البطاقة',
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAyahCard(CardTheme theme) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 200.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradientColors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          // زخرفة إسلامية خفيفة في الزوايا
          Positioned(
            top: -20,
            right: -20,
            child: Opacity(
              opacity: 0.07,
              child: Icon(Icons.star_rounded, size: 120.r, color: theme.numberColor),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Opacity(
              opacity: 0.07,
              child: Icon(Icons.star_rounded, size: 120.r, color: theme.numberColor),
            ),
          ),
          // المحتوى
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // شريط علوي: اسم التطبيق
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مُرَتِّل القرآن',
                      style: GoogleFonts.amiri(
                        textStyle: TextStyle(
                          color: theme.surahColor.withValues(alpha: 0.8),
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: theme.numberColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: theme.numberColor.withValues(alpha: 0.3), width: 0.5),
                      ),
                      child: Text(
                        '﴿ $_ayahNumber ﴾',
                        style: TextStyle(
                          color: theme.numberColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Divider ذهبي
                Container(height: 1, color: theme.numberColor.withValues(alpha: 0.25)),
                SizedBox(height: 20.h),

                // نص الآية
                Text(
                  _ayahText,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    textStyle: TextStyle(
                      color: theme.textColor,
                      fontSize: 19.sp,
                      height: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Divider ذهبي
                Container(height: 1, color: theme.numberColor.withValues(alpha: 0.25)),
                SizedBox(height: 14.h),

                // اسم السورة
                Text(
                  'سورة $_surahName',
                  style: GoogleFonts.amiri(
                    textStyle: TextStyle(
                      color: theme.surahColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndShare() async {
    setState(() => _isSharing = true);
    try {
      // التقاط الـ Widget كصورة عالية الجودة
      final RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // حفظ الصورة في مسار مؤقت
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/ayah_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // مشاركة الصورة
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'image/png')],
        text: 'سورة $_surahName - الآية $_ayahNumber\n\nمن تطبيق مُرَتِّل القرآن 📖',
      );
    } catch (e) {
      debugPrint('Error capturing card: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }
}

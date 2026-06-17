import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import '../controller/wasiya_controller.dart';

class WasiyaView extends GetView<WasiyaController> {
  const WasiyaView({super.key});

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

    final List<String> stepsTitles = [
      'سورة الفاتحة',
      'آية الكرسي',
      'أواخر البقرة',
      'سورة الإخلاص',
      'سورة الفلق',
      'سورة الناس',
      'ورد التسبيح',
      'ورد الاستغفار',
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: TextApp(
          text: 'وصية الحاج إبراهيم المقيد (أبو خضر)',
          color: primaryColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final currentStepIndex = controller.selectedStepIndex.value;

          // Define step content dynamically inside Obx to track reactive changes
          final List<Map<String, dynamic>> stepsData = [
            {
              'title': 'سورة الفاتحة',
              'type': 'reading',
              'text':
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝ الرَّحْمَٰنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ ۝ إِيَّاكَ نَعْبُدُ وإِيَّاكَ نَسْتَعِينُ ۝ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
              'isDone': controller.isFatihaDone.value,
              'onTap': () => controller.completeReadingStep(1),
            },
            {
              'title': 'آية الكرسي',
              'type': 'reading',
              'text':
                  'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
              'isDone': controller.isAyahKursiDone.value,
              'onTap': () => controller.completeReadingStep(2),
            },
            {
              'title': 'أواخر سورة البقرة',
              'type': 'reading',
              'text':
                  'آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْهِ الْمَصِيرُ ۝ لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
              'isDone': controller.isLastBaqarahDone.value,
              'onTap': () => controller.completeReadingStep(3),
            },
            {
              'title': 'سورة الإخلاص',
              'type': 'reading',
              'text':
                  'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
              'isDone': controller.isIkhlasDone.value,
              'onTap': () => controller.completeReadingStep(4),
            },
            {
              'title': 'سورة الفلق',
              'type': 'reading',
              'text':
                  'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
              'isDone': controller.isFalaqDone.value,
              'onTap': () => controller.completeReadingStep(5),
            },
            {
              'title': 'سورة الناس',
              'type': 'reading',
              'text':
                  'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
              'isDone': controller.isNasDone.value,
              'onTap': () => controller.completeReadingStep(6),
            },
            {
              'title': 'التسبيح',
              'type': 'counter',
              'text': 'سبحان الله والحمد لله ولا اله الا الله والله اكبر',
              'currentCount': controller.tasbeehCount.value,
              'targetCount': 100,
              'onTap': () => controller.incrementTasbeeh(),
            },
            {
              'title': 'الاستغفار',
              'type': 'counter',
              'text': 'أستغفر الله العظيم',
              'currentCount': controller.istighfarCount.value,
              'targetCount': 100,
              'onTap': () => controller.incrementIstighfar(),
            },
          ];

          final step = stepsData[currentStepIndex];
          final isStepCounter = step['type'] == 'counter';
          final bool isStepDone = currentStepIndex < 6
              ? step['isDone'] as bool
              : (step['currentCount'] as int) >= 100;

          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 8.h),
                  // 1. Zikr Selector chips
                  _buildStepSelector(
                    stepsTitles,
                    primaryColor,
                    goldColor,
                    cardBackgroundColor,
                    outlineColor,
                    textColor,
                  ),
                  SizedBox(height: 14.h),

                  // 2. Abu Khader profile card with image and prayer
                  _buildAbuKhaderProfileCard(
                    primaryColor,
                    goldColor,
                    cardBackgroundColor,
                    outlineColor,
                    textColor,
                  ),
                  SizedBox(height: 16.h),

                  // 3. Central Content area
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isStepCounter) ...[
                          // Reading Arabic card
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding: EdgeInsets.all(18.w),
                            constraints: BoxConstraints(maxHeight: 220.h),
                            decoration: BoxDecoration(
                              color: cardBackgroundColor,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: outlineColor,
                                width: 1.w,
                              ),
                              boxShadow: AppTheme.shadowSm,
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                step['text'] as String,
                                textAlign: TextAlign.justify,
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.amiri(
                                  textStyle: TextStyle(
                                    color: textColor,
                                    fontSize: 18.sp,
                                    height: 1.85,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          // Circle button for reading
                          _buildReadingButton(
                            primaryColor,
                            goldColor,
                            cardBackgroundColor,
                            outlineColor,
                            textColor,
                            isDark,
                            step['onTap'] as VoidCallback,
                            isStepDone,
                          ),
                        ] else ...[
                          // Counter text card
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: cardBackgroundColor,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: outlineColor,
                                width: 1.w,
                              ),
                              boxShadow: AppTheme.shadowSm,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              step['text'] as String,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.amiri(
                                textStyle: TextStyle(
                                  color: primaryColor,
                                  fontSize: 22.sp,
                                  height: 1.6,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // Concentric counter button
                          _buildCounterButton(
                            primaryColor,
                            goldColor,
                            cardBackgroundColor,
                            outlineColor,
                            textColor,
                            isDark,
                            step['onTap'] as VoidCallback,
                            step['currentCount'] as int,
                            step['targetCount'] as int,
                            isStepDone,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 4. Bottom progress display & Reset Controls
                  _buildBottomProgressAndControls(
                    primaryColor,
                    goldColor,
                    cardBackgroundColor,
                    outlineColor,
                    textColor,
                    isDark,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
              // Success overlay
              if (controller.isCompleted.value)
                _buildSuccessBanner(backgroundColor, primaryColor, goldColor),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepSelector(
    List<String> stepsTitles,
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
  ) {
    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) {
          final isSelected = controller.selectedStepIndex.value == index;
          bool isStepDone = false;
          switch (index) {
            case 0:
              isStepDone = controller.isFatihaDone.value;
              break;
            case 1:
              isStepDone = controller.isAyahKursiDone.value;
              break;
            case 2:
              isStepDone = controller.isLastBaqarahDone.value;
              break;
            case 3:
              isStepDone = controller.isIkhlasDone.value;
              break;
            case 4:
              isStepDone = controller.isFalaqDone.value;
              break;
            case 5:
              isStepDone = controller.isNasDone.value;
              break;
            case 6:
              isStepDone = controller.tasbeehCount.value >= 100;
              break;
            case 7:
              isStepDone = controller.istighfarCount.value >= 100;
              break;
          }
          final String title = stepsTitles[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              controller.selectStep(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? primary : cardBg,
                borderRadius: BorderRadius.circular(24.r),
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
                    title,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAbuKhaderProfileCard(
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: outline, width: 1.w),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 1.5.w),
              boxShadow: [
                BoxShadow(color: gold.withValues(alpha: 0.1), blurRadius: 4.r),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/photos/abu_khader.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, color: gold, size: 20.r);
                },
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'وصية الحاج إبراهيم المقيد (أبو خضر)',
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      color: primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'رحمه الله تعالى وجعل هذه الطاعة في ميزان حسناته',
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      color: text.withValues(alpha: 0.5),
                      fontSize: 9.5.sp,
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

  Widget _buildReadingButton(
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
    bool isDark,
    VoidCallback onTap,
    bool isDone,
  ) {
    final scale = 1.0.obs;

    return GestureDetector(
      onTapDown: (_) {
        scale.value = 0.92;
        HapticFeedback.mediumImpact();
        onTap();
      },
      onTapUp: (_) => scale.value = 1.0,
      onTapCancel: () => scale.value = 1.0,
      child: Obx(() {
        return AnimatedScale(
          scale: scale.value,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 130.w,
            height: 130.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? const Color(0xFF064E3B) : cardBg,
              border: Border.all(
                color: isDone ? const Color(0xFF064E3B) : gold,
                width: 3.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDone
                      ? const Color(0xFF064E3B).withValues(alpha: 0.2)
                      : gold.withValues(alpha: 0.15),
                  blurRadius: 16.r,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDone ? Icons.check : Icons.chrome_reader_mode_outlined,
                  color: isDone ? Colors.white : gold,
                  size: 28.r,
                ),
                SizedBox(height: 6.h),
                Text(
                  isDone ? 'تمت القراءة' : 'أتممت القراءة',
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      color: isDone ? Colors.white : text,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCounterButton(
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
    bool isDark,
    VoidCallback onTap,
    int currentCount,
    int targetCount,
    bool isDone,
  ) {
    final scale = 1.0.obs;

    return GestureDetector(
      onTapDown: (_) {
        scale.value = 0.92;
        HapticFeedback.mediumImpact();
        onTap();
      },
      onTapUp: (_) => scale.value = 1.0,
      onTapCancel: () => scale.value = 1.0,
      child: Obx(() {
        final countStr = _toArabicNumbers(currentCount.toString());
        final targetStr = _toArabicNumbers(targetCount.toString());

        return AnimatedScale(
          scale: scale.value,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 180.w,
            height: 180.w,
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
                  width: 166.w,
                  height: 166.w,
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
                          fontSize: 38.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: 44.w,
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
    Color primary,
    Color gold,
    Color cardBg,
    Color outline,
    Color text,
    bool isDark,
  ) {
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
                    'تقدم الوصية اليوم:',
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
              Obx(() {
                int completed = 0;
                if (controller.isFatihaDone.value) completed++;
                if (controller.isAyahKursiDone.value) completed++;
                if (controller.isLastBaqarahDone.value) completed++;
                if (controller.isIkhlasDone.value) completed++;
                if (controller.isFalaqDone.value) completed++;
                if (controller.isNasDone.value) completed++;
                if (controller.tasbeehCount.value >= 100) completed++;
                if (controller.istighfarCount.value >= 100) completed++;

                return Text(
                  '${_toArabicNumbers(completed.toString())} / ٨ خطوات',
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      color: gold,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(() {
            int completed = 0;
            if (controller.isFatihaDone.value) completed++;
            if (controller.isAyahKursiDone.value) completed++;
            if (controller.isLastBaqarahDone.value) completed++;
            if (controller.isIkhlasDone.value) completed++;
            if (controller.isFalaqDone.value) completed++;
            if (controller.isNasDone.value) completed++;
            if (controller.tasbeehCount.value >= 100) completed++;
            if (controller.istighfarCount.value >= 100) completed++;
            final progress = (completed / 8.0).clamp(0.0, 1.0);

            return ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5.h,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(gold),
              ),
            );
          }),
          SizedBox(height: 10.h),
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
                    size: 16.r,
                  ),
                  label: Text(
                    'إعادة البدء بالوصية',
                    style: GoogleFonts.getFont(
                      'Noto Naskh Arabic',
                      textStyle: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
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
      title: 'إعادة ضبط الوصية',
      titleStyle: GoogleFonts.getFont(
        'Noto Naskh Arabic',
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      middleText: 'هل تريد تصفير كل الخطوات والعدادات للبدء من جديد اليوم؟',
      middleTextStyle: GoogleFonts.getFont('Noto Naskh Arabic'),
      backgroundColor: Colors.white,
      radius: 16.r,
      textConfirm: 'نعم، إعادة ضبط',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF003527),
      textCancel: 'إلغاء',
      cancelTextColor: const Color(0xFF003527),
      onConfirm: () {
        controller.resetWasiya();
        Get.back();
      },
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
          color: bg,
          border: Border(
            top: BorderSide(color: gold.withValues(alpha: 0.3), width: 1.w),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تقبل الله طاعتك وغفر ذنبك ✨',
              style: GoogleFonts.getFont(
                'Noto Naskh Arabic',
                textStyle: TextStyle(
                  color: primary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'العودة للرئيسية',
                  style: GoogleFonts.getFont(
                    'Noto Naskh Arabic',
                    textStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
}

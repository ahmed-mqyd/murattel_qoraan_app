import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/images/images_const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:murattel_qoraan_app/screens/settings_screen/controller/settings_controller.dart';
import 'package:murattel_qoraan_app/core/controllers/audio_controller.dart';

class HomeController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _moonTimer;
  final PageController moonPageController = PageController();

  final isPlaying = false.obs;
  final isAudioLoading = false.obs;

  // Bookmark tracking
  final bookmarkSurahId = (-1).obs;
  final bookmarkSurahName = ''.obs;
  final bookmarkAyahIndex = (-1).obs;

  // Favorites lists
  final favoriteAyahsList = <Map<String, dynamic>>[].obs;
  final favoriteAzkarList = <Map<String, dynamic>>[].obs;

  // Daily Goal (Portion) tracking
  final todayReadCount = 0.obs;
  final dailyGoalProgress = 0.0.obs;
  final dailyGoalPercentage = '0%'.obs;
  final dailyGoalRemainingText = ''.obs;

  // Enhanced Daily Checklist states
  final isMorningAzkarDone = false.obs;
  final isEveningAzkarDone = false.obs;
  final dailyTasbeehCount = 0.obs;
  final isWasiyaDone = false.obs;
  final overallGoalProgress = 0.0.obs;
  final overallGoalPercentage = '0%'.obs;

  // Daily Ayah state
  final dailyAyahText = ''.obs;
  final dailyAyahTranslation = ''.obs;
  final dailyAyahSurahName = ''.obs;
  final dailyAyahSurahId = 1.obs;
  final dailyAyahNumber = 1.obs;
  final dailyAyahGlobalNumber = 1.obs;
  final isSaved = false.obs;

  // Al-Maqeed Family Moons state
  final currentMoonIndex = 0.obs;
  final List<Map<String, String>> familyMoons = [
    {'name': 'حسن المقيد', 'image': hassanMqyd},
    {'name': 'حسام المقيد', 'image': hussam},
    {'name': 'الحاج ابراهيم المقيد أبو خضر', 'image': khader},
    {'name': 'محمود المقيد', 'image': mahmoud},
    {'name': 'محمد المقيد', 'image': mohamed},
    {'name': 'حسام وعبد الغني المقيد ', 'image': hussamAbed},
    {'name': 'يوسف المقيد', 'image': yosefMqyd},
    {'name': 'الحاج ابراهيم المقيد ابو خضر', 'image': abuKhader},
    {'name': 'محمود المقيد', 'image': mahmoudMqyd},
  ];

  final List<Map<String, dynamic>> _dailyAyahsList = [
    {
      'textAr':
          'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ',
      'textEn':
          'And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.',
      'surahNameAr': 'البقرة',
      'surahNameEn': 'Al-Baqarah',
      'surahId': 2,
      'ayahNumber': 186,
      'globalAyahNumber': 193,
    },
    {
      'textAr':
          'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ',
      'textEn':
          'So do not weaken and do not grieve, and you will be superior if you are [true] believers.',
      'surahNameAr': 'آل عمران',
      'surahNameEn': 'Al-Imran',
      'surahId': 3,
      'ayahNumber': 139,
      'globalAyahNumber': 432,
    },
    {
      'textAr': 'قَالَ لَا تَخَافَا ۖ إِنَّنِي مَعَكُمَا أَسْمَعُ وَأَرَىٰ',
      'textEn':
          'He said, "Fear not. Indeed, I am with you both; I hear and I see."',
      'surahNameAr': 'طه',
      'surahNameEn': 'Taha',
      'surahId': 20,
      'ayahNumber': 46,
      'globalAyahNumber': 2394,
    },
    {
      'textAr': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'textEn':
          'For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.',
      'surahNameAr': 'الشرح',
      'surahNameEn': 'Ash-Sharh',
      'surahId': 94,
      'ayahNumber': 5,
      'globalAyahNumber': 6084,
    },
    {
      'textAr':
          'وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا ۚ وَإِنَّ اللَّهَ لَمَعَ الْمُحْسِنِينَ',
      'textEn':
          'And those who strive for Us - We will surely guide them to Our ways. And indeed, Allah is with the doers of good.',
      'surahNameAr': 'العنكبوت',
      'surahNameEn': 'Al-Ankabut',
      'surahId': 29,
      'ayahNumber': 69,
      'globalAyahNumber': 3390,
    },
    {
      'textAr':
          'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
      'textEn':
          'Say, "O My servants who have transgressed against themselves, do not despair of the mercy of Allah. Indeed, Allah forgives all sins."',
      'surahNameAr': 'الزمر',
      'surahNameEn': 'Az-Zumar',
      'surahId': 39,
      'ayahNumber': 53,
      'globalAyahNumber': 4111,
    },
    {
      'textAr': 'وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ',
      'textEn': 'And your Lord says, "Call upon Me; I will respond to you."',
      'surahNameAr': 'غافر',
      'surahNameEn': 'Ghafir',
      'surahId': 40,
      'ayahNumber': 60,
      'globalAyahNumber': 4217,
    },
    {
      'textAr':
          'رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
      'textEn':
          'Our Lord, grant us from Yourself mercy and prepare for us from our affair right guidance.',
      'surahNameAr': 'الكهف',
      'surahNameEn': 'Al-Kahf',
      'surahId': 18,
      'ayahNumber': 10,
      'globalAyahNumber': 2115,
    },
    {
      'textAr': 'مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ',
      'textEn':
          'Your Lord has not forsaken you, [O Muhammad], nor has He detested [you].',
      'surahNameAr': 'الضحى',
      'surahNameEn': 'Ad-Duha',
      'surahId': 93,
      'ayahNumber': 3,
      'globalAyahNumber': 6075,
    },
    {
      'textAr': 'وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
      'textEn':
          'And [remember] when your Lord proclaimed, "If you are grateful, I will surely increase you [in favor]"',
      'surahNameAr': 'إبراهيم',
      'surahNameEn': 'Ibrahim',
      'surahId': 14,
      'ayahNumber': 7,
      'globalAyahNumber': 1775,
    },
  ];

  @override
  void onInit() {
    super.onInit();

    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      
      final processingState = state.processingState;
      isAudioLoading.value = processingState == ProcessingState.loading ||
                           processingState == ProcessingState.buffering;

      if (processingState == ProcessingState.completed) {
        isPlaying.value = false;
      }
    });

    _moonTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      nextMoon();
    });

    refreshData();
  }

  void nextMoon() {
    if (familyMoons.isEmpty) return;
    currentMoonIndex.value = (currentMoonIndex.value + 1) % familyMoons.length;
    if (moonPageController.hasClients) {
      try {
        moonPageController.animateToPage(
          currentMoonIndex.value,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // نادراً ما يحدث تداخل هنا، نقوم بتجاهله لمنع انهيار التطبيق
      }
    }
    _resetTimer();
  }

  void previousMoon() {
    if (familyMoons.isEmpty) return;
    currentMoonIndex.value =
        (currentMoonIndex.value - 1 + familyMoons.length) % familyMoons.length;
    if (moonPageController.hasClients) {
      try {
        moonPageController.animateToPage(
          currentMoonIndex.value,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // تجاهل الخطأ
      }
    }
    _resetTimer();
  }

  void _resetTimer() {
    _moonTimer?.cancel();
    _moonTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      nextMoon();
    });
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    _moonTimer?.cancel();
    moonPageController.dispose();
    super.onClose();
  }

  void refreshData() {
    loadBookmark();
    loadDailyGoal();
    loadDailyAyah();
    loadFavorites();
  }

  void loadBookmark() {
    final prefs = Get.find<SharedPreferences>();
    bookmarkSurahId.value = prefs.getInt('bookmark_surah_id') ?? -1;
    bookmarkSurahName.value = prefs.getString('bookmark_surah_name') ?? '';
    bookmarkAyahIndex.value = prefs.getInt('bookmark_ayah_index') ?? -1;
  }

  void loadFavorites() {
    final prefs = Get.find<SharedPreferences>();
    
    // 1. Load Quran favorites
    final favAyahs = prefs.getStringList('mushaf_favorites_list') ?? [];
    final List<Map<String, dynamic>> parsedAyahs = [];
    for (final key in favAyahs) {
      final parts = key.split('-');
      if (parts.length == 2) {
        final int sId = int.tryParse(parts[0]) ?? 1;
        final int aIndex = int.tryParse(parts[1]) ?? 0;
        final String sName = prefs.getString('surah_name_$sId') ?? 'سورة $sId';
        parsedAyahs.add({
          'surahId': sId,
          'surahName': sName,
          'ayahIndex': aIndex,
        });
      }
    }
    favoriteAyahsList.assignAll(parsedAyahs);

    // 2. Load Azkar favorites
    final favAzkar = prefs.getStringList('azkar_favorites_list') ?? [];
    final List<Map<String, dynamic>> parsedAzkar = [];
    for (final text in favAzkar) {
      String category = 'morning';
      String categoryName = 'أذكار الصباح';
      
      if (text.contains('بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي') || text.contains('قِنِي عَذَابَكَ') || text.contains('أَمُوتُ وَأَحْيَا')) {
        category = 'sleep';
        categoryName = 'أذكار النوم';
      } else if (text.contains('أستغفر الله') || text.contains('السلام ومنك السلام') || text.contains('سبحان الله') || text.contains('الحمد لله') || text.contains('الله أكبر')) {
        category = 'after_prayer';
        categoryName = 'بعد الصلاة';
      } else if (text.contains('أَمْسَيْنَا وَأَمْسَى')) {
        category = 'evening';
        categoryName = 'أذكار المساء';
      }
      
      parsedAzkar.add({
        'text': text,
        'category': category,
        'categoryName': categoryName,
      });
    }
    favoriteAzkarList.assignAll(parsedAzkar);
  }

  void loadDailyGoal() {
    final prefs = Get.find<SharedPreferences>();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    // 1. Quran Reading
    final count = prefs.getInt('verses_read_$todayStr') ?? 0;
    todayReadCount.value = count;

    final int goal = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().dailyGoal.value
        : 20;

    final double readingProg = (count / goal.toDouble()).clamp(0.0, 1.0);
    dailyGoalProgress.value = readingProg;

    final String pct = '${(readingProg * 100).toInt()}%';
    dailyGoalPercentage.value = _toArabicNumbers(pct);

    final int remaining = (goal - count).clamp(0, goal);
    if (remaining > 0) {
      final String remStr =
          'بقي لك ${_toArabicNumbers(remaining.toString())} آية لإكمال وردك اليومي';
      dailyGoalRemainingText.value = remStr;
    } else {
      dailyGoalRemainingText.value = 'أحسنت! لقد أكملت وردك اليومي اليوم';
    }

    // 2. Morning Azkar
    isMorningAzkarDone.value =
        prefs.getBool('morning_azkar_$todayStr') ?? false;

    // 3. Evening Azkar
    isEveningAzkarDone.value =
        prefs.getBool('evening_azkar_$todayStr') ?? false;

    // 4. Daily Tasbeeh (out of daily goal of 100)
    final tasbeehVal = prefs.getInt('daily_tasbeeh_count_$todayStr') ?? 0;
    dailyTasbeehCount.value = tasbeehVal;
    final double tasbeehProg = (tasbeehVal / 100.0).clamp(0.0, 1.0);

    // 5. Wasiya of Ibrahim Al-Maqeed (Abu Khader)
    isWasiyaDone.value = prefs.getBool('wasiya_abukhader_$todayStr') ?? false;

    // 6. Overall Calculation
    final double morningProg = isMorningAzkarDone.value ? 1.0 : 0.0;
    final double eveningProg = isEveningAzkarDone.value ? 1.0 : 0.0;
    final double wasiyaProg = isWasiyaDone.value ? 1.0 : 0.0;
    final double overallProg =
        (readingProg + morningProg + eveningProg + tasbeehProg + wasiyaProg) /
        5.0;

    overallGoalProgress.value = overallProg;
    final String overallPct = '${(overallProg * 100).toInt()}%';
    overallGoalPercentage.value = _toArabicNumbers(overallPct);
  }

  void loadDailyAyah() {
    final now = DateTime.now();
    final int dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % _dailyAyahsList.length;
    final map = _dailyAyahsList[index];

    dailyAyahText.value = map['textAr'] as String;
    dailyAyahTranslation.value = map['textEn'] as String;
    dailyAyahSurahName.value = map['surahNameAr'] as String;
    dailyAyahSurahId.value = map['surahId'] as int;
    dailyAyahNumber.value = map['ayahNumber'] as int;
    dailyAyahGlobalNumber.value = map['globalAyahNumber'] as int;

    final prefs = Get.find<SharedPreferences>();
    final savedList = prefs.getStringList('saved_ayahs_keys') ?? [];
    isSaved.value = savedList.contains(
      '${map['surahId']}-${map['ayahNumber']}',
    );
  }

  Future<void> togglePlay() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
      return;
    }

    isAudioLoading.value = true;

    final prefs = Get.find<SharedPreferences>();
    final reciterKey =
        prefs.getString('settings_selected_reciter') ?? 'alafasy';
    String reciterId;
    switch (reciterKey) {
      case 'abdulbasit':
        reciterId = 'ar.abdulbasitmurattal';
        break;
      case 'almuaiqly':
        reciterId = 'ar.maheralmuaiqly';
        break;
      case 'ghamdi':
        reciterId = 'ar.saadghamidi';
        break;
      case 'faresabbad':
        reciterId = 'Fares_Abbad_64kbps';
        break;
      case 'yasser':
        reciterId = 'Yasser_Ad-Dussary_128kbps';
        break;
      case 'alafasy':
      default:
        reciterId = 'ar.alafasy';
        break;
    }

    final urlString = AudioController.getAudioUrl(
      reciterId,
      dailyAyahSurahId.value,
      dailyAyahNumber.value,
      dailyAyahGlobalNumber.value,
    );

    try {
      await _audioPlayer.setUrl(urlString);
      _audioPlayer.play();
    } catch (e) {
      isAudioLoading.value = false;
      isPlaying.value = false;
      Get.snackbar(
        'مرتل القرآن',
        'فشل تشغيل الصوت، يرجى التحقق من الاتصال بالإنترنت',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isAudioLoading.value = false;
    }
  }

  Future<void> copyToClipboard() async {
    final String refStr =
        '[سورة ${dailyAyahSurahName.value} - الآية ${dailyAyahNumber.value}]';
    final String textToCopy =
        '${dailyAyahText.value}\n\n$refStr\n${dailyAyahTranslation.value}';
    await Clipboard.setData(ClipboardData(text: textToCopy));

    Get.snackbar(
      'مرتل القرآن',
      'تم نسخ الآية إلى الحافظة بنجاح',

      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF003527),
      colorText: Colors.white,
    );
  }

  Future<void> toggleSaveAyah() async {
    final prefs = Get.find<SharedPreferences>();
    final String key = '${dailyAyahSurahId.value}-${dailyAyahNumber.value}';
    final List<String> savedList =
        prefs.getStringList('saved_ayahs_keys') ?? [];

    if (savedList.contains(key)) {
      savedList.remove(key);
      isSaved.value = false;
      Get.snackbar(
        'مرتل القرآن',
        'تم إزالة الآية من المحفوظات',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF003527),
        colorText: Colors.white,
      );
    } else {
      savedList.add(key);
      isSaved.value = true;
      Get.snackbar(
        'مرتل القرآن',
        'تم حفظ الآية في المحفوظات',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFC5A059),
        colorText: Colors.white,
      );
    }
    await prefs.setStringList('saved_ayahs_keys', savedList);
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

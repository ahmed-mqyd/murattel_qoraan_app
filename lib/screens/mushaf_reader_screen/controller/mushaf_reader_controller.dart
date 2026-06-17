import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home_screen/controller/home_controller.dart';

class MushafReaderController extends GetxController {
  late final int surahId;
  late final String surahName;

  final isLoading = true.obs;
  final hasError = false.obs;

  final arVerses = <dynamic>[].obs;
  final enVerses = <dynamic>[].obs;

  // Typography scaling
  final arFontSize = 24.0.obs;
  final enFontSize = 14.0.obs;

  // Bookmarking state (Last Read position)
  final bookmarkedAyahIndex = (-1).obs;

  // Favorites state (Explicit bookmarked items)
  final favoriteAyahs = <String>[].obs;

  // Selected verse for translation / actions overlay
  final selectedAyahIndex = 0.obs;

  // Audio Playback
  late final AudioPlayer _audioPlayer;
  final isPlaying = false.obs;
  final isAudioLoading = false.obs;
  final playingAyahIndex =
      (-1).obs; // 0-indexed index of the verse in the active surah

  // Scroll Controller
  late final ScrollController scrollController;
  final RxList<double> ayahScrollOffsets = <double>[].obs;

  static const String _arFontKey = 'mushaf_ar_font_size';
  static const String _enFontKey = 'mushaf_en_font_size';
  static const String _bookmarkSurahIdKey = 'bookmark_surah_id';
  static const String _bookmarkAyahIndexKey = 'bookmark_ayah_index';

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    _audioPlayer = AudioPlayer();

    // Read route arguments
    surahId = Get.arguments['id'] ?? 1;
    surahName = Get.arguments['name'] ?? '';

    _loadSettings();
    _fetchSurahData();
    _initAudioListeners();
    _setupTrackingListener();
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _initAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
      if (state == PlayerState.playing) {
        isAudioLoading.value = false;
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _playNextAyah();
    });
  }

  Future<File> get _cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/surah_$surahId.json');
  }

  Future<void> _loadSettings() async {
    final prefs = Get.find<SharedPreferences>();
    arFontSize.value = prefs.getDouble(_arFontKey) ?? 24.0;
    enFontSize.value = prefs.getDouble(_enFontKey) ?? 14.0;

    // Load favorites
    final favList = prefs.getStringList('mushaf_favorites_list') ?? [];
    favoriteAyahs.assignAll(favList);

    // Check if initial ayah index was passed from navigation
    final initialAyah = Get.arguments['initialAyahIndex'] ?? -1;
    if (initialAyah >= 0) {
      selectedAyahIndex.value = initialAyah;
    } else {
      // Check if this surah is bookmarked and load index
      final bookmarkedId = prefs.getInt(_bookmarkSurahIdKey);
      if (bookmarkedId == surahId) {
        bookmarkedAyahIndex.value = prefs.getInt(_bookmarkAyahIndexKey) ?? -1;
        if (bookmarkedAyahIndex.value >= 0) {
          selectedAyahIndex.value = bookmarkedAyahIndex.value;
        }
      }
    }
  }

  Future<void> updateArFontSize(double size) async {
    arFontSize.value = size;
    final prefs = Get.find<SharedPreferences>();
    await prefs.setDouble(_arFontKey, size);
    calculateScrollOffsets();
  }

  Future<void> updateEnFontSize(double size) async {
    enFontSize.value = size;
    final prefs = Get.find<SharedPreferences>();
    await prefs.setDouble(_enFontKey, size);
  }

  Future<void> _fetchSurahData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final cache = await _cacheFile;
      if (await cache.exists()) {
        final content = await cache.readAsString();
        final json = jsonDecode(content);
        _parseSurahData(json);
        isLoading.value = false;

        // Auto scroll to bookmark if exists
        _scrollToBookmarkAfterInit();
        return;
      }

      // If cache missing, fetch side-by-side editions (Uthmani text and Sahih International translation)
      final url = Uri.parse(
        'https://api.alquran.cloud/v1/surah/$surahId/editions/quran-uthmani,en.sahih',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        _parseSurahData(decoded);

        // Save to cache file asynchronously
        await cache.writeAsString(jsonEncode(decoded));
        isLoading.value = false;

        _scrollToBookmarkAfterInit();
      } else {
        hasError.value = true;
        isLoading.value = false;
      }
    } catch (e) {
      // Check offline cache fallback
      final cache = await _cacheFile;
      if (await cache.exists()) {
        final content = await cache.readAsString();
        final json = jsonDecode(content);
        _parseSurahData(json);
        isLoading.value = false;
        _scrollToBookmarkAfterInit();
      } else {
        hasError.value = true;
        isLoading.value = false;
      }
    }
  }

  void _parseSurahData(Map<String, dynamic> data) {
    final editionsList = data['data'] as List<dynamic>;

    // Edition 0: Arabic Uthmani
    final arData = editionsList[0];
    arVerses.value = arData['ayahs'] as List<dynamic>;

    // Edition 1: English Translation
    final enData = editionsList[1];
    enVerses.value = enData['ayahs'] as List<dynamic>;

    calculateScrollOffsets();
  }

  void retryFetch() {
    _fetchSurahData();
  }

  void _scrollToBookmarkAfterInit() {
    final initialAyah = Get.arguments['initialAyahIndex'] ?? -1;
    if (initialAyah >= 0 && initialAyah < arVerses.length) {
      Future.delayed(const Duration(milliseconds: 600), () {
        scrollToAyah(initialAyah);
      });
    } else if (bookmarkedAyahIndex.value >= 0 &&
        bookmarkedAyahIndex.value < arVerses.length) {
      Future.delayed(const Duration(milliseconds: 600), () {
        scrollToAyah(bookmarkedAyahIndex.value);
      });
    }
  }

  void scrollToAyah(int index) {
    if (index >= 0 && index < ayahScrollOffsets.length) {
      final offset = ayahScrollOffsets[index];
      final headerHeight = 175.h; // Height of Surah header and margins
      final targetScroll = offset + headerHeight - 120.h;

      if (scrollController.hasClients) {
        scrollController.animateTo(
          targetScroll.clamp(0.0, scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // Bookmarking / Favoriting
  Future<void> toggleBookmark(int ayahIndex) async {
    final prefs = Get.find<SharedPreferences>();
    final key = '$surahId-$ayahIndex';
    
    if (favoriteAyahs.contains(key)) {
      favoriteAyahs.remove(key);
      Get.snackbar(
        'مرتل القرآن',
        'تم إزالة الآية من المفضلة',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFC5A059).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } else {
      favoriteAyahs.add(key);
      // Also save the surah name info for easy lookup later
      await prefs.setString('surah_name_$surahId', surahName);
      
      Get.snackbar(
        'مرتل القرآن',
        'تم إضافة الآية إلى المفضلة بنجاح',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF064E3B).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
    
    await prefs.setStringList('mushaf_favorites_list', favoriteAyahs.toList());

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshData();
    }
  }

  bool isAyahFavorite(int index) {
    return favoriteAyahs.contains('$surahId-$index');
  }

  // Audio Recitation Controlling
  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      if (playingAyahIndex.value == -1) {
        // Start from first verse or bookmarked verse
        final initialIndex = bookmarkedAyahIndex.value >= 0
            ? bookmarkedAyahIndex.value
            : 0;
        await playAyah(initialIndex);
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  Future<void> playAyah(int index) async {
    if (index < 0 || index >= arVerses.length) return;

    isAudioLoading.value = true;
    playingAyahIndex.value = index;
    selectedAyahIndex.value = index; // Keep selection synced with active audio
    scrollToAyah(index);

    // Get global ayah number in Quran
    final int globalAyahNumber = arVerses[index]['number'];

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
      case 'alafasy':
      default:
        reciterId = 'ar.alafasy';
        break;
    }

    final urlString =
        'https://cdn.alquran.cloud/media/audio/ayah/$reciterId/$globalAyahNumber';

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(urlString));
    } catch (e) {
      isAudioLoading.value = false;
      isPlaying.value = false;
      Get.snackbar(
'مرتل القرآن',
      'فشل في تشغيل التلاوة الصوتية، يرجى التحقق من اتصالك بالإنترنت.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void _setupTrackingListener() {
    ever(selectedAyahIndex, (int index) {
      if (arVerses.isNotEmpty && index >= 0 && index < arVerses.length) {
        final int globalAyahNumber = arVerses[index]['number'];
        _trackAyahRead(globalAyahNumber);
      }
    });
  }

  void _trackAyahRead(int globalAyahNumber) {
    try {
      final prefs = Get.find<SharedPreferences>();
      final todayStr = DateTime.now().toIso8601String().split(
        'T',
      )[0]; // yyyy-MM-dd
      final readKey = 'verses_read_$todayStr';

      // To avoid double counting the same ayah read in the same day, keep list of unique ids
      final readListKey = 'unique_verses_read_list_$todayStr';
      final List<String> readList = prefs.getStringList(readListKey) ?? [];
      final String ayahIdStr = '$surahId-$globalAyahNumber';

      if (!readList.contains(ayahIdStr)) {
        readList.add(ayahIdStr);
        prefs.setStringList(readListKey, readList);
        prefs.setInt(readKey, readList.length);

        // Also update total verses count
        final totalKey = 'total_verses_read';
        final totalRead = prefs.getInt(totalKey) ?? 0;
        prefs.setInt(totalKey, totalRead + 1);

        // Update streak logic
        _updateStreak(prefs, todayStr);
      }

      // Save last read position for the Home Screen's Continue Reading section
      prefs.setInt('bookmark_surah_id', surahId);
      prefs.setString('bookmark_surah_name', surahName);
      prefs.setInt('bookmark_ayah_index', selectedAyahIndex.value);

      // Refresh HomeController if registered to update Home UI in real-time
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshData();
      }
    } catch (e) {
      // ignore
    }
  }

  void _updateStreak(SharedPreferences prefs, String todayStr) {
    const String streakKey = 'suluk_streak';
    const String lastReadDateKey = 'suluk_last_read_date';

    final int currentStreak = prefs.getInt(streakKey) ?? 0;
    final String? lastReadDate = prefs.getString(lastReadDateKey);

    if (lastReadDate == null) {
      prefs.setInt(streakKey, 1);
      prefs.setString(lastReadDateKey, todayStr);
    } else if (lastReadDate != todayStr) {
      final lastDate = DateTime.parse(lastReadDate);
      final todayDate = DateTime.parse(todayStr);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        prefs.setInt(streakKey, currentStreak + 1);
        prefs.setString(lastReadDateKey, todayStr);
      } else if (difference > 1) {
        prefs.setInt(streakKey, 1);
        prefs.setString(lastReadDateKey, todayStr);
      }
    }
  }

  void _playNextAyah() {
    final nextIndex = playingAyahIndex.value + 1;
    if (nextIndex < arVerses.length) {
      playAyah(nextIndex);
    } else {
      // End of Surah
      playingAyahIndex.value = -1;
      isPlaying.value = false;
    }
  }

  void playPreviousAyah() {
    final prevIndex = playingAyahIndex.value - 1;
    if (prevIndex >= 0) {
      playAyah(prevIndex);
    }
  }

  void playNextAyahManual() {
    _playNextAyah();
  }

  String getCleanArText(int index) {
    final text = arVerses[index]['text'] ?? '';
    if (index == 0 &&
        surahId != 1 &&
        text.startsWith('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ')) {
      return text
          .replaceFirst('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '')
          .trim();
    }
    return text;
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

  void calculateScrollOffsets() {
    if (arVerses.isEmpty) return;

    final double screenWidth = Get.width;
    final double padding = 32.w; // 16.w padding on each side
    final double maxWidth = screenWidth - padding;

    final List<InlineSpan> spans = [];
    final List<int> startIndices = [];
    int currentLength = 0;

    for (int i = 0; i < arVerses.length; i++) {
      startIndices.add(currentLength);
      final text = getCleanArText(i);
      spans.add(TextSpan(text: text));
      currentLength += text.length;

      final marker = _toArabicNumbers((i + 1).toString());
      spans.add(TextSpan(text: marker));
      currentLength += marker.length;
    }

    final textSpan = TextSpan(
      children: spans,
      style: GoogleFonts.amiri(
        fontSize: arFontSize.value,
        height: 1.8,
        fontWeight: FontWeight.w600,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
    );

    textPainter.layout(maxWidth: maxWidth);

    final List<double> offsets = [];
    for (int i = 0; i < arVerses.length; i++) {
      final offset = textPainter.getOffsetForCaret(
        TextPosition(offset: startIndices[i]),
        Rect.zero,
      );
      offsets.add(offset.dy);
    }

    ayahScrollOffsets.value = offsets;
  }

  void selectPreviousAyah() {
    if (selectedAyahIndex.value > 0) {
      selectedAyahIndex.value--;
      if (isPlaying.value || playingAyahIndex.value != -1) {
        playAyah(selectedAyahIndex.value);
      } else {
        scrollToAyah(selectedAyahIndex.value);
      }
    }
  }

  void selectNextAyah() {
    if (selectedAyahIndex.value < arVerses.length - 1) {
      selectedAyahIndex.value++;
      if (isPlaying.value || playingAyahIndex.value != -1) {
        playAyah(selectedAyahIndex.value);
      } else {
        scrollToAyah(selectedAyahIndex.value);
      }
    }
  }
}

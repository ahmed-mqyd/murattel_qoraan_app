import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/audio_controller.dart';
import '../../../core/models/reciter.dart';
import '../../../core/routes/app_routes.dart';
import '../../home_screen/controller/home_controller.dart';

class MushafReaderController extends GetxController {
  // Access global AudioController
  final AudioController audioController = Get.find<AudioController>();

  // Static cache for offline Quran database
  static List<dynamic>? _cachedQuranData;

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

  // Audio Offline Download State
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final isSurahDownloaded = false.obs;

  // Tafseer state
  final showTafseer = false.obs;
  final tafseerVerses = <String>[].obs;
  final isTafseerLoading = false.obs;
  final tafseerError = ''.obs;

  // Audio Playback states mapped to AudioController
  final isPlaying = false.obs;
  final isAudioLoading = false.obs;
  final playingAyahIndex =
      (-1).obs; // 0-indexed index of the verse in the active surah

  StreamSubscription? _isPlayingSubscription;
  StreamSubscription? _isAudioLoadingSubscription;
  StreamSubscription? _playingAyahIndexSubscription;

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
    _isPlayingSubscription?.cancel();
    _isAudioLoadingSubscription?.cancel();
    _playingAyahIndexSubscription?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void _initAudioListeners() {
    // Bind observables to global AudioController
    isPlaying.value = audioController.isPlaying.value;
    isAudioLoading.value = audioController.isAudioLoading.value;

    _isPlayingSubscription = audioController.isPlaying.listen(
      (val) => isPlaying.value = val,
    );
    _isAudioLoadingSubscription = audioController.isAudioLoading.listen(
      (val) => isAudioLoading.value = val,
    );

    _playingAyahIndexSubscription = audioController.playingAyahIndex.listen((
      index,
    ) {
      final reciterId = _getReciterId();
      final bool isFullSurah = AudioController.isFullSurahReciter(reciterId);
      if (isFullSurah) {
        playingAyahIndex.value = -1;
        return;
      }
      if (audioController.playingSurahId.value == surahId) {
        if (index >= 0 && index < arVerses.length) {
          playingAyahIndex.value = index;
          selectedAyahIndex.value = index;
          scrollToAyah(index);
        }
      }
    });
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
      if (_cachedQuranData == null) {
        // Load the full Quran text from assets
        final String jsonString = await rootBundle.loadString(
          'assets/quran.json',
        );
        _cachedQuranData = jsonDecode(jsonString) as List<dynamic>;
      }

      final surah = _cachedQuranData!.firstWhere(
        (s) => s['number'] == surahId,
        orElse: () => null,
      );

      if (surah != null) {
        final List<dynamic> ayahs = surah['ayahs'];

        // Populate arVerses
        arVerses.assignAll(ayahs);

        // Populate enVerses (English translation mapped to 'text' key expected by the view)
        final List<dynamic> mappedEnVerses = ayahs.map((ayah) {
          return {
            'number': ayah['number'],
            'numberInSurah': ayah['numberInSurah'],
            'text': ayah['enText'] ?? '',
            'juz': ayah['juz'],
            'page': ayah['page'],
          };
        }).toList();

        enVerses.assignAll(mappedEnVerses);

        calculateScrollOffsets();
        isLoading.value = false;
        _scrollToBookmarkAfterInit();
        checkIfDownloaded();
        fetchTafseerData(); // Fetch Tafseer data asynchronously in the background
        await audioController.setupPlaylist(surahId, surahName, arVerses);

        // Sync index if already playing
        if (audioController.playingSurahId.value == surahId) {
          final activeIndex = audioController.playingAyahIndex.value;
          if (activeIndex >= 0 && activeIndex < arVerses.length) {
            playingAyahIndex.value = activeIndex;
            selectedAyahIndex.value = activeIndex;
            scrollToAyah(activeIndex);
          }
        }
      } else {
        throw Exception(
          'السورة المطلوبة غير موجودة في قاعدة البيانات المحلية.',
        );
      }
    } catch (e) {
      debugPrint('Error loading offline Quran data: $e');
      hasError.value = true;
      isLoading.value = false;
    }
  }

  void retryFetch() {
    _fetchSurahData();
  }

  Future<void> fetchTafseerData() async {
    isTafseerLoading.value = true;
    tafseerError.value = '';

    try {
      final directory = await getApplicationDocumentsDirectory();
      final String cachePath =
          '${directory.path}/tafseer/ar.muyassar/surah_$surahId.json';
      final file = File(cachePath);

      if (await file.exists()) {
        final String cachedString = await file.readAsString();
        final Map<String, dynamic> cachedJson = jsonDecode(cachedString);
        _parseAndSetTafseer(cachedJson);
        isTafseerLoading.value = false;
        return;
      }

      // If not cached, fetch from network
      final response = await http
          .get(
            Uri.parse(
              'https://api.alquran.cloud/v1/surah/$surahId/ar.muyassar',
            ),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 200 && jsonResponse['data'] != null) {
          // Cache locally
          await file.parent.create(recursive: true);
          await file.writeAsString(response.body);

          _parseAndSetTafseer(jsonResponse);
          isTafseerLoading.value = false;
        } else {
          throw Exception('استجابة غير صالحة من السيرفر');
        }
      } else {
        throw Exception(
          'فشل تحميل التفسير: رمز الحماية ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching Tafseer: $e');
      tafseerError.value =
          'لا يوجد اتصال بالإنترنت لعرض التفسير. يرجى الاتصال بالإنترنت والمحاولة مجدداً.';
      isTafseerLoading.value = false;
    }
  }

  void _parseAndSetTafseer(Map<String, dynamic> jsonMap) {
    final List<dynamic> ayahs = jsonMap['data']['ayahs'];
    final List<String> texts = ayahs
        .map((ayah) => ayah['text'] as String)
        .toList();
    tafseerVerses.assignAll(texts);
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
    if (audioController.playingSurahId.value != surahId) {
      await audioController.setupPlaylist(surahId, surahName, arVerses);
      await audioController.playAyah(
        bookmarkedAyahIndex.value >= 0 ? bookmarkedAyahIndex.value : 0,
      );
    } else {
      await audioController.togglePlayPause();
    }
  }

  String _getReciterId() {
    final prefs = Get.find<SharedPreferences>();
    return Reciters.selected(prefs).audioId;
  }

  Future<String> _getLocalPathForAyah(int globalAyahNumber) async {
    final directory = await getApplicationDocumentsDirectory();
    final reciterId = _getReciterId();
    return '${directory.path}/audio/$reciterId/$globalAyahNumber.mp3';
  }

  Future<String> _getLocalPathForSurah(int surahId) async {
    final directory = await getApplicationDocumentsDirectory();
    final reciterId = _getReciterId();
    return '${directory.path}/audio/$reciterId/surah_$surahId.mp3';
  }

  Future<void> checkIfDownloaded() async {
    if (arVerses.isEmpty) return;

    try {
      final reciterId = _getReciterId();
      final bool isFullSurah = AudioController.isFullSurahReciter(reciterId);

      if (isFullSurah) {
        final localPath = await _getLocalPathForSurah(surahId);
        final file = File(localPath);
        isSurahDownloaded.value = await file.exists();
      } else {
        bool allExist = true;
        for (int i = 0; i < arVerses.length; i++) {
          final int globalAyahNumber = arVerses[i]['number'];
          final localPath = await _getLocalPathForAyah(globalAyahNumber);
          final file = File(localPath);
          if (!await file.exists()) {
            allExist = false;
            break;
          }
        }
        isSurahDownloaded.value = allExist;
      }
    } catch (e) {
      isSurahDownloaded.value = false;
    }
  }

  Future<void> downloadSurahAudio() async {
    if (isDownloading.value || arVerses.isEmpty) return;

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    final reciterId = _getReciterId();
    final bool isFullSurah = AudioController.isFullSurahReciter(reciterId);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio/$reciterId');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      if (isFullSurah) {
        final localPath = await _getLocalPathForSurah(surahId);
        final file = File(localPath);

        if (!await file.exists()) {
          final urlString = AudioController.getSurahAudioUrl(
            reciterId,
            surahId,
          );

          final client = http.Client();
          final request = http.Request('GET', Uri.parse(urlString));
          final response = await client
              .send(request)
              .timeout(const Duration(minutes: 5));

          if (response.statusCode == 200) {
            final List<int> bytes = [];
            final int? contentLength = response.contentLength;
            int downloaded = 0;

            await for (final List<int> chunk in response.stream) {
              if (!isDownloading.value) {
                client.close();
                return;
              }
              bytes.addAll(chunk);
              downloaded += chunk.length;
              if (contentLength != null && contentLength > 0) {
                downloadProgress.value = downloaded / contentLength;
              }
            }
            await file.writeAsBytes(bytes);
          } else {
            throw Exception('فشل تحميل السورة الكريمة: ${response.statusCode}');
          }
        }
      } else {
        int downloadedCount = 0;
        final int totalCount = arVerses.length;

        for (int i = 0; i < totalCount; i++) {
          if (!isDownloading.value) return;

          final int globalAyahNumber = arVerses[i]['number'];
          final int ayahNumberInSurah = arVerses[i]['numberInSurah'];
          final localPath = await _getLocalPathForAyah(globalAyahNumber);
          final file = File(localPath);

          if (!await file.exists()) {
            final urlString = AudioController.getAudioUrl(
              reciterId,
              surahId,
              ayahNumberInSurah,
              globalAyahNumber,
            );
            final response = await http
                .get(Uri.parse(urlString))
                .timeout(const Duration(seconds: 15));

            if (response.statusCode == 200) {
              await file.writeAsBytes(response.bodyBytes);
            } else {
              throw Exception(
                'فشل تحميل الآية $globalAyahNumber: ${response.statusCode}',
              );
            }
          }

          downloadedCount++;
          downloadProgress.value = downloadedCount / totalCount;
        }
      }

      isSurahDownloaded.value = true;
      Get.snackbar(
        'مرتل القرآن',
        'تم تحميل سورة $surahName بنجاح للاستماع دون اتصال.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF003527),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint('Download error: $e');
      Get.snackbar(
        'مرتل القرآن',
        'حدث خطأ أثناء تحميل السورة: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
      checkIfDownloaded();
      await audioController.forceRebuildPlaylist();
    }
  }

  Future<void> deleteDownloadedSurahAudio() async {
    if (isDownloading.value || arVerses.isEmpty) return;

    try {
      final reciterId = _getReciterId();
      final bool isFullSurah = AudioController.isFullSurahReciter(reciterId);

      int deletedCount = 0;
      if (isFullSurah) {
        final localPath = await _getLocalPathForSurah(surahId);
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
          deletedCount++;
        }
      } else {
        for (int i = 0; i < arVerses.length; i++) {
          final int globalAyahNumber = arVerses[i]['number'];
          final localPath = await _getLocalPathForAyah(globalAyahNumber);
          final file = File(localPath);
          if (await file.exists()) {
            await file.delete();
            deletedCount++;
          }
        }
      }

      isSurahDownloaded.value = false;
      await audioController.forceRebuildPlaylist();
      if (deletedCount > 0) {
        Get.snackbar(
          'مرتل القرآن',
          'تم حذف الملفات الصوتية لسورة $surahName بنجاح لتوفير المساحة.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFC5A059),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error deleting files: $e');
    }
  }

  Future<void> playAyah(int index) async {
    if (index < 0 || index >= arVerses.length) return;

    final reciterId = _getReciterId();
    final bool isFullSurah = AudioController.isFullSurahReciter(reciterId);

    if (isFullSurah) {
      playingAyahIndex.value = -1;
    } else {
      playingAyahIndex.value = index;
      selectedAyahIndex.value =
          index; // Keep selection synced with active audio
      scrollToAyah(index);
    }

    try {
      if (audioController.playingSurahId.value != surahId) {
        await audioController.setupPlaylist(surahId, surahName, arVerses);
      }
      await audioController.playAyah(index);
    } catch (e) {
      isAudioLoading.value = false;
      isPlaying.value = false;
      Get.snackbar(
        'مرتل القرآن',
        'فشل في تشغيل التلاوة الصوتية، يرجى التحقق من اتصالك بالإنترنت.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A),
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

  void playPreviousAyah() {
    audioController.playPrevious();
  }

  void playNextAyahManual() {
    audioController.playNext();
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

  // ── Surah Navigation (Swipe Gestures) ──────────────────────────────────────

  /// قائمة أسماء السور الـ 114 — مرتبة حسب الرقم (index 0 = سورة 1)
  static const List<String> _surahNames = [
    'الفَاتِحَة',
    'البَقَرَة',
    'آل عِمرَان',
    'النِّسَاء',
    'المَائِدَة',
    'الأنعَام',
    'الأعرَاف',
    'الأنفَال',
    'التَّوبَة',
    'يُونُس',
    'هُود',
    'يُوسُف',
    'الرَّعْد',
    'إِبْرَاهِيم',
    'الحِجْر',
    'النَّحْل',
    'الإِسْرَاء',
    'الكَهْف',
    'مَرْيَم',
    'طه',
    'الأَنْبِيَاء',
    'الحَجّ',
    'المُؤْمِنُون',
    'النُّور',
    'الفُرْقَان',
    'الشُّعَرَاء',
    'النَّمْل',
    'القَصَص',
    'العَنْكَبُوت',
    'الرُّوم',
    'لُقْمَان',
    'السَّجْدَة',
    'الأَحْزَاب',
    'سَبَأ',
    'فَاطِر',
    'يس',
    'الصَّافَّات',
    'ص',
    'الزُّمَر',
    'غَافِر',
    'فُصِّلَت',
    'الشُّورَى',
    'الزُّخْرُف',
    'الدُّخَان',
    'الجَاثِيَة',
    'الأَحْقَاف',
    'مُحَمَّد',
    'الفَتْح',
    'الحُجُرَات',
    'ق',
    'الذَّارِيَات',
    'الطُّور',
    'النَّجْم',
    'القَمَر',
    'الرَّحْمَن',
    'الوَاقِعَة',
    'الحَدِيد',
    'المُجَادِلَة',
    'الحَشْر',
    'المُمْتَحَنَة',
    'الصَّفّ',
    'الجُمُعَة',
    'المُنَافِقُون',
    'التَّغَابُن',
    'الطَّلَاق',
    'التَّحْرِيم',
    'المُلْك',
    'القَلَم',
    'الحَاقَّة',
    'المَعَارِج',
    'نُوح',
    'الجِنّ',
    'المُزَّمِّل',
    'المُدَّثِّر',
    'القِيَامَة',
    'الإِنْسَان',
    'المُرْسَلَات',
    'النَّبَأ',
    'النَّازِعَات',
    'عَبَس',
    'التَّكْوِير',
    'الانْفِطَار',
    'المُطَفِّفِين',
    'الانْشِقَاق',
    'البُرُوج',
    'الطَّارِق',
    'الأَعْلَى',
    'الغَاشِيَة',
    'الفَجْر',
    'البَلَد',
    'الشَّمْس',
    'اللَّيْل',
    'الضُّحَى',
    'الشَّرْح',
    'التِّين',
    'العَلَق',
    'القَدْر',
    'البَيِّنَة',
    'الزَّلْزَلَة',
    'العَادِيَات',
    'القَارِعَة',
    'التَّكَاثُر',
    'العَصْر',
    'الهُمَزَة',
    'الفِيل',
    'قُرَيْش',
    'المَاعُون',
    'الكَوْثَر',
    'الكَافِرُون',
    'النَّصْر',
    'المَسَد',
    'الإِخْلَاص',
    'الفَلَق',
    'النَّاس',
  ];

  /// الانتقال إلى السورة التالية (إذا لم تكن آخر سورة)
  void navigateToNextSurah() {
    if (surahId >= 114) return; // لا يمكن التقدم بعد سورة الناس
    final int nextId = surahId + 1;
    final String nextName = _surahNames[nextId - 1]; // index = id - 1
    _navigateToSurah(nextId, nextName);
  }

  /// الانتقال إلى السورة السابقة (إذا لم تكن أول سورة)
  void navigateToPrevSurah() {
    if (surahId <= 1) return; // لا يمكن الرجوع قبل سورة الفاتحة
    final int prevId = surahId - 1;
    final String prevName = _surahNames[prevId - 1]; // index = id - 1
    _navigateToSurah(prevId, prevName);
  }

  /// التنقل الداخلي: يوقف الصوت ويستبدل الشاشة الحالية بالسورة المطلوبة
  void _navigateToSurah(int id, String name) {
    // إيقاف الصوت الحالي فوراً لمنع التداخل الصوتي
    audioController.audioPlayer.stop();

    // الانتقال إلى السورة الجديدة باستبدال الشاشة الحالية (offNamed)
    Get.offNamed(
      Routes.mushafReader,
      arguments: {'id': id, 'name': name, 'initialAyahIndex': -1},
      preventDuplicates: false,
    );
  }
}

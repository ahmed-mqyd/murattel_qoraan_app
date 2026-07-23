import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_session/audio_session.dart';
import 'package:murattel_qoraan_app/core/data/azkar_library_data.dart';
import 'package:murattel_qoraan_app/core/models/reciter.dart';
import 'package:murattel_qoraan_app/core/models/surah_meta.dart';

class AudioController extends GetxController {
  late final AudioPlayer audioPlayer;
  ConcatenatingAudioSource? _playlist;

  final isPlaying = false.obs;
  final isAudioLoading = false.obs;
  final playingAyahIndex = (-1).obs;
  final playingSurahId = (-1).obs;
  final playingSurahName = ''.obs;
  final activeVerses = <dynamic>[].obs;

  /// مفتاح التشغيل المخصص الجاري (مثل 'ruqyah') — فارغ عند تشغيل السور العادية
  final playingSelectionKey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();
    _initAudioSession();
    _initAudioListeners();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  void _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
    } catch (e) {
      Get.log("Failed to configure AudioSession: $e");
    }
  }

  void _initAudioListeners() {
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;

      final processingState = state.processingState;
      isAudioLoading.value =
          processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering;
    });

    audioPlayer.currentIndexStream.listen((index) {
      final reciterId = _getReciterId();
      if (AudioController.isFullSurahReciter(reciterId)) {
        playingAyahIndex.value = -1;
      } else if (index != null && index >= 0 && index < activeVerses.length) {
        playingAyahIndex.value = index;
      }
    });
  }

  String _getReciterId() {
    final prefs = Get.find<SharedPreferences>();
    return Reciters.selected(prefs).audioId;
  }

  String _getReciterNameArabic() {
    final prefs = Get.find<SharedPreferences>();
    return Reciters.selected(prefs).arabicName;
  }

  static String getAudioUrl(
    String reciterId,
    int surahId,
    int ayahNumberInSurah,
    int globalAyahNumber,
  ) {
    if (Reciters.byAudioId(reciterId).source == ReciterSource.everyAyah) {
      final String surahStr = surahId.toString().padLeft(3, '0');
      final String ayahStr = ayahNumberInSurah.toString().padLeft(3, '0');
      return 'https://everyayah.com/data/$reciterId/$surahStr$ayahStr.mp3';
    } else {
      return 'https://cdn.alquran.cloud/media/audio/ayah/$reciterId/$globalAyahNumber';
    }
  }

  static bool isFullSurahReciter(String reciterId) {
    return Reciters.byAudioId(reciterId).isFullSurah;
  }

  static String getSurahAudioUrl(String reciterId, int surahId) {
    final template = Reciters.byAudioId(reciterId).surahUrlTemplate;
    if (template == null) return '';
    return template.replaceAll('{surah}', surahId.toString().padLeft(3, '0'));
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

  /// تشغيل مجموعة آيات مخصصة (كالرقية الشرعية) بصوت القارئ المختار،
  /// مع دعم التشغيل في الخلفية وأزرار الإشعار — تماماً مثل شاشة المصحف.
  Future<void> playAyahSelection({
    required String selectionKey,
    required String albumTitle,
    required List<AyahRef> ayahs,
  }) async {
    final prefs = Get.find<SharedPreferences>();
    var reciter = Reciters.selected(prefs);
    // قرّاء السورة الكاملة لا يوفرون ملفات آية-بآية — نستخدم القارئ الافتراضي
    if (reciter.isFullSurah) {
      reciter = Reciters.byKey(Reciters.defaultKey);
    }

    // إعادة تعيين حالة تشغيل السور حتى لا تتشوش شاشة المصحف
    playingSurahId.value = -1;
    playingSurahName.value = albumTitle;
    activeVerses.clear();
    playingAyahIndex.value = -1;
    playingSelectionKey.value = selectionKey;

    final documents = await getApplicationDocumentsDirectory();
    final List<AudioSource> sources = [];

    for (final ref in ayahs) {
      final int globalAyah =
          SurahMetas.globalAyahStart(ref.surahId) + ref.ayahInSurah - 1;
      final surahName = SurahMetas.byId(ref.surahId).arabicName;
      final url = AudioController.getAudioUrl(
        reciter.audioId,
        ref.surahId,
        ref.ayahInSurah,
        globalAyah,
      );
      final localPath =
          '${documents.path}/audio/${reciter.audioId}/$globalAyah.mp3';
      final localFile = File(localPath);

      final tag = MediaItem(
        id: 'sel_${selectionKey}_$globalAyah',
        album: albumTitle,
        title: 'سورة $surahName — الآية ${ref.ayahInSurah}',
        artist: reciter.arabicName,
      );

      if (await localFile.exists()) {
        sources.add(AudioSource.file(localPath, tag: tag));
      } else {
        sources.add(AudioSource.uri(Uri.parse(url), tag: tag));
      }
    }

    try {
      isAudioLoading.value = true;
      _playlist = ConcatenatingAudioSource(children: sources);
      await audioPlayer.setAudioSource(_playlist!, preload: false);
      await audioPlayer.seek(Duration.zero, index: 0);
      await audioPlayer.play();
    } catch (e) {
      isAudioLoading.value = false;
      isPlaying.value = false;
      playingSelectionKey.value = '';
      Get.log('فشل تشغيل المجموعة الصوتية: $e');
    }
  }

  /// إيقاف التشغيل المخصص الجاري
  Future<void> stopSelection() async {
    playingSelectionKey.value = '';
    await audioPlayer.stop();
  }

  Future<void> setupPlaylist(
    int surahId,
    String surahName,
    List<dynamic> verses,
  ) async {
    // If it's already the same surah, don't rebuild it unless needed
    if (playingSurahId.value == surahId &&
        activeVerses.length == verses.length) {
      return;
    }

    playingSelectionKey.value = '';
    playingSurahId.value = surahId;
    playingSurahName.value = surahName;
    activeVerses.assignAll(verses);
    playingAyahIndex.value = -1;

    final reciterId = _getReciterId();
    final List<AudioSource> sources = [];
    final String rName = _getReciterNameArabic();
    final bool isFullSurah = AudioController.isFullSurahReciter(reciterId);

    if (isFullSurah) {
      final urlString = AudioController.getSurahAudioUrl(reciterId, surahId);
      final localPath = await _getLocalPathForSurah(surahId);
      final localFile = File(localPath);

      final AudioSource source;
      if (await localFile.exists()) {
        source = AudioSource.file(
          localPath,
          tag: MediaItem(
            id: 'surah_${surahId}_$reciterId',
            album: 'سورة $surahName',
            title: 'كامل التلاوة',
            artist: rName,
          ),
        );
      } else {
        source = AudioSource.uri(
          Uri.parse(urlString),
          tag: MediaItem(
            id: 'surah_${surahId}_$reciterId',
            album: 'سورة $surahName',
            title: 'كامل التلاوة',
            artist: rName,
          ),
        );
      }
      sources.add(source);
    } else {
      for (int i = 0; i < verses.length; i++) {
        final int globalAyahNumber = verses[i]['number'];
        final int ayahNumberInSurah = verses[i]['numberInSurah'];
        final urlString = AudioController.getAudioUrl(
          reciterId,
          surahId,
          ayahNumberInSurah,
          globalAyahNumber,
        );
        final localPath = await _getLocalPathForAyah(globalAyahNumber);
        final localFile = File(localPath);

        final AudioSource source;
        if (await localFile.exists()) {
          source = AudioSource.file(
            localPath,
            tag: MediaItem(
              id: 'ayah_${surahId}_${ayahNumberInSurah}_$reciterId',
              album: 'سورة $surahName',
              title: 'الآية $ayahNumberInSurah',
              artist: rName,
            ),
          );
        } else {
          source = AudioSource.uri(
            Uri.parse(urlString),
            tag: MediaItem(
              id: 'ayah_${surahId}_${ayahNumberInSurah}_$reciterId',
              album: 'سورة $surahName',
              title: 'الآية $ayahNumberInSurah',
              artist: rName,
            ),
          );
          // Trigger background caching for offline playback next time
          _cacheAudioFileInBackground(urlString, localPath);
        }
        sources.add(source);
      }
    }

    _playlist = ConcatenatingAudioSource(children: sources);
    await audioPlayer.setAudioSource(_playlist!, preload: false);
  }

  Future<void> playAyah(int index) async {
    final reciterId = _getReciterId();
    final bool isFullSurah = AudioController.isFullSurahReciter(reciterId);
    final targetIndex = isFullSurah ? 0 : index;

    if (!isFullSurah && (targetIndex < 0 || targetIndex >= activeVerses.length))
      return;
    try {
      isAudioLoading.value = true;
      await audioPlayer.seek(Duration.zero, index: targetIndex);
      await audioPlayer.play();
    } catch (e) {
      isAudioLoading.value = false;
      isPlaying.value = false;
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await audioPlayer.pause();
    } else {
      if (audioPlayer.currentIndex == null) {
        await playAyah(0);
      } else {
        await audioPlayer.play();
      }
    }
  }

  void playPrevious() {
    if (audioPlayer.hasPrevious) {
      audioPlayer.seekToPrevious();
    }
  }

  void playNext() {
    if (audioPlayer.hasNext) {
      audioPlayer.seekToNext();
    }
  }

  // Background audio caching helper
  Future<void> _cacheAudioFileInBackground(
    String urlString,
    String localPath,
  ) async {
    try {
      final file = File(localPath);
      if (await file.exists()) return;

      final response = await http
          .get(Uri.parse(urlString))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        await file.parent.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        Get.log('تم حفظ التلاوة الصوتية بنجاح للتأطير المحلي: $localPath');
      }
    } catch (e) {
      Get.log('خطأ أثناء حفظ التلاوة محلياً: $e');
    }
  }

  // Force playlist rebuild (e.g. after download/delete files)
  Future<void> forceRebuildPlaylist() async {
    final sId = playingSurahId.value;
    final sName = playingSurahName.value;
    final verses = List<dynamic>.from(activeVerses);
    if (sId != -1) {
      playingSurahId.value = -1; // Force rebuild
      await setupPlaylist(sId, sName, verses);
    }
  }
}

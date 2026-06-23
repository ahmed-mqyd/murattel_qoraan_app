import 'dart:io';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_session/audio_session.dart';

class AudioController extends GetxController {
  late final AudioPlayer audioPlayer;
  ConcatenatingAudioSource? _playlist;

  final isPlaying = false.obs;
  final isAudioLoading = false.obs;
  final playingAyahIndex = (-1).obs;
  final playingSurahId = (-1).obs;
  final playingSurahName = ''.obs;
  final activeVerses = <dynamic>[].obs;

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
      isAudioLoading.value = processingState == ProcessingState.loading ||
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
    final reciterKey = prefs.getString('settings_selected_reciter') ?? 'alafasy';
    switch (reciterKey) {
      case 'abdulbasit':
        return 'ar.abdulbasitmurattal';
      case 'almuaiqly':
        return 'ar.maheralmuaiqly';
      case 'ghamdi':
        return 'ar.saadghamidi';
      case 'faresabbad':
        return 'Fares_Abbad_64kbps';
      case 'yasser':
        return 'Yasser_Ad-Dussary_128kbps';
      case 'islamsobhi':
        return 'islam_sobhi';
      case 'ahmedshafei':
        return 'ahmed_alshafey';
      case 'alafasy':
      default:
        return 'ar.alafasy';
    }
  }

  String _getReciterNameArabic() {
    final prefs = Get.find<SharedPreferences>();
    final reciterKey = prefs.getString('settings_selected_reciter') ?? 'alafasy';
    switch (reciterKey) {
      case 'abdulbasit':
        return 'عبد الباسط عبد الصمد';
      case 'almuaiqly':
        return 'ماهر المعيقلي';
      case 'ghamdi':
        return 'سعد الغامدي';
      case 'faresabbad':
        return 'فارس عباد';
      case 'yasser':
        return 'ياسر الدوسري';
      case 'islamsobhi':
        return 'إسلام صبحي';
      case 'ahmedshafei':
        return 'أحمد الشافعي';
      case 'alafasy':
      default:
        return 'مشاري العفاسي';
    }
  }

  static String getAudioUrl(String reciterId, int surahId, int ayahNumberInSurah, int globalAyahNumber) {
    if (reciterId.contains('_')) {
      final String surahStr = surahId.toString().padLeft(3, '0');
      final String ayahStr = ayahNumberInSurah.toString().padLeft(3, '0');
      return 'https://everyayah.com/data/$reciterId/$surahStr$ayahStr.mp3';
    } else {
      return 'https://cdn.alquran.cloud/media/audio/ayah/$reciterId/$globalAyahNumber';
    }
  }

  static bool isFullSurahReciter(String reciterId) {
    return reciterId == 'islam_sobhi' || reciterId == 'ahmed_alshafey';
  }

  static String getSurahAudioUrl(String reciterId, int surahId) {
    final String surahStr = surahId.toString().padLeft(3, '0');
    if (reciterId == 'islam_sobhi') {
      return 'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem/$surahStr.mp3';
    } else if (reciterId == 'ahmed_alshafey') {
      return 'https://archive.org/download/ahmed_alshafey_202211/$surahStr.mp3';
    }
    return '';
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

  Future<void> setupPlaylist(int surahId, String surahName, List<dynamic> verses) async {
    // If it's already the same surah, don't rebuild it unless needed
    if (playingSurahId.value == surahId && activeVerses.length == verses.length) {
      return;
    }

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
        final urlString = AudioController.getAudioUrl(reciterId, surahId, ayahNumberInSurah, globalAyahNumber);
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

    if (!isFullSurah && (targetIndex < 0 || targetIndex >= activeVerses.length)) return;
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

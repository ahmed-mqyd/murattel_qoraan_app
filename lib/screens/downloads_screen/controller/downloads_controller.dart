import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/controllers/audio_controller.dart';
import '../../../core/models/reciter.dart';
import '../../../core/services/audio_download_service.dart';

class DownloadsController extends GetxController {
  /// القارئ الذي تُدار تحميلاته — يبدأ بالقارئ المختار في الإعدادات
  final Rx<Reciter> reciter = Reciters.byKey(Reciters.defaultKey).obs;

  final isLoadingStates = true.obs;

  /// حالة كل سورة (المفتاح رقم السورة)
  final RxMap<int, SurahDownloadState> surahStates =
      <int, SurahDownloadState>{}.obs;

  /// السورة الجاري تحميلها حالياً (-1 = لا يوجد) — تحميل واحد في كل مرة
  final downloadingSurahId = (-1).obs;
  final downloadProgress = 0.0.obs;

  /// المساحة المستخدمة لهذا القارئ بالبايت
  final usedBytes = 0.obs;

  bool _cancelRequested = false;

  @override
  void onInit() {
    super.onInit();
    final prefs = Get.find<SharedPreferences>();
    reciter.value = Reciters.selected(prefs);
    refreshStates();
  }

  @override
  void onClose() {
    // إيقاف أي تحميل جارٍ عند مغادرة الشاشة
    _cancelRequested = true;
    super.onClose();
  }

  /// تغيير القارئ المعروض داخل الشاشة (لا يغيّر قارئ التشغيل في الإعدادات)
  void switchReciter(Reciter newReciter) {
    if (downloadingSurahId.value != -1) {
      Get.snackbar(
        'مرتل القرآن',
        'انتظر انتهاء التحميل الجاري أو ألغِه قبل تغيير القارئ.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF003527),
        colorText: Colors.white,
      );
      return;
    }
    reciter.value = newReciter;
    refreshStates();
  }

  /// مسح واحد لمجلد القارئ لتحديد حالة كل السور والمساحة المستخدمة
  Future<void> refreshStates() async {
    isLoadingStates.value = true;
    try {
      final names = await AudioDownloadService.existingFileNames(reciter.value);
      final states = <int, SurahDownloadState>{};
      for (int id = 1; id <= 114; id++) {
        states[id] = AudioDownloadService.surahState(reciter.value, id, names);
      }
      surahStates.assignAll(states);
      usedBytes.value = await AudioDownloadService.usedBytes(reciter.value);
    } catch (e) {
      debugPrint('Failed to read download states: $e');
    } finally {
      isLoadingStates.value = false;
    }
  }

  Future<void> downloadSurah(int surahId) async {
    if (downloadingSurahId.value != -1) {
      Get.snackbar(
        'مرتل القرآن',
        'يوجد تحميل جارٍ بالفعل — انتظر اكتماله أو ألغِه أولاً.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF003527),
        colorText: Colors.white,
      );
      return;
    }

    _cancelRequested = false;
    downloadingSurahId.value = surahId;
    downloadProgress.value = 0.0;

    try {
      final completed = await AudioDownloadService.downloadSurah(
        reciter.value,
        surahId,
        onProgress: (p) => downloadProgress.value = p,
        isCancelled: () => _cancelRequested,
      );

      if (completed) {
        surahStates[surahId] = SurahDownloadState.downloaded;
      }
    } catch (e) {
      debugPrint('Surah download error: $e');
      Get.snackbar(
        'مرتل القرآن',
        'تعذر إكمال التحميل — تحقق من اتصال الإنترنت وحاول مجدداً.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      downloadingSurahId.value = -1;
      downloadProgress.value = 0.0;
      await refreshStates();
      // إعادة بناء قائمة التشغيل إن كانت السورة المحمّلة معروضة حالياً
      if (Get.isRegistered<AudioController>()) {
        await Get.find<AudioController>().forceRebuildPlaylist();
      }
    }
  }

  void cancelDownload() {
    _cancelRequested = true;
  }

  Future<void> deleteSurah(int surahId) async {
    try {
      await AudioDownloadService.deleteSurah(reciter.value, surahId);
      surahStates[surahId] = SurahDownloadState.notDownloaded;
      await refreshStates();
      if (Get.isRegistered<AudioController>()) {
        await Get.find<AudioController>().forceRebuildPlaylist();
      }
    } catch (e) {
      debugPrint('Surah delete error: $e');
    }
  }

  /// عدد السور المحمّلة بالكامل
  int get downloadedCount => surahStates.values
      .where((s) => s == SurahDownloadState.downloaded)
      .length;

  String formatBytes(int bytes) {
    if (bytes <= 0) return toArabicNumbers('0 م.ب');
    final mb = bytes / (1024 * 1024);
    if (mb < 1000) {
      return toArabicNumbers('${mb.toStringAsFixed(1)} م.ب');
    }
    return toArabicNumbers('${(mb / 1024).toStringAsFixed(2)} ج.ب');
  }

  String toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '٫'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }
}

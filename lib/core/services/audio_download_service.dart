import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../controllers/audio_controller.dart';
import '../models/reciter.dart';
import '../models/surah_meta.dart';

/// حالة تحميل سورة لقارئ معيّن
enum SurahDownloadState { notDownloaded, partial, downloaded }

/// خدمة تحميل تلاوات السور للاستماع دون اتصال.
///
/// تحفظ الملفات بنفس مسارات التشغيل الحالية حتى تلتقطها شاشة المصحف
/// و[AudioController] تلقائياً:
/// - قارئ آية-بآية: `documents/audio/{audioId}/{globalAyah}.mp3`
/// - قارئ سورة كاملة: `documents/audio/{audioId}/surah_{surahId}.mp3`
class AudioDownloadService {
  AudioDownloadService._();

  static Future<Directory> _reciterDir(Reciter reciter) async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory('${documents.path}/audio/${reciter.audioId}');
  }

  /// أسماء الملفات الموجودة حالياً لهذا القارئ — تُقرأ بمسح واحد للمجلد
  /// بدل آلاف استدعاءات exists() المنفصلة.
  static Future<Set<String>> existingFileNames(Reciter reciter) async {
    final dir = await _reciterDir(reciter);
    if (!await dir.exists()) return {};
    final names = <String>{};
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is File) {
        names.add(entity.uri.pathSegments.last);
      }
    }
    return names;
  }

  /// إجمالي المساحة المستخدمة لهذا القارئ بالبايت
  static Future<int> usedBytes(Reciter reciter) async {
    final dir = await _reciterDir(reciter);
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  /// حالة تحميل سورة بناءً على مسح الملفات المُمرَّر من [existingFileNames]
  static SurahDownloadState surahState(
    Reciter reciter,
    int surahId,
    Set<String> existingNames,
  ) {
    if (reciter.isFullSurah) {
      return existingNames.contains('surah_$surahId.mp3')
          ? SurahDownloadState.downloaded
          : SurahDownloadState.notDownloaded;
    }
    final meta = SurahMetas.byId(surahId);
    final start = SurahMetas.globalAyahStart(surahId);
    int found = 0;
    for (int g = start; g < start + meta.verseCount; g++) {
      if (existingNames.contains('$g.mp3')) found++;
    }
    if (found == 0) return SurahDownloadState.notDownloaded;
    if (found == meta.verseCount) return SurahDownloadState.downloaded;
    return SurahDownloadState.partial;
  }

  /// تحميل سورة كاملة، مع تقدم [onProgress] من 0 إلى 1،
  /// وإمكانية الإلغاء عبر [isCancelled]. ترجع true عند الاكتمال.
  static Future<bool> downloadSurah(
    Reciter reciter,
    int surahId, {
    required ValueChanged<double> onProgress,
    required bool Function() isCancelled,
  }) async {
    final dir = await _reciterDir(reciter);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    if (reciter.isFullSurah) {
      return _downloadFullSurahFile(
        reciter,
        surahId,
        dir,
        onProgress: onProgress,
        isCancelled: isCancelled,
      );
    }
    return _downloadAyahByAyah(
      reciter,
      surahId,
      dir,
      onProgress: onProgress,
      isCancelled: isCancelled,
    );
  }

  static Future<bool> _downloadFullSurahFile(
    Reciter reciter,
    int surahId,
    Directory dir, {
    required ValueChanged<double> onProgress,
    required bool Function() isCancelled,
  }) async {
    final file = File('${dir.path}/surah_$surahId.mp3');
    if (await file.exists()) {
      onProgress(1.0);
      return true;
    }

    final url = AudioController.getSurahAudioUrl(reciter.audioId, surahId);
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client
          .send(request)
          .timeout(const Duration(minutes: 10));
      if (response.statusCode != 200) {
        throw Exception('فشل التحميل: رمز الحالة ${response.statusCode}');
      }

      // الكتابة تدفقياً إلى ملف مؤقت ثم إعادة التسمية — حتى لا يبقى ملف
      // ناقص بمكان الملف النهائي لو انقطع التحميل في المنتصف
      final tmpFile = File('${file.path}.part');
      final sink = tmpFile.openWrite();
      final int? contentLength = response.contentLength;
      int downloaded = 0;
      try {
        await for (final chunk in response.stream) {
          if (isCancelled()) {
            await sink.close();
            await _safeDelete(tmpFile);
            return false;
          }
          sink.add(chunk);
          downloaded += chunk.length;
          if (contentLength != null && contentLength > 0) {
            onProgress(downloaded / contentLength);
          }
        }
        await sink.close();
        await tmpFile.rename(file.path);
        onProgress(1.0);
        return true;
      } catch (_) {
        await sink.close();
        await _safeDelete(tmpFile);
        rethrow;
      }
    } finally {
      client.close();
    }
  }

  static Future<bool> _downloadAyahByAyah(
    Reciter reciter,
    int surahId,
    Directory dir, {
    required ValueChanged<double> onProgress,
    required bool Function() isCancelled,
  }) async {
    final meta = SurahMetas.byId(surahId);
    final start = SurahMetas.globalAyahStart(surahId);

    for (int i = 0; i < meta.verseCount; i++) {
      if (isCancelled()) return false;

      final globalAyah = start + i;
      final ayahInSurah = i + 1;
      final file = File('${dir.path}/$globalAyah.mp3');

      if (!await file.exists()) {
        final url = AudioController.getAudioUrl(
          reciter.audioId,
          surahId,
          ayahInSurah,
          globalAyah,
        );
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 30));
        if (response.statusCode != 200) {
          throw Exception(
            'فشل تحميل الآية $ayahInSurah: رمز الحالة ${response.statusCode}',
          );
        }
        await file.writeAsBytes(response.bodyBytes);
      }

      onProgress((i + 1) / meta.verseCount);
    }
    return true;
  }

  /// حذف ملفات سورة محمّلة لهذا القارئ، وترجع عدد الملفات المحذوفة
  static Future<int> deleteSurah(Reciter reciter, int surahId) async {
    final dir = await _reciterDir(reciter);
    if (!await dir.exists()) return 0;

    int deleted = 0;
    if (reciter.isFullSurah) {
      final file = File('${dir.path}/surah_$surahId.mp3');
      if (await file.exists()) {
        await file.delete();
        deleted++;
      }
    } else {
      final meta = SurahMetas.byId(surahId);
      final start = SurahMetas.globalAyahStart(surahId);
      for (int g = start; g < start + meta.verseCount; g++) {
        final file = File('${dir.path}/$g.mp3');
        if (await file.exists()) {
          await file.delete();
          deleted++;
        }
      }
    }
    return deleted;
  }

  static Future<void> _safeDelete(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}

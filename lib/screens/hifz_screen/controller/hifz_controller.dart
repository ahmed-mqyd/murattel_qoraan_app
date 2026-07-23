import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/models/surah_meta.dart';
import '../../home_screen/controller/home_controller.dart';
import '../../suluk_screen/controller/suluk_controller.dart';

class HifzController extends GetxController {
  // النصائح الذكية تمر عبر خادمك الوسيط الذي يحمل مفتاح Gemini
  // (انظر server/hifz_tips_proxy.php وخطوات التشغيل بأعلاه) —
  // لا يوجد أي مفتاح داخل التطبيق، والتقييم الأساسي محلي بالكامل
  // ولا يتأثر إذا كان الرابط فارغاً أو الخادم غير متاح.
  static const String _tipsProxyUrl =
      ''; // مثال: 'https://your-domain.com/api/hifz_tips_proxy.php'
  static const String _tipsProxyToken = ''; // نفس قيمة APP_TOKEN في ملف الخادم

  // حالات الشاشة
  final RxBool isLoading = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool hasResult = false.obs;

  final RxDouble score = 0.0.obs;
  final RxString surahName = 'سورة الفَاتِحَة'.obs;
  final RxString ayahRange = '١ - ٧'.obs;
  final RxList<EvaluationWord> evaluationWords = <EvaluationWord>[].obs;
  final RxList<String> tips = <String>[].obs;
  final RxString transcription = ''.obs;

  // التعرف اللحظي على الكلام (Speech to Text) — المستهلك الوحيد للميكروفون
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxString liveText = ''.obs;
  final RxBool isSpeechAvailable = false.obs;
  final RxBool speechInitFailed = false.obs;
  String? _arabicLocaleId;

  // تجميع النص عبر جلسات الاستماع المتعاقبة: جلسة التعرف على أندرويد تنتهي
  // تلقائياً عند أول وقفة، فنعيد تشغيلها ونجمع النص المؤكد أولاً بأول.
  String _finalizedText = '';
  String _currentPartial = '';
  bool _keepListening = false;
  bool _restartScheduled = false;

  // رقم جلسة التقييم — يُلغي نتائج المعالجة المتأخرة بعد ضغط "حاول مرة أخرى"
  int _evalSession = 0;

  // تحديد الآيات للتسميع
  final RxInt startAyah = 1.obs;
  final RxInt endAyah = 7.obs;
  final RxInt totalVerses = 7.obs;

  // قائمة السور — مشتقة من السجل المركزي في core/models/surah_meta.dart
  List<Map<String, dynamic>> get rawSurahs => SurahMetas.all
      .map((s) => {'id': s.id, 'name': s.arabicName, 'verses': s.verseCount})
      .toList();

  List<String> get availableSurahs =>
      rawSurahs.map((e) => 'سورة ${e['name']}').toList();

  @override
  void onInit() {
    super.onInit();
    // Default config initialization for Al-Fatiha
    totalVerses.value = 7;
    startAyah.value = 1;
    endAyah.value = 7;
    updateRange();
    initSpeech();
  }

  @override
  void onClose() {
    _keepListening = false;
    _speech.stop();
    super.onClose();
  }

  Future<void> initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      isSpeechAvailable.value = available;
      speechInitFailed.value = !available;
      if (available) {
        // اختيار أول لهجة عربية متاحة على الجهاز، وإلا لغة النظام الافتراضية
        final locales = await _speech.locales();
        for (final locale in locales) {
          if (locale.localeId.toLowerCase().startsWith('ar')) {
            _arabicLocaleId = locale.localeId;
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Speech init failed: $e');
      isSpeechAvailable.value = false;
      speechInitFailed.value = true;
    }
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      _scheduleListenRestart();
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    debugPrint('Speech error: ${error.errorMsg}');
    // أخطاء مثل error_speech_timeout تنهي الجلسة — نعيد تشغيلها ما دام التسميع مستمراً
    _scheduleListenRestart();
  }

  void _scheduleListenRestart() {
    if (!_keepListening || !isRecording.value || _restartScheduled) return;
    _restartScheduled = true;
    Future.delayed(const Duration(milliseconds: 350), () async {
      _restartScheduled = false;
      if (!_keepListening || !isRecording.value) return;
      _commitPartial();
      try {
        await _listenOnce();
      } catch (e) {
        debugPrint('Listen restart failed: $e');
      }
    });
  }

  Future<void> _listenOnce() {
    return _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: stt.SpeechListenOptions(
        localeId: _arabicLocaleId,
        partialResults: true,
        cancelOnError: false,
        // مهلات متسامحة مع وقفات التنفس والتدبر أثناء الترتيل؛ وإن أنهى
        // النظام الجلسة قبلها فآلية إعادة التشغيل أعلاه تتكفل بالاستمرار
        listenFor: const Duration(minutes: 10),
        pauseFor: const Duration(seconds: 60),
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (result.finalResult) {
      if (words.isNotEmpty) {
        _finalizedText = _finalizedText.isEmpty
            ? words
            : '$_finalizedText $words';
      }
      _currentPartial = '';
    } else {
      _currentPartial = words;
    }
    _updateLiveText();
  }

  void _commitPartial() {
    if (_currentPartial.trim().isNotEmpty) {
      _finalizedText = _finalizedText.isEmpty
          ? _currentPartial.trim()
          : '$_finalizedText ${_currentPartial.trim()}';
      _currentPartial = '';
      _updateLiveText();
    }
  }

  void _updateLiveText() {
    if (_currentPartial.isEmpty) {
      liveText.value = _finalizedText;
    } else if (_finalizedText.isEmpty) {
      liveText.value = _currentPartial;
    } else {
      liveText.value = '$_finalizedText $_currentPartial';
    }
  }

  void reset() {
    _evalSession++;
    if (isRecording.value) {
      _keepListening = false;
      _speech.stop();
    }
    hasResult.value = false;
    isRecording.value = false;
    isLoading.value = false;
    score.value = 0.0;
    transcription.value = '';
    liveText.value = '';
    _finalizedText = '';
    _currentPartial = '';
    evaluationWords.clear();
    tips.clear();
  }

  void selectSurah(String name) {
    final searchName = _stripTashkeel(name.replaceFirst('سورة ', '').trim());
    final meta = rawSurahs.firstWhere(
      (element) => _stripTashkeel(element['name'] as String) == searchName,
    );
    surahName.value = name;
    totalVerses.value = meta['verses'] as int;
    startAyah.value = 1;
    endAyah.value = totalVerses.value > 5 ? 5 : totalVerses.value;
    updateRange();
    reset();
  }

  void updateRange() {
    ayahRange.value = _toArabicRange('${startAyah.value}-${endAyah.value}');
  }

  void nextAyahRange() {
    if (endAyah.value >= totalVerses.value) {
      Get.snackbar(
        'مرتل القرآن',
        'لقد وصلت لنهاية السورة',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF003527),
        colorText: Colors.white,
      );
      return;
    }

    final currentRangeSize = endAyah.value - startAyah.value + 1;
    final int nextStart = endAyah.value + 1;
    int nextEnd = nextStart + currentRangeSize - 1;
    if (nextEnd > totalVerses.value) {
      nextEnd = totalVerses.value;
    }

    startAyah.value = nextStart;
    endAyah.value = nextEnd;
    updateRange();
    reset();
  }

  String _toArabicRange(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '-'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  // بدء التسميع — التعرف على الكلام هو المستهلك الوحيد للميكروفون
  // (تشغيل مسجّل ملفات بالتوازي معه يجعل أحدهما يستلم صمتاً على أندرويد 10+)
  Future<void> startRecording() async {
    if (isRecording.value) return;
    try {
      if (!isSpeechAvailable.value) {
        await initSpeech();
      }
      if (!isSpeechAvailable.value) {
        Get.snackbar(
          'صلاحية الميكروفون',
          'التعرف على الكلام غير متاح. يرجى منح صلاحية الميكروفون من إعدادات الهاتف والتأكد من تفعيل خدمات التعرف على الكلام.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFBA1A1A),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      _finalizedText = '';
      _currentPartial = '';
      liveText.value = '';
      hasResult.value = false;
      _keepListening = true;
      isRecording.value = true;
      await _listenOnce();
    } catch (e) {
      _keepListening = false;
      isRecording.value = false;
      Get.snackbar('خطأ', 'فشل في بدء التسميع: $e');
    }
  }

  // إيقاف التسميع وبدء التقييم
  Future<void> stopRecording() async {
    if (!isRecording.value) return;
    _keepListening = false;
    isRecording.value = false;
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Speech stop error: $e');
    }

    // مهلة قصيرة حتى يصل آخر نص مؤكد من محرك التعرف بعد الإيقاف
    await Future.delayed(const Duration(milliseconds: 700));
    _commitPartial();

    final recited = _finalizedText.trim();
    if (recited.isEmpty) {
      Get.snackbar(
        'مرتل القرآن',
        'لم يتم التقاط أي تلاوة — رتّل بصوت واضح قريباً من الميكروفون ثم أعد المحاولة.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    isLoading.value = true;
    final int session = ++_evalSession;
    try {
      final targetWords = await _fetchTargetDisplayWords();
      final evaluation = _evaluateLocally(targetWords, recited);
      if (session != _evalSession) return;

      score.value = evaluation.score;
      evaluationWords.value = evaluation.words;
      transcription.value = recited;
      tips.value = _buildLocalTips(evaluation);
      hasResult.value = true;

      // Track the recited verses if the score is passing (>= 75%)
      if (score.value >= 75.0) {
        _trackRecitedVerses();
        _saveHifzSessionStats(score.value);
      }

      // تحسين النصائح عبر Gemini في الخلفية — النتيجة معروضة بالفعل،
      // وإن فشل الاتصال تبقى النصائح المحلية كما هي
      _refineTipsWithGemini(
        targetText: targetWords.join(' '),
        recitedText: recited,
        wrongWords: evaluation.words
            .where((w) => !w.isCorrect)
            .map((w) => w.text)
            .toList(),
        session: session,
      );
    } catch (e) {
      debugPrint('Hifz evaluation error: $e');
      Get.snackbar(
        'مرتل القرآن',
        'تعذر تحميل نص الآيات للمقارنة — تحقق من اتصال الإنترنت ثم أعد المحاولة.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  int _currentSurahId() {
    final searchName = _stripTashkeel(
      surahName.value.replaceFirst('سورة ', '').trim(),
    );
    final meta = rawSurahs.firstWhere(
      (element) => _stripTashkeel(element['name'] as String) == searchName,
    );
    return meta['id'] as int;
  }

  /// جلب كلمات المقطع المستهدف (نص مبسط بالتشكيل) مع كاش محلي للسورة كاملة
  /// حتى يعمل التسميع المتكرر بدون إنترنت بعد أول تحميل.
  Future<List<String>> _fetchTargetDisplayWords() async {
    final surahId = _currentSurahId();
    final prefs = Get.find<SharedPreferences>();
    final cacheKey = 'hifz_surah_text_simple_$surahId';

    List<String>? ayahTexts;
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        ayahTexts = List<String>.from(jsonDecode(cached));
      } catch (_) {
        ayahTexts = null;
      }
    }

    if (ayahTexts == null) {
      final url = Uri.parse(
        'https://api.alquran.cloud/v1/surah/$surahId/quran-simple',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw Exception('Failed to load Quranic text: ${response.statusCode}');
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final ayahs = data['data']['ayahs'] as List;
      ayahTexts = ayahs.map((a) => a['text'] as String).toList();

      // الـ API يدمج البسملة داخل نص الآية الأولى لكل سورة (عدا الفاتحة حيث
      // هي الآية الأولى نفسها، والتوبة بلا بسملة) — نحذفها كي لا تُحسب خطأً
      if (surahId != 1 && ayahTexts.isNotEmpty) {
        ayahTexts[0] = _stripLeadingBasmala(ayahTexts[0]);
      }
      await prefs.setString(cacheKey, jsonEncode(ayahTexts));
    }

    final int start = startAyah.value.clamp(1, ayahTexts.length).toInt();
    final int end = endAyah.value.clamp(start, ayahTexts.length).toInt();
    final slice = ayahTexts.sublist(start - 1, end);
    return slice
        .join(' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
  }

  String _stripLeadingBasmala(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length < 5) return text;
    final head = words.take(4).map(_normalizeForMatch).join(' ');
    if (head == 'بسم الله الرحمن الرحيم') {
      return words.sublist(4).join(' ');
    }
    return text;
  }

  /// تطبيع الكلمة للمقارنة: إزالة التشكيل وعلامات الضبط وتوحيد صور الحروف
  /// التي يكتبها محرك التعرف بشكل مختلف عن الرسم القرآني.
  String _normalizeForMatch(String input) {
    var s = input;
    s = s.replaceAll(
      RegExp(
        r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF\u0640]',
      ),
      '',
    );
    s = s.replaceAll(RegExp('[أإآٱ]'), 'ا');
    s = s.replaceAll('ة', 'ه');
    s = s.replaceAll('ى', 'ي');
    s = s.replaceAll('ؤ', 'و');
    s = s.replaceAll('ئ', 'ي');
    s = s.replaceAll('ء', '');
    s = s.replaceAll(RegExp(r'[^\u0621-\u064A]'), '');
    return s;
  }

  double _similarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    if ((a.length - b.length).abs() > 3) return 0.0;
    final dist = _levenshtein(a, b);
    final maxLen = math.max(a.length, b.length);
    return 1.0 - dist / maxLen;
  }

  int _levenshtein(String a, String b) {
    final m = a.length, n = b.length;
    var prev = List<int>.generate(n + 1, (j) => j);
    var curr = List<int>.filled(n + 1, 0);
    for (int i = 1; i <= m; i++) {
      curr[0] = i;
      for (int j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = math.min(
          math.min(curr[j - 1] + 1, prev[j] + 1),
          prev[j - 1] + cost,
        );
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[n];
  }

  List<String> _stripPrefixIfMatch(List<String> words, List<String> prefix) {
    if (words.length < prefix.length) return words;
    for (int i = 0; i < prefix.length; i++) {
      if (_similarity(words[i], prefix[i]) < 0.75) return words;
    }
    return words.sublist(prefix.length);
  }

  /// التقييم المحلي الحتمي: محاذاة كلمات المقطع المستهدف مع الكلمات المنطوقة
  /// (برمجة ديناميكية بأسلوب المسافة التحريرية) وتحديد صحة كل كلمة.
  _LocalEvaluation _evaluateLocally(
    List<String> displayWords,
    String recitedText,
  ) {
    const double threshold = 0.75;
    const double delCost = 1.0; // كلمة مستهدفة فاتت القارئ
    const double insCost = 0.8; // كلمة زائدة نطقها القارئ

    final targetNorm = displayWords.map(_normalizeForMatch).toList();
    var spokenNorm = recitedText
        .split(RegExp(r'\s+'))
        .map(_normalizeForMatch)
        .where((w) => w.isNotEmpty)
        .toList();

    // الاستعاذة لا تُحسب على القارئ، والبسملة كذلك إن لم تكن ضمن المقطع نفسه
    spokenNorm = _stripPrefixIfMatch(spokenNorm, const [
      'اعوذ',
      'بالله',
      'من',
      'الشيطان',
      'الرجيم',
    ]);
    const basmala = ['بسم', 'الله', 'الرحمن', 'الرحيم'];
    final targetStartsWithBasmala =
        targetNorm.length >= 4 &&
        targetNorm.sublist(0, 4).join(' ') == basmala.join(' ');
    if (!targetStartsWithBasmala) {
      spokenNorm = _stripPrefixIfMatch(spokenNorm, basmala);
    }

    final n = targetNorm.length;
    final m = spokenNorm.length;

    final sim = List.generate(
      n,
      (i) => List<double>.generate(
        m,
        (j) => _similarity(targetNorm[i], spokenNorm[j]),
      ),
    );

    final dp = List.generate(n + 1, (_) => List<double>.filled(m + 1, 0));
    for (int i = 1; i <= n; i++) {
      dp[i][0] = i * delCost;
    }
    for (int j = 1; j <= m; j++) {
      dp[0][j] = j * insCost;
    }
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final s = sim[i - 1][j - 1];
        // المطابقة الجيدة شبه مجانية، والمحاولة الخاطئة أرخص من (حذف + زيادة)
        // حتى تنحاز المحاذاة لاعتبارها كلمة منطوقة خاطئة لا كلمتين منفصلتين
        final double subCost = s >= threshold ? (1.0 - s) * 0.5 : 1.5;
        dp[i][j] = math.min(
          dp[i - 1][j - 1] + subCost,
          math.min(dp[i - 1][j] + delCost, dp[i][j - 1] + insCost),
        );
      }
    }

    // التتبع العكسي لتحديد الكلمات المستهدفة التي قوبلت بنطق صحيح
    final matched = List<bool>.filled(n, false);
    int i = n, j = m;
    while (i > 0 && j > 0) {
      final s = sim[i - 1][j - 1];
      final double subCost = s >= threshold ? (1.0 - s) * 0.5 : 1.5;
      if ((dp[i][j] - (dp[i - 1][j - 1] + subCost)).abs() < 1e-9) {
        matched[i - 1] = s >= threshold;
        i--;
        j--;
      } else if ((dp[i][j] - (dp[i - 1][j] + delCost)).abs() < 1e-9) {
        i--;
      } else {
        j--;
      }
    }

    final correct = matched.where((x) => x).length;
    final double computedScore = n == 0
        ? 0.0
        : (100.0 * correct / n).clamp(0.0, 100.0).toDouble();

    int trailingMissed = 0;
    for (int k = n - 1; k >= 0 && !matched[k]; k--) {
      trailingMissed++;
    }

    return _LocalEvaluation(
      score: computedScore.roundToDouble(),
      words: [
        for (int k = 0; k < n; k++)
          EvaluationWord(text: displayWords[k], isCorrect: matched[k]),
      ],
      trailingMissed: trailingMissed,
    );
  }

  List<String> _buildLocalTips(_LocalEvaluation evaluation) {
    final wrong = evaluation.words
        .where((w) => !w.isCorrect)
        .map((w) => w.text)
        .toList();
    if (wrong.isEmpty) {
      return [
        'ما شاء الله، تسميع متقن بدون أخطاء! ثبّت حفظك بإعادة التسميع غداً.',
      ];
    }
    final localTips = <String>[
      'راجع نطق الكلمات المظللة بالأحمر: ${wrong.take(6).join('، ')}',
    ];
    if (evaluation.trailingMissed >= 3) {
      localTips.add(
        'يبدو أنك توقفت قبل إتمام المقطع — راجع الآيات الأخيرة من المصحف ثم أعد التسميع.',
      );
    }
    if (evaluation.score < 60) {
      localTips.add(
        'اقرأ المقطع من المصحف قراءة متأنية عدة مرات قبل إعادة التسميع.',
      );
    }
    localTips.add(
      'استمع لتلاوة قارئك المفضل لهذا المقطع ثم سمّع مرة أخرى لتثبيت الحفظ.',
    );
    return localTips;
  }

  /// نصائح مخصصة عبر الخادم الوسيط (الذي يحمل مفتاح Gemini على استضافتك).
  /// تُستبدل النصائح المحلية فقط عند نجاح الطلب وبقاء نفس جلسة التقييم.
  ///
  /// طبقات توفير الحصة قبل أي نداء شبكة:
  /// 1. تخطٍّ كامل عند الإتقان (لا أخطاء) — النصيحة المحلية كافية
  /// 2. كاش محلي: إعادة تسميع نفس المقطع بنفس الأخطاء (طبيعة الحفظ تكرار)
  ///    تُجاب من الجهاز مباشرة بلا أي طلب
  Future<void> _refineTipsWithGemini({
    required String targetText,
    required String recitedText,
    required List<String> wrongWords,
    required int session,
  }) async {
    // الخادم الوسيط غير مُفعَّل — نكتفي بالنصائح المحلية بلا أي نداء
    if (_tipsProxyUrl.isEmpty) return;

    // تسميع متقن — لا حاجة لاستهلاك الحصة، النصيحة المحلية مناسبة تماماً
    if (wrongWords.isEmpty) return;

    try {
      final prefs = Get.find<SharedPreferences>();

      // كاش محلي بمفتاح ثابت من المقطع والأخطاء
      final cacheKey =
          'hifz_tips_cache_${_stableHash('$targetText|${wrongWords.join(',')}')}';
      final cachedTips = prefs.getStringList(cacheKey);
      if (cachedTips != null && cachedTips.isNotEmpty) {
        if (session == _evalSession) tips.value = cachedTips;
        return;
      }

      // معرّف جهاز ثابت لعدّاد الاستهلاك اليومي على الخادم
      var deviceId = prefs.getString('hifz_device_id');
      if (deviceId == null) {
        deviceId =
            '${DateTime.now().millisecondsSinceEpoch}${math.Random().nextInt(999999)}';
        await prefs.setString('hifz_device_id', deviceId);
      }

      final response = await http
          .post(
            Uri.parse(_tipsProxyUrl),
            headers: {
              'Content-Type': 'application/json',
              'X-App-Token': _tipsProxyToken,
            },
            body: jsonEncode({
              'target': targetText,
              'recited': recitedText,
              'wrong': wrongWords,
              'device': deviceId,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        debugPrint('AI tips skipped: status ${response.statusCode}');
        return;
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final refined = data['tips'] != null
          ? List<String>.from(data['tips'])
          : <String>[];
      if (refined.isNotEmpty) {
        await prefs.setStringList(cacheKey, refined);
        if (session == _evalSession) {
          tips.value = refined;
        }
      }
    } catch (e) {
      // فشل النصائح الذكية لا يؤثر على النتيجة — تبقى النصائح المحلية
      debugPrint('AI tips skipped: $e');
    }
  }

  /// بصمة نصية ثابتة عبر التشغيلات (FNV-1a) — String.hashCode في Dart
  /// غير مضمون الثبات بين المنصات فلا يصلح مفتاح كاش دائم
  String _stableHash(String input) {
    int hash = 0x811C9DC5;
    for (final code in input.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  void _trackRecitedVerses() {
    try {
      final prefs = Get.find<SharedPreferences>();
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final readKey = 'verses_read_$todayStr';
      final readListKey = 'unique_verses_read_list_$todayStr';

      final List<String> readList = prefs.getStringList(readListKey) ?? [];

      final surahId = _currentSurahId();

      bool addedAny = false;
      for (int i = startAyah.value; i <= endAyah.value; i++) {
        final String ayahIdStr = '$surahId-$i';
        if (!readList.contains(ayahIdStr)) {
          readList.add(ayahIdStr);
          addedAny = true;
        }
      }

      if (addedAny) {
        prefs.setStringList(readListKey, readList);
        prefs.setInt(readKey, readList.length);

        // Also update total verses count
        final totalKey = 'total_verses_read';
        final totalRead = prefs.getInt(totalKey) ?? 0;
        prefs.setInt(
          totalKey,
          totalRead + (endAyah.value - startAyah.value + 1),
        );

        // Update streak logic
        _updateStreak(prefs, todayStr);

        // Refresh Home Controller and Suluk Controller if registered
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().refreshData();
        }
        if (Get.isRegistered<SulukController>()) {
          Get.find<SulukController>().loadStats();
        }
      }
    } catch (e) {
      debugPrint('Error tracking recited verses: $e');
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

  void _saveHifzSessionStats(double sessionScore) {
    try {
      final prefs = Get.find<SharedPreferences>();
      // زيادة عداد الجلسات
      final sessions = (prefs.getInt('hifz_sessions_count') ?? 0) + 1;
      prefs.setInt('hifz_sessions_count', sessions);
      // تحديث أعلى نتيجة
      final best = prefs.getDouble('hifz_best_score') ?? 0.0;
      if (sessionScore > best) {
        prefs.setDouble('hifz_best_score', sessionScore);
      }
      // تحديث SulukController وفحص الأوسمة
      if (Get.isRegistered<SulukController>()) {
        final suluk = Get.find<SulukController>();
        suluk.loadStats();
        suluk.checkAchievementsPublic();
      }
    } catch (e) {
      debugPrint('Error saving hifz session stats: $e');
    }
  }

  String _stripTashkeel(String input) {
    return input.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  }
}

class _LocalEvaluation {
  final double score;
  final List<EvaluationWord> words;
  final int trailingMissed;

  _LocalEvaluation({
    required this.score,
    required this.words,
    required this.trailingMissed,
  });
}

class EvaluationWord {
  final String text;
  final bool isCorrect;

  EvaluationWord({required this.text, required this.isCorrect});
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../home_screen/controller/home_controller.dart';
import '../../suluk_screen/controller/suluk_controller.dart';

class HifzController extends GetxController {
  // مفتاح Gemini AI المقدم
  final String _apiKey = 'AQ.Ab8RN6JvhKgZRgVaxgL_B7r00prHb2JcqzPUgUI7_IKkEnDaMw'; 
  final String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  final AudioRecorder _audioRecorder = AudioRecorder();
  
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
  
  // التعرف اللحظي على الكلام (Speech to Text)
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxString liveText = ''.obs;
  final RxBool isSpeechAvailable = false.obs;

  // تحديد الآيات للتسميع
  final RxInt startAyah = 1.obs;
  final RxInt endAyah = 7.obs;
  final RxInt totalVerses = 7.obs;

  // قائمة السور المتاحة في المصحف الشريف ومعلوماتها
  final List<Map<String, dynamic>> rawSurahs = const [
    {'id': 1, 'name': 'الفَاتِحَة', 'verses': 7},
    {'id': 2, 'name': 'البَقَرَة', 'verses': 286},
    {'id': 3, 'name': 'آل عِمرَان', 'verses': 200},
    {'id': 4, 'name': 'النِّسَاء', 'verses': 176},
    {'id': 5, 'name': 'المَائِدَة', 'verses': 120},
    {'id': 6, 'name': 'الأنعَام', 'verses': 165},
    {'id': 7, 'name': 'الأعرَاف', 'verses': 206},
    {'id': 8, 'name': 'الأنفَال', 'verses': 75},
    {'id': 9, 'name': 'التَّوبَة', 'verses': 129},
    {'id': 10, 'name': 'يُونُس', 'verses': 109},
    {'id': 11, 'name': 'هُود', 'verses': 123},
    {'id': 12, 'name': 'يُوسُف', 'verses': 111},
    {'id': 13, 'name': 'الرَّعْد', 'verses': 43},
    {'id': 14, 'name': 'إِبْرَاهِيم', 'verses': 52},
    {'id': 15, 'name': 'الحِجْر', 'verses': 99},
    {'id': 16, 'name': 'النَّحْل', 'verses': 128},
    {'id': 17, 'name': 'الإِسْرَاء', 'verses': 111},
    {'id': 18, 'name': 'الكَهْف', 'verses': 110},
    {'id': 19, 'name': 'مَرْيَم', 'verses': 98},
    {'id': 20, 'name': 'طه', 'verses': 135},
    {'id': 21, 'name': 'الأَنْبِيَاء', 'verses': 112},
    {'id': 22, 'name': 'الحَجّ', 'verses': 78},
    {'id': 23, 'name': 'المُؤْمِنُون', 'verses': 118},
    {'id': 24, 'name': 'النُّور', 'verses': 64},
    {'id': 25, 'name': 'الفُرْقَان', 'verses': 77},
    {'id': 26, 'name': 'الشُّعَرَاء', 'verses': 227},
    {'id': 27, 'name': 'النَّمْل', 'verses': 93},
    {'id': 28, 'name': 'القَصَص', 'verses': 88},
    {'id': 29, 'name': 'العَنْكَبُوت', 'verses': 69},
    {'id': 30, 'name': 'الرُّوم', 'verses': 60},
    {'id': 31, 'name': 'لُقْمَان', 'verses': 34},
    {'id': 32, 'name': 'السَّجْدَة', 'verses': 30},
    {'id': 33, 'name': 'الأَحْزَاب', 'verses': 73},
    {'id': 34, 'name': 'سَبَأ', 'verses': 54},
    {'id': 35, 'name': 'فَاطِر', 'verses': 45},
    {'id': 36, 'name': 'يس', 'verses': 83},
    {'id': 37, 'name': 'الصَّافَّات', 'verses': 182},
    {'id': 38, 'name': 'ص', 'verses': 88},
    {'id': 39, 'name': 'الزُّمَر', 'verses': 75},
    {'id': 40, 'name': 'غَافِر', 'verses': 85},
    {'id': 41, 'name': 'فُصِّلَت', 'verses': 54},
    {'id': 42, 'name': 'الشُّورَى', 'verses': 53},
    {'id': 43, 'name': 'الزُّخْرُف', 'verses': 89},
    {'id': 44, 'name': 'الدُّخَان', 'verses': 59},
    {'id': 45, 'name': 'الجَاثِيَة', 'verses': 37},
    {'id': 46, 'name': 'الأَحْقَاف', 'verses': 35},
    {'id': 47, 'name': 'مُحَمَّد', 'verses': 38},
    {'id': 48, 'name': 'الفَتْح', 'verses': 29},
    {'id': 49, 'name': 'الحُجُرَات', 'verses': 18},
    {'id': 50, 'name': 'ق', 'verses': 45},
    {'id': 51, 'name': 'الذَّارِيَات', 'verses': 60},
    {'id': 52, 'name': 'الطُّور', 'verses': 49},
    {'id': 53, 'name': 'النَّجْم', 'verses': 62},
    {'id': 54, 'name': 'القَمَر', 'verses': 55},
    {'id': 55, 'name': 'الرَّحْمَن', 'verses': 78},
    {'id': 56, 'name': 'الوَاقِعَة', 'verses': 96},
    {'id': 57, 'name': 'الحَدِيد', 'verses': 29},
    {'id': 58, 'name': 'المُجَادِلَة', 'verses': 22},
    {'id': 59, 'name': 'الحَشْر', 'verses': 24},
    {'id': 60, 'name': 'المُمْتَحَنَة', 'verses': 13},
    {'id': 61, 'name': 'الصَّفّ', 'verses': 14},
    {'id': 62, 'name': 'الجُمُعَة', 'verses': 11},
    {'id': 63, 'name': 'المُنَافِقُون', 'verses': 11},
    {'id': 64, 'name': 'التَّغَابُن', 'verses': 18},
    {'id': 65, 'name': 'الطَّلَاق', 'verses': 12},
    {'id': 66, 'name': 'التَّحْرِيم', 'verses': 12},
    {'id': 67, 'name': 'المُلْك', 'verses': 30},
    {'id': 68, 'name': 'القَلَم', 'verses': 52},
    {'id': 69, 'name': 'الحَاقَّة', 'verses': 52},
    {'id': 70, 'name': 'المَعَارِج', 'verses': 44},
    {'id': 71, 'name': 'نُوح', 'verses': 28},
    {'id': 72, 'name': 'الجِنّ', 'verses': 28},
    {'id': 73, 'name': 'المُزَّمِّل', 'verses': 20},
    {'id': 74, 'name': 'المُدَّثِّر', 'verses': 56},
    {'id': 75, 'name': 'القِيَامَة', 'verses': 40},
    {'id': 76, 'name': 'الإِنْسَان', 'verses': 31},
    {'id': 77, 'name': 'المُرْسَلَات', 'verses': 50},
    {'id': 78, 'name': 'النَّبَأ', 'verses': 40},
    {'id': 79, 'name': 'النَّازِعَات', 'verses': 46},
    {'id': 80, 'name': 'عَبَس', 'verses': 42},
    {'id': 81, 'name': 'التَّكْوِير', 'verses': 29},
    {'id': 82, 'name': 'الانْفِطَار', 'verses': 19},
    {'id': 83, 'name': 'المُطَفِّفِين', 'verses': 36},
    {'id': 84, 'name': 'الانْشِقَاق', 'verses': 25},
    {'id': 85, 'name': 'البُرُوج', 'verses': 22},
    {'id': 86, 'name': 'الطَّارِق', 'verses': 17},
    {'id': 87, 'name': 'الأَعْلَى', 'verses': 19},
    {'id': 88, 'name': 'الغَاشِيَة', 'verses': 26},
    {'id': 89, 'name': 'الفَجْر', 'verses': 30},
    {'id': 90, 'name': 'البَلَد', 'verses': 20},
    {'id': 91, 'name': 'الشَّمْس', 'verses': 15},
    {'id': 92, 'name': 'اللَّيْل', 'verses': 21},
    {'id': 93, 'name': 'الضُّحَى', 'verses': 11},
    {'id': 94, 'name': 'الشَّرْح', 'verses': 8},
    {'id': 95, 'name': 'التِّين', 'verses': 8},
    {'id': 96, 'name': 'العَلَق', 'verses': 19},
    {'id': 97, 'name': 'القَدْر', 'verses': 5},
    {'id': 98, 'name': 'البَيِّنَة', 'verses': 8},
    {'id': 99, 'name': 'الزَّلْزَلَة', 'verses': 8},
    {'id': 100, 'name': 'العَادِيَات', 'verses': 11},
    {'id': 101, 'name': 'القَارِعَة', 'verses': 11},
    {'id': 102, 'name': 'التَّكَاثُر', 'verses': 8},
    {'id': 103, 'name': 'العَصْر', 'verses': 3},
    {'id': 104, 'name': 'الهُمَزَة', 'verses': 9},
    {'id': 105, 'name': 'الفِيل', 'verses': 5},
    {'id': 106, 'name': 'قُرَيْش', 'verses': 4},
    {'id': 107, 'name': 'المَاعُون', 'verses': 7},
    {'id': 108, 'name': 'الكَوْثَر', 'verses': 3},
    {'id': 109, 'name': 'الكَافِرُون', 'verses': 6},
    {'id': 110, 'name': 'النَّصْر', 'verses': 3},
    {'id': 111, 'name': 'المَسَد', 'verses': 5},
    {'id': 112, 'name': 'الإِخْلَاص', 'verses': 4},
    {'id': 113, 'name': 'الفَلَق', 'verses': 5},
    {'id': 114, 'name': 'النَّاس', 'verses': 6},
  ];

  List<String> get availableSurahs => rawSurahs.map((e) => 'سورة ${e['name']}').toList();

  String? _audioPath;

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

  Future<void> initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
      isSpeechAvailable.value = available;
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }
  }

  @override
  void onClose() {
    _audioRecorder.dispose();
    super.onClose();
  }

  void reset() {
    hasResult.value = false;
    isRecording.value = false;
    isLoading.value = false;
    score.value = 0.0;
    transcription.value = '';
    liveText.value = '';
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

  // بدء التسجيل
  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _audioPath = '${directory.path}/recitation_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        const config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        );
        await _audioRecorder.start(config, path: _audioPath!);
        isRecording.value = true;
        hasResult.value = false;
        liveText.value = '';

        // Start live transcription
        if (isSpeechAvailable.value) {
          await _speech.listen(
            onResult: (result) {
              liveText.value = result.recognizedWords;
            },
            listenOptions: stt.SpeechListenOptions(
              localeId: 'ar-EG', // Arabic Egyptian/Saudi/General
              listenFor: const Duration(minutes: 5),
              pauseFor: const Duration(seconds: 10),
              cancelOnError: false,
              partialResults: true,
            ),
          );
        } else {
          // Attempt to re-initialize if not ready
          bool available = await _speech.initialize();
          isSpeechAvailable.value = available;
          if (available) {
            await _speech.listen(
              onResult: (result) {
                liveText.value = result.recognizedWords;
              },
              listenOptions: stt.SpeechListenOptions(
                localeId: 'ar-EG',
                listenFor: const Duration(minutes: 5),
                pauseFor: const Duration(seconds: 10),
                cancelOnError: false,
                partialResults: true,
              ),
            );
          }
        }
      } else {
        Get.snackbar(
          'صلاحية الميكروفون',
          'يرجى تفعيل صلاحية الميكروفون من إعدادات الهاتف لتتمكن من التسميع.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFBA1A1A),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في بدء التسجيل: $e');
    }
  }

  // إيقاف التسجيل وبدء التقييم
  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (isSpeechAvailable.value) {
        await _speech.stop();
      }
      isRecording.value = false;
      if (path != null) {
        isLoading.value = true;
        
        // 1. Fetch original Uthmani text of target surah range
        final correctText = await _fetchCorrectTextApp(  );
        
        // 2. Read audio file bytes and encode to base64
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (bytes.isEmpty || bytes.length < 1000) {
            Get.snackbar(
              'مرتل القرآن',
              'الملف الصوتي فارغ أو قصير جداً. يرجى التحدث بوضوح والتأكد من تفعيل صلاحية الميكروفون (شائع على محاكيات الهواتف).',
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFFBA1A1A),
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
            isLoading.value = false;
            return;
          }
          final base64Audio = base64Encode(bytes);
          
          // 3. Call Gemini API for evaluation
          await evaluateRecitationWithAudio(correctText, base64Audio);
        } else {
          Get.snackbar('خطأ', 'فشل العثور على ملف الصوت المسجل');
          isLoading.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      Get.snackbar(
        'مرتل القرآن',
        'حدث خطأ في معالجة التسجيل، تم عرض نموذج توضيحي للنتائج.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A).withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      _showMockData();
      hasResult.value = true;
      isLoading.value = false;
    }
  }

  Future<String> _fetchCorrectTextApp(  ) async {
    final searchName = _stripTashkeel(surahName.value.replaceFirst('سورة ', '').trim());
    final meta = rawSurahs.firstWhere(
      (element) => _stripTashkeel(element['name'] as String) == searchName,
    );
    final surahId = meta['id'];
    
    final url = Uri.parse('https://api.alquran.cloud/v1/surah/$surahId/quran-uthmani');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final ayahs = data['data']['ayahs'] as List;
      
      final start = startAyah.value;
      final end = endAyah.value;
      
      final targetAyahs = ayahs.sublist(start - 1, end);
      return targetAyahs.map((a) => a['text'] as String).join(' ');
    }
    throw Exception('Failed to load Quranic text');
  }

  Future<void> evaluateRecitationWithAudio(String originalText, String base64Audio) async {
    isLoading.value = true;
    try {
      final prompt = '''
      You are an expert Quran recitation correction assistant.
      The user is reciting the following target Quranic text: "$originalText"
      
      Compare their audio recitation to the target text.
      Evaluate if they pronounced each word correctly.
      
      Provide your response in JSON format matching this schema:
      {
        "score": 0-100 score,
        "transcription": "Arabic transcription of what the user recited (exactly as they pronounced it)",
        "words": [
          {"text": "word from target text", "isCorrect": true/false}
        ],
        "tips": ["helpful feedback tips in Arabic regarding pronunciation, rules, or mistakes"]
      }
      
      Ensure every word from the target text is mapped in the "words" array in correct order.
      ''';

      http.Response? response;
      int maxRetries = 3;
      int retryCount = 0;
      int delaySeconds = 2;

      while (retryCount < maxRetries) {
        try {
          response = await http.post(
            Uri.parse('$_apiUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'inlineData': {
                        'mimeType': 'audio/wav',
                        'data': base64Audio
                      }
                    },
                    {
                      'text': prompt
                    }
                  ]
                }
              ],
              'generationConfig': {
                'responseMimeType': 'application/json',
                'responseSchema': {
                  'type': 'OBJECT',
                  'properties': {
                    'score': {
                      'type': 'INTEGER',
                    },
                    'transcription': {
                      'type': 'STRING',
                    },
                    'words': {
                      'type': 'ARRAY',
                      'items': {
                        'type': 'OBJECT',
                        'properties': {
                          'text': {
                            'type': 'STRING',
                          },
                          'isCorrect': {
                            'type': 'BOOLEAN',
                          },
                        },
                        'required': ['text', 'isCorrect'],
                      },
                    },
                    'tips': {
                      'type': 'ARRAY',
                      'items': {
                        'type': 'STRING',
                      },
                    },
                  },
                  'required': ['score', 'transcription', 'words', 'tips'],
                },
              }
            }),
          ).timeout(const Duration(seconds: 15));

          if (response.statusCode == 200) {
            break; // Success
          } else if (response.statusCode == 503 || response.statusCode == 429) {
            retryCount++;
            if (retryCount < maxRetries) {
              debugPrint('Gemini API returned ${response.statusCode}. Retrying in $delaySeconds seconds (attempt $retryCount/$maxRetries)...');
              await Future.delayed(Duration(seconds: delaySeconds));
              delaySeconds *= 2;
            }
          } else {
            break; // Non-retryable error status code
          }
        } catch (e) {
          retryCount++;
          if (retryCount < maxRetries) {
            debugPrint('Gemini API request failed: $e. Retrying in $delaySeconds seconds (attempt $retryCount/$maxRetries)...');
            await Future.delayed(Duration(seconds: delaySeconds));
            delaySeconds *= 2;
          } else {
            rethrow;
          }
        }
      }

      if (response == null) {
        throw Exception('فشل التوصيل بالخادم، لم يتم الحصول على استجابة.');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('استجابة خالية من خوادم التقييم الذكي.');
        }
        
        final content = candidates[0]['content'];
        if (content == null) {
          throw Exception('تم حظر المحتوى أو لم يتم توليد رد من الخادم.');
        }
        
        final parts = content['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          throw Exception('استجابة خالية في أجزاء النص.');
        }
        
        String resultText = parts[0]['text'] as String? ?? '';
        resultText = resultText.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonResult = jsonDecode(resultText);
        
        final double parsedScore = (jsonResult['score'] as num?)?.toDouble() ?? 0.0;
        final String parsedTranscription = jsonResult['transcription'] as String? ?? '';
        final List<String> parsedTips = jsonResult['tips'] != null 
            ? List<String>.from(jsonResult['tips']) 
            : <String>[];
            
        final List<EvaluationWord> parsedWords = <EvaluationWord>[];
        if (jsonResult['words'] != null) {
          for (var w in (jsonResult['words'] as List)) {
            parsedWords.add(EvaluationWord(
              text: (w['text'] as String?) ?? '',
              isCorrect: (w['isCorrect'] as bool?) ?? false,
            ));
          }
        }
        
        score.value = parsedScore;
        transcription.value = parsedTranscription;
        tips.value = parsedTips;
        evaluationWords.value = parsedWords;
        hasResult.value = true;
        
        // Track the recited verses if the score is passing (>= 75%)
        if (score.value >= 75.0) {
          _trackRecitedVerses();
          _saveHifzSessionStats(score.value);
        }
      } else {
        debugPrint('Gemini API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('فشل الاتصال بالخادم: رمز الحالة ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('AI Evaluation Error: $e');
      
      String friendlyMessage = 'حدث خطأ غير متوقع أثناء معالجة التقييم.';
      final errStr = e.toString();
      if (errStr.contains('503')) {
        friendlyMessage = 'خوادم التقييم الذكي مزدحمة حالياً نتيجة للطلب المرتفع. تم عرض نموذج نتائج توضيحي، يرجى إعادة المحاولة بعد ثوانٍ.';
      } else if (errStr.contains('429')) {
        friendlyMessage = 'تم تجاوز عدد الطلبات المسموح بها مؤقتاً. تم عرض نموذج نتائج توضيحي، يرجى المحاولة بعد قليل.';
      } else if (errStr.contains('TimeoutException') || errStr.contains('SocketException')) {
        friendlyMessage = 'يبدو أن هناك مشكلة أو بطء في اتصال الإنترنت لديك. تم عرض نموذج نتائج توضيحي.';
      } else if (errStr.contains('استجابة خالية')) {
        friendlyMessage = 'لم يتم الكشف عن صوت واضح في التسجيل (شائع على محاكي الآيفون لعدم اتصال الميكروفون). تم عرض نتائج تجريبية لتوضيح التجربة.';
      } else {
        friendlyMessage = 'فشل الاتصال بالذكاء الاصطناعي: $friendlyMessage (الرمز: $e)';
      }

      Get.snackbar(
        'مرتل القرآن',
        friendlyMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A).withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
      _showMockData();
      hasResult.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _showMockData() {
    score.value = 92;
    evaluationWords.value = [
      EvaluationWord(text: 'تَبَارَكَ ', isCorrect: true),
      EvaluationWord(text: 'الَّذِي ', isCorrect: true),
      EvaluationWord(text: 'بِيَدِهِ ', isCorrect: true),
      EvaluationWord(text: 'الْمُلْكُ ', isCorrect: true),
      EvaluationWord(text: 'وَهُوَ ', isCorrect: true),
    ];
    tips.value = ['قراءتك ممتازة، استمر في المراجعة.'];
  }

  void _trackRecitedVerses() {
    try {
      final prefs = Get.find<SharedPreferences>();
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final readKey = 'verses_read_$todayStr';
      final readListKey = 'unique_verses_read_list_$todayStr';
      
      final List<String> readList = prefs.getStringList(readListKey) ?? [];
      
      final searchName = surahName.value.replaceFirst('سورة ', '').trim();
      final meta = rawSurahs.firstWhere((element) => element['name'] == searchName);
      final surahId = meta['id'];
      
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
        prefs.setInt(totalKey, totalRead + (endAyah.value - startAyah.value + 1));
        
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

class EvaluationWord {
  final String text;
  final bool isCorrect;

  EvaluationWord({required this.text, required this.isCorrect});
}

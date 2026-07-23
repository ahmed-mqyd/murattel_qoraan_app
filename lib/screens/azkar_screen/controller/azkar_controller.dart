import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/controllers/audio_controller.dart';
import 'package:murattel_qoraan_app/core/data/azkar_library_data.dart';
import 'package:murattel_qoraan_app/screens/home_screen/controller/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dhikr {
  final String text;
  final int targetCount;
  final String? source;
  final RxInt currentCount = 0.obs;
  final RxBool isFinished = false.obs;

  Dhikr({required this.text, required this.targetCount, this.source});

  void increment() {
    if (currentCount.value < targetCount) {
      currentCount.value++;
      HapticFeedback.lightImpact();
      if (currentCount.value == targetCount) {
        isFinished.value = true;
        HapticFeedback.heavyImpact();
      }
    }
  }

  void reset() {
    currentCount.value = 0;
    isFinished.value = false;
  }
}

class AzkarController extends GetxController {
  late final SharedPreferences _prefs;
  final RxString selectedCategory = 'morning'.obs;
  final favoriteAzkar = <String>[].obs;

  final selectedDhikrIndex = 0.obs;
  final isCompleted = false.obs;
  final fontSize = 22.0.obs;

  /// الأذكار مبنية من المكتبة المركزية مغلّفة بحالة تفاعلية للعدادات
  late final Map<String, List<Dhikr>> azkarData;

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    fontSize.value = _prefs.getDouble('azkar_font_size') ?? 22.0;
    final favs = _prefs.getStringList('azkar_favorites_list') ?? [];
    favoriteAzkar.assignAll(favs);

    azkarData = {
      for (final category in AzkarLibrary.categories)
        category.key: category.items
            .map(
              (item) => Dhikr(
                text: item.text,
                targetCount: item.count,
                source: item.source,
              ),
            )
            .toList(),
    };

    // فتح القسم المطلوب من الإشعارات أو شاشة المكتبة
    final arg = Get.arguments;
    if (arg is String && azkarData.containsKey(arg)) {
      selectedCategory.value = arg;
    }

    checkCompletion();
  }

  // ملاحظة: لا نوقف صوت الرقية عند مغادرة الشاشة عمداً —
  // التلاوة تستمر في الخلفية بأزرار الإشعار تماماً مثل شاشة المصحف،
  // والإيقاف متاح من زر الإيقاف في الشريط أو من إشعار التشغيل.

  /// بيانات القسم الحالي من المكتبة (العنوان، الأيقونة، المجموعة...)
  AzkarCategoryData? get currentCategoryData =>
      AzkarLibrary.byKey(selectedCategory.value);

  /// أقسام نفس المجموعة — تُعرض في شريط الأقسام العلوي
  List<AzkarCategoryData> get sameGroupCategories {
    final current = currentCategoryData;
    if (current == null) return AzkarLibrary.byGroup(AzkarGroup.daily);
    return AzkarLibrary.byGroup(current.group);
  }

  bool get isRuqyahCategory => selectedCategory.value == 'ruqyah';

  void updateFontSize(double size) {
    fontSize.value = size;
    _prefs.setDouble('azkar_font_size', size);
  }

  void selectDhikr(int index) {
    if (index >= 0 && index < currentAzkar.length) {
      selectedDhikrIndex.value = index;
    }
  }

  void nextDhikr() {
    if (selectedDhikrIndex.value < currentAzkar.length - 1) {
      selectedDhikrIndex.value++;
    }
  }

  void previousDhikr() {
    if (selectedDhikrIndex.value > 0) {
      selectedDhikrIndex.value--;
    }
  }

  void checkCompletion() {
    if (currentAzkar.isEmpty) {
      isCompleted.value = false;
    } else {
      isCompleted.value = currentAzkar.every((dhikr) => dhikr.isFinished.value);
    }
  }

  void incrementDhikr(Dhikr dhikr) {
    dhikr.increment();
    checkCompletion();

    if (dhikr.isFinished.value) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (selectedDhikrIndex.value < currentAzkar.length - 1) {
          if (currentAzkar[selectedDhikrIndex.value].isFinished.value) {
            nextDhikr();
          }
        }
      });
    }
  }

  Future<void> toggleFavoriteDhikr(String text) async {
    if (favoriteAzkar.contains(text)) {
      favoriteAzkar.remove(text);
      Get.snackbar(
        'مرتل القرآن',
        'تم إزالة الذكر من المفضلة',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFC5A059).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } else {
      favoriteAzkar.add(text);
      Get.snackbar(
        'مرتل القرآن',
        'تم إضافة الذكر إلى المفضلة بنجاح',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF064E3B).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
    await _prefs.setStringList('azkar_favorites_list', favoriteAzkar.toList());

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshData();
    }
  }

  bool isDhikrFavorite(String text) {
    return favoriteAzkar.contains(text);
  }

  List<Dhikr> get currentAzkar => azkarData[selectedCategory.value] ?? [];

  void setCategory(String category) {
    selectedCategory.value = category;
    selectedDhikrIndex.value = 0;
    checkCompletion();
  }

  void resetAll() {
    for (var dhikr in currentAzkar) {
      dhikr.reset();
    }
    selectedDhikrIndex.value = 0;
    isCompleted.value = false;
  }

  // ═══════ تلاوة الرقية الشرعية الصوتية (خلفية مثل المصحف) ═══════

  AudioController get _audio => Get.find<AudioController>();

  bool get isRuqyahPlaying =>
      _audio.playingSelectionKey.value == 'ruqyah' && _audio.isPlaying.value;

  Future<void> toggleRuqyahAudio() async {
    final audio = _audio;
    if (audio.playingSelectionKey.value == 'ruqyah') {
      // جارية بالفعل — إيقاف مؤقت أو استئناف
      if (audio.isPlaying.value) {
        await audio.audioPlayer.pause();
      } else {
        await audio.audioPlayer.play();
      }
      return;
    }
    await audio.playAyahSelection(
      selectionKey: 'ruqyah',
      albumTitle: 'الرقية الشرعية',
      ayahs: AzkarLibrary.ruqyahAyahRefs,
    );
  }

  Future<void> stopRuqyahAudio() async {
    if (_audio.playingSelectionKey.value == 'ruqyah') {
      await _audio.stopSelection();
    }
  }
}

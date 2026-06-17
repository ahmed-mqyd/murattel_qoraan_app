import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/screens/home_screen/controller/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dhikr {
  final String text;
  final int targetCount;
  final RxInt currentCount = 0.obs;
  final RxBool isFinished = false.obs;

  Dhikr({required this.text, required this.targetCount});

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

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    final favs = _prefs.getStringList('azkar_favorites_list') ?? [];
    favoriteAzkar.assignAll(favs);
    checkCompletion();
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
        'حصن المسلم',
        'تم إزالة الذكر من المفضلة',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFC5A059).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } else {
      favoriteAzkar.add(text);
      Get.snackbar(
        'حصن المسلم',
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

  final Map<String, List<Dhikr>> azkarData = {
    'morning': [
      Dhikr(text: 'أَصْبَحْنَا وَأَصْبَحَ المُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ المُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', targetCount: 1),
      Dhikr(text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ', targetCount: 1),
      Dhikr(text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ', targetCount: 100),
      Dhikr(text: 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ', targetCount: 3),
    ],
    'evening': [
      Dhikr(text: 'أَمْسَيْنَا وَأَمْسَى المُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ المُلْكُ وَلَهُ الْحَمْدُ وَهُوة عَلَى كُلِّ شَيْءٍ قَدِيرٌ', targetCount: 1),
      Dhikr(text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ المَصِيرُ', targetCount: 1),
      Dhikr(text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ', targetCount: 100),
      Dhikr(text: 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ', targetCount: 3),
    ],
    'after_prayer': [
      Dhikr(text: 'أستغفر الله', targetCount: 3),
      Dhikr(text: 'اللهم أنت السلام ومنك السلام، تباركت يا ذا الجلال والإكرام', targetCount: 1),
      Dhikr(text: 'سبحان الله', targetCount: 33),
      Dhikr(text: 'الحمد لله', targetCount: 33),
      Dhikr(text: 'الله أكبر', targetCount: 33),
      Dhikr(text: 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير', targetCount: 1),
    ],
    'sleep': [
      Dhikr(text: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا، بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ', targetCount: 1),
      Dhikr(text: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ', targetCount: 3),
      Dhikr(text: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', targetCount: 1),
    ],
  };

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
}

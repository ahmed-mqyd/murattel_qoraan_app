import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home_screen/controller/home_controller.dart';

class TasbeehZikr {
  final String text;
  final String translation;

  TasbeehZikr({required this.text, required this.translation});
}

class TasbeehController extends GetxController {
  final zikrList = <TasbeehZikr>[
    TasbeehZikr(text: 'أَسْتَغْفِرُ اللَّهَ', translation: 'Astaghfirullah'),
    TasbeehZikr(text: 'سُبْحَانَ اللَّهِ', translation: 'Subhan Allah'),
    TasbeehZikr(text: 'الْحَمْدُ لِلَّهِ', translation: 'Alhamdulillah'),
    TasbeehZikr(text: 'لَا إِلَٰهَ إِلَّا اللَّهُ', translation: 'La ilaha illa Allah'),
    TasbeehZikr(text: 'اللَّهُ أَكْبَرُ', translation: 'Allahu Akbar'),
    TasbeehZikr(text: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ', translation: 'La hawla wa la quwwata illa billah'),
    TasbeehZikr(text: 'اللَّهُمَّ صَلِّ وَسَلِّيمْ عَلَى نَبِيِّنَا مُحَمَّدٍ', translation: 'Allahumma salli wa sallim ala nabiyyina Muhammad'),
    TasbeehZikr(text: 'عَدَّادٌ حُرٌّ', translation: 'Custom Counter'),
  ];

  final selectedZikrIndex = 0.obs;
  final currentCount = 0.obs;
  final cycleCount = 0.obs;
  final targetCount = 33.obs; // Default to 33
  final targetOptions = [33, 100, 1000, 0]; // 0 means Free/Unlimited

  final dailyTotalCount = 0.obs;
  late final SharedPreferences _prefs;

  @override
  void onInit() async {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    _loadDailyCount();
  }

  void _loadDailyCount() {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    dailyTotalCount.value = _prefs.getInt('daily_tasbeeh_count_$todayStr') ?? 0;
  }

  void increment() async {
    currentCount.value++;
    
    // Save to daily total
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    dailyTotalCount.value = (_prefs.getInt('daily_tasbeeh_count_$todayStr') ?? 0) + 1;
    await _prefs.setInt('daily_tasbeeh_count_$todayStr', dailyTotalCount.value);

    // Refresh HomeController if registered
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshData();
    }

    // Check if target reached (and target is not 0 / Free)
    if (targetCount.value > 0 && currentCount.value >= targetCount.value) {
      currentCount.value = 0;
      cycleCount.value++;
    }
  }

  void resetCurrent() {
    currentCount.value = 0;
  }

  void resetAll() async {
    currentCount.value = 0;
    cycleCount.value = 0;
  }

  void setTarget(int target) {
    targetCount.value = target;
    currentCount.value = 0;
  }

  void selectZikr(int index) {
    selectedZikrIndex.value = index;
    currentCount.value = 0;
    cycleCount.value = 0;
  }

  TasbeehZikr get currentZikr => zikrList[selectedZikrIndex.value];
}

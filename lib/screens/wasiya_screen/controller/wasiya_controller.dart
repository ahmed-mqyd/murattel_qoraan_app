import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home_screen/controller/home_controller.dart';

class WasiyaController extends GetxController {
  final selectedStepIndex = 0.obs;

  final isFatihaDone = false.obs;
  final isAyahKursiDone = false.obs;
  final isLastBaqarahDone = false.obs;
  final isIkhlasDone = false.obs;
  final isFalaqDone = false.obs;
  final isNasDone = false.obs;

  final tasbeehCount = 0.obs;
  final istighfarCount = 0.obs;

  final isCompleted = false.obs;
  late final SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    _loadState();
  }

  void _loadState() {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final doneToday = _prefs.getBool('wasiya_abukhader_$todayStr') ?? false;

    if (doneToday) {
      isFatihaDone.value = true;
      isAyahKursiDone.value = true;
      isLastBaqarahDone.value = true;
      isIkhlasDone.value = true;
      isFalaqDone.value = true;
      isNasDone.value = true;
      tasbeehCount.value = 100;
      istighfarCount.value = 100;
      isCompleted.value = true;
    } else {
      // Load partial state if saved
      isFatihaDone.value = _prefs.getBool('wasiya_step_1_$todayStr') ?? false;
      isAyahKursiDone.value = _prefs.getBool('wasiya_step_2_$todayStr') ?? false;
      isLastBaqarahDone.value = _prefs.getBool('wasiya_step_3_$todayStr') ?? false;
      isIkhlasDone.value = _prefs.getBool('wasiya_step_4_$todayStr') ?? false;
      isFalaqDone.value = _prefs.getBool('wasiya_step_5_$todayStr') ?? false;
      isNasDone.value = _prefs.getBool('wasiya_step_6_$todayStr') ?? false;
      tasbeehCount.value = _prefs.getInt('wasiya_step_7_$todayStr') ?? 0;
      istighfarCount.value = _prefs.getInt('wasiya_step_8_$todayStr') ?? 0;
      
      // Auto-focus on first incomplete step
      if (!isFatihaDone.value) {
        selectedStepIndex.value = 0;
      } else if (!isAyahKursiDone.value) {
        selectedStepIndex.value = 1;
      } else if (!isLastBaqarahDone.value) {
        selectedStepIndex.value = 2;
      } else if (!isIkhlasDone.value) {
        selectedStepIndex.value = 3;
      } else if (!isFalaqDone.value) {
        selectedStepIndex.value = 4;
      } else if (!isNasDone.value) {
        selectedStepIndex.value = 5;
      } else if (tasbeehCount.value < 100) {
        selectedStepIndex.value = 6;
      } else if (istighfarCount.value < 100) {
        selectedStepIndex.value = 7;
      } else {
        selectedStepIndex.value = 0;
      }
    }
  }

  void selectStep(int index) {
    selectedStepIndex.value = index;
  }

  void toggleStep(int index, bool val) {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    switch (index) {
      case 1:
        isFatihaDone.value = val;
        _prefs.setBool('wasiya_step_1_$todayStr', val);
        break;
      case 2:
        isAyahKursiDone.value = val;
        _prefs.setBool('wasiya_step_2_$todayStr', val);
        break;
      case 3:
        isLastBaqarahDone.value = val;
        _prefs.setBool('wasiya_step_3_$todayStr', val);
        break;
      case 4:
        isIkhlasDone.value = val;
        _prefs.setBool('wasiya_step_4_$todayStr', val);
        break;
      case 5:
        isFalaqDone.value = val;
        _prefs.setBool('wasiya_step_5_$todayStr', val);
        break;
      case 6:
        isNasDone.value = val;
        _prefs.setBool('wasiya_step_6_$todayStr', val);
        break;
    }
    _checkCompletion();
    
    // Auto-advance if marking as done
    if (val && selectedStepIndex.value == index - 1 && selectedStepIndex.value < 7) {
      selectedStepIndex.value++;
    }
  }

  void completeReadingStep(int index) {
    toggleStep(index, true);
  }

  void incrementTasbeeh() {
    if (tasbeehCount.value < 100) {
      tasbeehCount.value++;
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      _prefs.setInt('wasiya_step_7_$todayStr', tasbeehCount.value);
      _checkCompletion();
      
      // Auto-advance to Istighfar when complete
      if (tasbeehCount.value == 100 && selectedStepIndex.value == 6) {
        selectedStepIndex.value = 7;
      }
    }
  }

  void incrementIstighfar() {
    if (istighfarCount.value < 100) {
      istighfarCount.value++;
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      _prefs.setInt('wasiya_step_8_$todayStr', istighfarCount.value);
      _checkCompletion();
    }
  }

  void resetWasiya() async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    
    isFatihaDone.value = false;
    isAyahKursiDone.value = false;
    isLastBaqarahDone.value = false;
    isIkhlasDone.value = false;
    isFalaqDone.value = false;
    isNasDone.value = false;
    tasbeehCount.value = 0;
    istighfarCount.value = 0;
    isCompleted.value = false;
    selectedStepIndex.value = 0;

    await _prefs.remove('wasiya_abukhader_$todayStr');
    await _prefs.remove('wasiya_step_1_$todayStr');
    await _prefs.remove('wasiya_step_2_$todayStr');
    await _prefs.remove('wasiya_step_3_$todayStr');
    await _prefs.remove('wasiya_step_4_$todayStr');
    await _prefs.remove('wasiya_step_5_$todayStr');
    await _prefs.remove('wasiya_step_6_$todayStr');
    await _prefs.remove('wasiya_step_7_$todayStr');
    await _prefs.remove('wasiya_step_8_$todayStr');

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshData();
    }
  }

  void _checkCompletion() async {
    final allReadDone = isFatihaDone.value &&
        isAyahKursiDone.value &&
        isLastBaqarahDone.value &&
        isIkhlasDone.value &&
        isFalaqDone.value &&
        isNasDone.value;

    final allCountersDone = tasbeehCount.value >= 100 && istighfarCount.value >= 100;

    if (allReadDone && allCountersDone && !isCompleted.value) {
      isCompleted.value = true;
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      await _prefs.setBool('wasiya_abukhader_$todayStr', true);

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshData();
      }
    }
  }
}

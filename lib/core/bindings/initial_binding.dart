import 'package:get/get.dart';
import '../theme/theme_service.dart';
import '../controllers/audio_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // 1. SharedPreferences (already initialized in main.dart)
    // We register it in Get so it is available everywhere.

    Get.put(ThemeController());
    Get.put(AudioController(), permanent: true);
  }
}

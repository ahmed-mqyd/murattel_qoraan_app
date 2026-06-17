import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // RxBool to hold the dark mode state
  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    // Default to the platform theme mode
    _isDarkMode.value = Get.isPlatformDarkMode;
  }

  void toggleTheme() {
    if (_isDarkMode.value) {
      Get.changeThemeMode(ThemeMode.light);
      _isDarkMode.value = false;
    } else {
      Get.changeThemeMode(ThemeMode.dark);
      _isDarkMode.value = true;
    }
  }
}

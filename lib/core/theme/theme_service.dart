import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  // RxString to hold the theme mode: 'light', 'dark', 'sepia', or 'system'
  final RxString _themeMode = 'system'.obs;

  String get themeModeString => _themeMode.value;

  ThemeMode get themeMode {
    switch (_themeMode.value) {
      case 'light':
      case 'sepia':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode {
    if (_themeMode.value == 'system') {
      return Get.isPlatformDarkMode;
    }
    return _themeMode.value == 'dark';
  }

  @override
  void onInit() {
    super.onInit();
    final prefs = Get.find<SharedPreferences>();
    _themeMode.value = prefs.getString('settings_theme_mode') ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    if (mode == 'light' || mode == 'dark' || mode == 'sepia' || mode == 'system') {
      _themeMode.value = mode;
      final prefs = Get.find<SharedPreferences>();
      await prefs.setString('settings_theme_mode', mode);
      
      if (mode == 'light') {
        Get.changeThemeMode(ThemeMode.light);
      } else if (mode == 'dark') {
        Get.changeThemeMode(ThemeMode.dark);
      } else if (mode == 'sepia') {
        // Sepia has brightness of light but custom themes
        Get.changeThemeMode(ThemeMode.light);
      } else {
        Get.changeThemeMode(ThemeMode.system);
      }
    }
  }
}

class ThemeColors {
  final Color backgroundColor;
  final Color cardBackgroundColor;
  final Color outlineColor;
  final Color textColor;
  final Color primaryColor;
  final Color goldColor;

  const ThemeColors({
    required this.backgroundColor,
    required this.cardBackgroundColor,
    required this.outlineColor,
    required this.textColor,
    required this.primaryColor,
    required this.goldColor,
  });

  static ThemeColors of(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final mode = themeController.themeModeString;

    final bool isDark = mode == 'dark' || (mode == 'system' && Get.isPlatformDarkMode);
    final bool isSepia = mode == 'sepia';

    if (isDark) {
      return const ThemeColors(
        backgroundColor: Color(0xFF02160F),
        cardBackgroundColor: Color(0xFF052219),
        outlineColor: Color(0x4D204F3F), // 204F3F at 30% alpha
        textColor: Color(0xFFE2E2E5),
        primaryColor: Color(0xFFA0D1BC),
        goldColor: Color(0xFFC5A059),
      );
    } else if (isSepia) {
      return const ThemeColors(
        backgroundColor: Color(0xFFF4ECD8), // Warm paper background
        cardBackgroundColor: Color(0xFFFAF4E8), // Light cream card background
        outlineColor: Color(0x4D8C7A5B), // Warm sepia outline (30% alpha)
        textColor: Color(0xFF3E2723), // Deep chocolate text
        primaryColor: Color(0xFF5D4037), // Warm brown primary
        goldColor: Color(0xFFC5A059), // Gold accents
      );
    } else {
      return const ThemeColors(
        backgroundColor: Color(0xFFFDFBF7),
        cardBackgroundColor: Colors.white,
        outlineColor: Color(0x66BFC9C3), // BFC9C3 at 40% alpha
        textColor: Color(0xFF1A1C1E),
        primaryColor: Color(0xFF003527),
        goldColor: Color(0xFFC5A059),
      );
    }
  }
}

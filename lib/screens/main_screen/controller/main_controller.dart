import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/screens/home_screen/view/home_view.dart';
import 'package:murattel_qoraan_app/screens/mushaf_screen/view/mushaf_view.dart';
import 'package:murattel_qoraan_app/screens/hifz_screen/view/hifz_view.dart';
import 'package:murattel_qoraan_app/screens/suluk_screen/view/suluk_view.dart';
import 'package:murattel_qoraan_app/screens/settings_screen/view/settings_view.dart';

class MainController extends GetxController {
  final currentIndex = 2.obs;

  final List<Widget> pages = [
    const HifzView(),
    const MushafView(),
    const HomeScreen(),
    const SulukView(),
    const SettingsView(),
  ];

  final List<String> pageNames = [
    'الحفظ',
    'المصحف',
    'الرئيسية',
    'السلوك',
    'الإعدادات',
  ];

  final List<IconData> pageIcons = [
    Icons.mic_rounded,
    Icons.menu_book_rounded,
    Icons.home_filled,
    Icons.insights_rounded,
    Icons.settings_rounded,
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}

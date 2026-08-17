import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/notification_services/notification_services.dart';
import 'package:murattel_qoraan_app/screens/home_screen/view/home_view.dart';
import 'package:murattel_qoraan_app/screens/mushaf_screen/view/mushaf_view.dart';
import 'package:murattel_qoraan_app/screens/hifz_screen/view/hifz_view.dart';
import 'package:murattel_qoraan_app/screens/suluk_screen/view/suluk_view.dart';
import 'package:murattel_qoraan_app/screens/settings_screen/view/settings_view.dart';

class MainController extends GetxController {
  final currentIndex = 2.obs;

  /// آخر وقت ضغط زر الرجوع — لتتبع الضغطة المزدوجة للخروج من التطبيق
  DateTime? lastBackPressTime;

  @override
  void onInit() {
    super.onInit();
    // تهيئة الإشعارات وطلب صلاحياتها (بما فيها التنبيه الدقيق) بعد ظهور
    // الشاشة الرئيسية فعليًا وليس أثناء إقلاع التطبيق في main() — طلب
    // الصلاحيات قبل أول إطار يعتمد على Activity context قد لا يكون جاهزًا
    // بعد على بعض الأجهزة، وهو ما كان يسبب فشل فتح التطبيق عند جوجل بلاي.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NotificationServices.initialize();
        await NotificationServices.scheduleDailySpiritualGoals();
        await NotificationServices.checkAppLaunchNotification();
      } catch (e) {
        Get.log('فشل تهيئة/جدولة الإشعارات: $e');
      }
    });
  }

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

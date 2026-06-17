import 'package:get/get.dart';
import 'package:murattel_qoraan_app/core/routes/app_routes.dart';
import 'package:murattel_qoraan_app/screens/main_screen/view/main_view.dart'; 
import 'package:murattel_qoraan_app/screens/main_screen/controller/main_controller.dart';
import 'package:murattel_qoraan_app/screens/splash_screen/view/splash_view.dart'; 
import 'package:murattel_qoraan_app/screens/splash_screen/controller/splash_controller.dart';
import 'package:murattel_qoraan_app/screens/home_screen/controller/home_controller.dart';
import 'package:murattel_qoraan_app/screens/mushaf_screen/controller/mushaf_controller.dart';
import 'package:murattel_qoraan_app/screens/hifz_screen/controller/hifz_controller.dart';
import 'package:murattel_qoraan_app/screens/suluk_screen/controller/suluk_controller.dart';
import 'package:murattel_qoraan_app/screens/settings_screen/controller/settings_controller.dart';
import 'package:murattel_qoraan_app/screens/qibla_screen/view/qibla_view.dart';
import 'package:murattel_qoraan_app/screens/qibla_screen/controller/qibla_controller.dart';
import 'package:murattel_qoraan_app/screens/mushaf_reader_screen/view/mushaf_reader_view.dart';
import 'package:murattel_qoraan_app/screens/mushaf_reader_screen/controller/mushaf_reader_controller.dart';
import 'package:murattel_qoraan_app/screens/prayer_times_screen/view/prayer_times_view.dart';
import 'package:murattel_qoraan_app/screens/prayer_times_screen/controller/prayer_times_controller.dart';
import 'package:murattel_qoraan_app/screens/azkar_screen/view/azkar_view.dart';
import 'package:murattel_qoraan_app/screens/azkar_screen/controller/azkar_controller.dart';
import 'package:murattel_qoraan_app/screens/tasbeeh_screen/view/tasbeeh_view.dart';
import 'package:murattel_qoraan_app/screens/tasbeeh_screen/controller/tasbeeh_controller.dart';
import 'package:murattel_qoraan_app/screens/wasiya_screen/view/wasiya_view.dart';
import 'package:murattel_qoraan_app/screens/wasiya_screen/controller/wasiya_controller.dart';

abstract class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.home,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
        Get.put(HomeController());
        Get.put(MushafController());
        Get.put(HifzController());
        Get.put(SulukController());
        Get.put(SettingsController());
      }),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.qibla,
      page: () => const QiblaView(),
      binding: BindingsBuilder(() {
        Get.put(QiblaController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.mushafReader,
      page: () => const MushafReaderView(),
      binding: BindingsBuilder(() {
        Get.put(MushafReaderController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.prayerTimes,
      page: () => const PrayerTimesView(),
      binding: BindingsBuilder(() {
        Get.put(PrayerTimesController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.azkar,
      page: () => const AzkarView(),
      binding: BindingsBuilder(() {
        Get.put(AzkarController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.tasbeeh,
      page: () => const TasbeehView(),
      binding: BindingsBuilder(() {
        Get.put(TasbeehController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.wasiya,
      page: () => const WasiyaView(),
      binding: BindingsBuilder(() {
        Get.put(WasiyaController());
      }),
      transition: Transition.rightToLeft,
    ),
  ];
}

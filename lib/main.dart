import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:murattel_qoraan_app/core/theme/app_theme.dart';
import 'package:murattel_qoraan_app/core/theme/theme_service.dart';
import 'package:murattel_qoraan_app/core/routes/app_pages.dart';
import 'package:murattel_qoraan_app/core/bindings/initial_binding.dart';
import 'package:murattel_qoraan_app/core/notification_services/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio_background/just_audio_background.dart';
  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background audio playback service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ahmdmqyd.murattelqoraan.channel.audio',
    androidNotificationChannelName: 'تلاوة القرآن الكريم',
    androidNotificationOngoing: true,
  );
  
  // Initialize SharedPreferences and register it for DI
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);
  
  // Initialize and schedule daily notifications
  await NotificationServices.initialize();
  await NotificationServices.scheduleDailySpiritualGoals();
  
  Get.put(ThemeController());
  runApp(const MyApp());

  // Check if app was launched via notification click
  NotificationServices.checkAppLaunchNotification();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return ScreenUtilPlusInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() {
          return GetMaterialApp(
            title: 'Murattel Quraan',
            debugShowCheckedModeBanner: false,
            theme: themeController.themeModeString == 'sepia'
                ? AppTheme.sepiaTheme
                : AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppPages.initial,
            getPages: AppPages.routes,
            initialBinding: InitialBinding(),
          );
        });
      },
    );
  }
}

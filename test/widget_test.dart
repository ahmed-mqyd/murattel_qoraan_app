import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murattel_qoraan_app/core/theme/theme_service.dart';
import 'package:murattel_qoraan_app/main.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Set screen size to avoid layout overflow issues in tests
    tester.view.physicalSize = const Size(1080, 2220); // typical device size (pixel size)
    tester.view.devicePixelRatio = 3.0; // typical device ratio

    // Reset the test view at the end of the test to clean up
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
    Get.put(ThemeController());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our Splash screen is loaded and shows 'مرتل القرآن'
    expect(find.text('مرتل القرآن'), findsOneWidget);

    // Pump the timer so the pending navigation completes before test teardown
    await tester.pump(const Duration(seconds: 3));
  });
}

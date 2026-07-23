import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murattel_qoraan_app/screens/tasbeeh_screen/controller/tasbeeh_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TasbeehController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    controller = TasbeehController();
    controller.onInit();
  });

  tearDown(() {
    Get.reset();
  });

  group('TasbeehController Tests - اختبارات متحكم السبحة الإلكترونية', () {
    test('Initial values should be set correctly', () {
      expect(controller.currentCount.value, equals(0));
      expect(controller.cycleCount.value, equals(0));
      expect(controller.targetCount.value, equals(33));
      expect(controller.selectedZikrIndex.value, equals(0));
      expect(controller.currentZikr.text, equals('أَسْتَغْفِرُ اللَّهَ'));
    });

    test('Increment should increase current count and daily total count', () async {
      await controller.increment();
      expect(controller.currentCount.value, equals(1));
      expect(controller.dailyTotalCount.value, equals(1));

      await controller.increment();
      expect(controller.currentCount.value, equals(2));
      expect(controller.dailyTotalCount.value, equals(2));
    });

    test('Reaching target count (33) resets current count and increments cycle count', () async {
      for (int i = 0; i < 32; i++) {
        await controller.increment();
      }
      expect(controller.currentCount.value, equals(32));
      expect(controller.cycleCount.value, equals(0));

      // 33rd increment reaches target
      await controller.increment();
      expect(controller.currentCount.value, equals(0));
      expect(controller.cycleCount.value, equals(1));
    });

    test('Changing target count resets current count', () async {
      await controller.increment();
      await controller.increment();
      expect(controller.currentCount.value, equals(2));

      controller.setTarget(100);
      expect(controller.targetCount.value, equals(100));
      expect(controller.currentCount.value, equals(0));
    });

    test('Selecting another Zikr resets current and cycle count', () async {
      await controller.increment();
      await controller.increment();

      controller.selectZikr(1);
      expect(controller.selectedZikrIndex.value, equals(1));
      expect(controller.currentZikr.text, equals('سُبْحَانَ اللَّهِ'));
      expect(controller.currentCount.value, equals(0));
      expect(controller.cycleCount.value, equals(0));
    });

    test('Reset current count should set count to 0', () async {
      await controller.increment();
      await controller.increment();
      controller.resetCurrent();

      expect(controller.currentCount.value, equals(0));
    });

    test('Reset all should set current count and cycle count to 0', () async {
      for (int i = 0; i < 33; i++) {
        await controller.increment();
      }
      await controller.increment();

      controller.resetAll();
      expect(controller.currentCount.value, equals(0));
      expect(controller.cycleCount.value, equals(0));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:murattel_qoraan_app/core/utils/prayer_time_utils.dart';

void main() {
  group('PrayerTimeUtils Tests - اختبارات دالة تنظيف أوقات الصلاة', () {
    test('Should clean time string containing timezone offset e.g. "04:32 (EET)"', () {
      final rawTime = '04:32 (EET)';
      final cleaned = cleanPrayerTimeString(rawTime);
      expect(cleaned, equals('04:32'));
    });

    test('Should handle plain time string without timezone e.g. "12:15"', () {
      final rawTime = '12:15';
      final cleaned = cleanPrayerTimeString(rawTime);
      expect(cleaned, equals('12:15'));
    });

    test('Should handle time string with space before suffix e.g. "15:45 +03"', () {
      final rawTime = '15:45 +03';
      final cleaned = cleanPrayerTimeString(rawTime);
      expect(cleaned, equals('15:45'));
    });

    test('Should return empty string if input is empty', () {
      final rawTime = '';
      final cleaned = cleanPrayerTimeString(rawTime);
      expect(cleaned, equals(''));
    });
  });
}

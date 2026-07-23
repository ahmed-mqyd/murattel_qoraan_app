import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Khatmah & Spiritual Goal Calculations Tests - اختبارات الختمة والأهداف الإيمانية', () {
    test('Khatmah completion percentage calculation', () {
      const int totalParts = 30;
      int completedParts = 18;

      double progressRatio = completedParts / totalParts;
      int percentage = (progressRatio * 100).toInt();

      expect(percentage, equals(60));
    });

    test('Full Khatmah completion calculates to 100%', () {
      const int totalParts = 30;
      int completedParts = 30;

      double progressRatio = completedParts / totalParts;
      int percentage = (progressRatio * 100).toInt();

      expect(percentage, equals(100));
    });

    test('Spiritual Goal Ayah Hifz percentage calculation (7/10 verses = 70%)', () {
      const int targetVerses = 10;
      int memorizedVerses = 7;

      double progressRatio = memorizedVerses / targetVerses;
      int percentage = (progressRatio * 100).toInt();

      expect(percentage, equals(70));
    });

    test('Spiritual Goal Ayah Hifz clamp ratio to max 1.0', () {
      const int targetVerses = 10;
      int memorizedVerses = 12;

      double progressRatio = (memorizedVerses / targetVerses).clamp(0.0, 1.0);
      int percentage = (progressRatio * 100).toInt();

      expect(progressRatio, equals(1.0));
      expect(percentage, equals(100));
    });
  });
}

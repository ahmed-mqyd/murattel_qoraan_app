import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:murattel_qoraan_app/core/location_services/location_services.dart';

class QiblaController extends GetxController {
  final currentHeading = 0.0.obs;
  final qiblaAngle = 135.0.obs;
  final selectedCity = 'jerusalem'.obs; // Key identifier
  final isAligned = false.obs;
  final distanceToKaaba = ''.obs;
  final isLoadingLocation = false.obs;
  final gpsCoords = ''.obs;
  final hasRealCompassSensor = false.obs;
  // تتأكد أن الجهاز لا يملك بوصلة فعلية (لا event ولا حتى Stream)، بعد مهلة
  // انتظار قصيرة — تُستخدم لعرض تحذير للمستخدم ولمنع الاعتماد على بيانات وهمية.
  final compassUnavailable = false.obs;
  final sensorAccuracy = 0.0.obs;

  // Coordinates of Kaaba
  final double kaabaLat = 21.422487;
  final double kaabaLng = 39.826206;

  final List<Map<String, dynamic>> cities = [
    {'key': 'jerusalem', 'lat': 31.768319, 'lng': 35.21371},
    {'key': 'gaza', 'lat': 31.508493, 'lng': 34.466844},
    {'key': 'cairo', 'lat': 30.044420, 'lng': 31.235712},
    {'key': 'madinah', 'lat': 24.467210, 'lng': 39.611172},
    {'key': 'riyadh', 'lat': 24.713552, 'lng': 46.675296},
    {'key': 'mecca', 'lat': 21.422487, 'lng': 39.826206},
    {'key': 'gpsCurrentLocation', 'lat': 0.0, 'lng': 0.0},
  ];

  Timer? _fluctuationTimer;
  Timer? _autoRotateTimer;
  Timer? _compassAvailabilityCheckTimer;
  StreamSubscription<CompassEvent>? _compassSubscription;
  final autoRotate = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startFluctuation();
    _initCompassStream();
    // Initially compute for Jerusalem
    calculateQibla(31.768319, 35.21371);
  }

  @override
  void onClose() {
    _fluctuationTimer?.cancel();
    _autoRotateTimer?.cancel();
    _compassAvailabilityCheckTimer?.cancel();
    _compassSubscription?.cancel();
    super.onClose();
  }

  void _initCompassStream() {
    final compassEvents = FlutterCompass.events;
    if (compassEvents == null) {
      // الجهاز لا يملك حساس بوصلة إطلاقاً (Stream نفسه null)
      _markCompassUnavailable();
      return;
    }

    _compassSubscription = compassEvents.listen((CompassEvent event) {
      if (event.heading != null) {
        hasRealCompassSensor.value = true;
        compassUnavailable.value = false;
        _fluctuationTimer?.cancel();
        _compassAvailabilityCheckTimer?.cancel();
        updateHeading(event.heading!);
        if (event.accuracy != null) {
          sensorAccuracy.value = event.accuracy!;
        }
      }
    }, onError: (_) => _markCompassUnavailable());

    // بعض الأجهزة تُرجع Stream غير null لكنها لا تصدر أي قراءة أبداً
    // (حساس معطوب أو محظور) — نعتبرها غير متاحة بعد مهلة انتظار قصيرة.
    _compassAvailabilityCheckTimer = Timer(const Duration(seconds: 3), () {
      if (!hasRealCompassSensor.value) {
        _markCompassUnavailable();
      }
    });
  }

  void _markCompassUnavailable() {
    compassUnavailable.value = true;
    _fluctuationTimer?.cancel();
    // نعيد المؤشر لنقطة بداية واضحة (الشمال) بدل تجميده على قيمة عشوائية
    currentHeading.value = 0.0;
    checkAlignment();
  }

  void _startFluctuation() {
    // Add tiny sensor fluctuations to make the compass feel realistic and alive
    _fluctuationTimer = Timer.periodic(const Duration(milliseconds: 150), (
      timer,
    ) {
      if (!autoRotate.value) {
        final randomOffset = (Random().nextDouble() - 0.5) * 0.8;
        currentHeading.value =
            (currentHeading.value + randomOffset + 360) % 360;
        checkAlignment();
      }
    });
  }

  void toggleAutoRotate() {
    autoRotate.value = !autoRotate.value;
    if (autoRotate.value) {
      _autoRotateTimer?.cancel();
      _autoRotateTimer = Timer.periodic(const Duration(milliseconds: 50), (
        timer,
      ) {
        currentHeading.value = (currentHeading.value + 2.0) % 360;
        checkAlignment();
        if (isAligned.value) {
          // Pause briefly when aligned
          autoRotate.value = false;
          _autoRotateTimer?.cancel();
          HapticFeedback.heavyImpact();
        }
      });
    } else {
      _autoRotateTimer?.cancel();
    }
  }

  Future<void> setCity(String cityKey) async {
    if (cityKey == 'gpsCurrentLocation') {
      await fetchLiveLocation();
    } else {
      final city = cities.firstWhere((c) => c['key'] == cityKey);
      selectedCity.value = cityKey;
      gpsCoords.value = '';
      calculateQibla(city['lat'] as double, city['lng'] as double);
    }
  }

  Future<void> fetchLiveLocation() async {
    isLoadingLocation.value = true;
    try {
      bool serviceEnabled =
          await LocationServices.checkAndPromptLocationService();
      if (!serviceEnabled) {
        isLoadingLocation.value = false;
        return;
      }

      LocationPermission permission =
          await LocationServices.checkAndRequestPermission();
      if (permission == LocationPermission.denied) {
        isLoadingLocation.value = false;
        Get.snackbar(
          'تنبيه الصلاحيات',
          'تم رفض إذن الوصول إلى الموقع الجغرافي.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        isLoadingLocation.value = false;
        Get.snackbar(
          'تنبيه الصلاحيات',
          'صلاحيات الموقع مرفوضة دائماً، يرجى تفعيلها من إعدادات الهاتف.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final Position? position = await LocationServices.determinePosition(
        accuracy: LocationAccuracy.high,
      );

      if (position == null) {
        throw Exception('Failed to obtain GPS lock');
      }

      selectedCity.value = 'gpsCurrentLocation';

      // Update coordinates readout
      final String latStr = position.latitude.toStringAsFixed(4);
      final String lngStr = position.longitude.toStringAsFixed(4);
      gpsCoords.value = toArabicNumbers('خط عرض: $latStr، خط طول: $lngStr');

      calculateQibla(position.latitude, position.longitude);
    } catch (e) {
      Get.snackbar(
        'خطأ الموقع',
        'حدث خطأ أثناء محاولة جلب الموقع الجغرافي: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void calculateQibla(double lat, double lng) {
    // 1. Calculate Qibla bearing angle
    qiblaAngle.value = getQiblaAngleForCoords(lat, lng);

    // 2. Calculate real geodesic distance using WGS84 ellipsoid
    final double distanceMeters = Geolocator.distanceBetween(
      lat,
      lng,
      kaabaLat,
      kaabaLng,
    );
    final double distanceKm = distanceMeters / 1000.0;

    distanceToKaaba.value = formatDistance(distanceKm);
    checkAlignment();
  }

  double getQiblaAngleForCoords(double lat, double lng) {
    final double userLatRad = lat * pi / 180;
    final double userLngRad = lng * pi / 180;
    final double kaabaLatRad = kaabaLat * pi / 180;
    final double kaabaLngRad = kaabaLng * pi / 180;

    final double diffLng = kaabaLngRad - userLngRad;

    final double y = sin(diffLng);
    final double x =
        cos(userLatRad) * tan(kaabaLatRad) - sin(userLatRad) * cos(diffLng);

    double qiblaRad = atan2(y, x);
    double qiblaDeg = qiblaRad * 180 / pi;

    return (qiblaDeg + 360) % 360;
  }

  double getAngleForCity(Map<String, dynamic> city) {
    if (city['key'] == 'gpsCurrentLocation') {
      if (selectedCity.value == 'gpsCurrentLocation') {
        return qiblaAngle.value;
      }
      return 0.0;
    }
    return getQiblaAngleForCoords(city['lat'] as double, city['lng'] as double);
  }

  String getDistanceForCity(Map<String, dynamic> city) {
    if (city['key'] == 'gpsCurrentLocation') {
      if (selectedCity.value == 'gpsCurrentLocation') {
        return distanceToKaaba.value;
      }
      return 'تحديد تلقائي';
    }
    final double dist =
        Geolocator.distanceBetween(
          city['lat'] as double,
          city['lng'] as double,
          kaabaLat,
          kaabaLng,
        ) /
        1000.0;
    return formatDistance(dist);
  }

  void updateHeading(double angle) {
    currentHeading.value = (angle + 360) % 360;
    checkAlignment();
  }

  void checkAlignment() {
    final diff = (currentHeading.value - qiblaAngle.value).abs();
    final normalizedDiff = diff > 180 ? 360 - diff : diff;
    final aligned = normalizedDiff <= 3.0; // aligned if within 3 degrees

    if (aligned && !isAligned.value) {
      HapticFeedback.mediumImpact();
    }
    isAligned.value = aligned;
  }

  String getCardinalDirectionName(double angle) {
    angle = (angle + 360) % 360;
    if (angle >= 337.5 || angle < 22.5) {
      return 'شمالاً';
    } else if (angle >= 22.5 && angle < 67.5) {
      return 'شمالاً شرقاً';
    } else if (angle >= 67.5 && angle < 112.5) {
      return 'شرقاً';
    } else if (angle >= 112.5 && angle < 157.5) {
      return 'جنوباً شرقاً';
    } else if (angle >= 157.5 && angle < 202.5) {
      return 'جنوباً';
    } else if (angle >= 202.5 && angle < 247.5) {
      return 'جنوباً غرباً';
    } else if (angle >= 247.5 && angle < 292.5) {
      return 'غرباً';
    } else {
      return 'شمالاً غرباً';
    }
  }

  String getTurnInstruction() {
    if (isAligned.value) {
      return 'متحاذي تماماً مع القبلة (باتجاه الكعبة المشرفة)';
    }
    double diff = qiblaAngle.value - currentHeading.value;
    diff = (diff + 180) % 360 - 180;

    final int degrees = diff.abs().round();
    if (diff > 0) {
      return 'أدر الهاتف ${toArabicNumbers(degrees.toString())}° يميناً';
    } else {
      return 'أدر الهاتف ${toArabicNumbers(degrees.toString())}° يساراً';
    }
  }

  // Format helper to translate numbers into Arabic representation
  String toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '٫'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  String formatDistance(double distance) {
    if (distance < 0.05) {
      return 'أنت في الكعبة المشرفة';
    }
    if (distance < 1.0) {
      int meters = (distance * 1000).round();
      return toArabicNumbers('$meters م');
    }
    int km = distance.round();
    String kmStr = km.toString();
    if (kmStr.length > 3) {
      kmStr =
          '${kmStr.substring(0, kmStr.length - 3)},${kmStr.substring(kmStr.length - 3)}';
    }
    return toArabicNumbers('$kmStr كم');
  }
}

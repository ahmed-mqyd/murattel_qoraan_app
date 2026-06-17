import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murattel_qoraan_app/core/location_services/location_services.dart';
import 'package:murattel_qoraan_app/core/notification_services/notification_services.dart';

class PrayerTimesController extends GetxController {
  final isLoading = true.obs;
  final prayerTimes = <String, String>{}.obs;
  final nextPrayerName = ''.obs;
  final nextPrayerTime = ''.obs;
  final locationName = 'جاري تحديد الموقع...'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrayerTimes();
  }

  Future<void> fetchPrayerTimes({bool forceRefresh = false}) async {
    isLoading.value = true;
    final prefs = Get.find<SharedPreferences>();
    final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final cachedDate = prefs.getString('cached_prayer_date') ?? '';
    final cachedTimesStr = prefs.getString('cached_prayer_times');

    // 1. If cached prayer times are valid for today, and not forcing a refresh, just load them.
    if (!forceRefresh && cachedTimesStr != null && cachedDate == todayStr) {
      _loadLocalCachedData(prefs);
      isLoading.value = false;
      return;
    }

    try {
      double? latitude = prefs.getDouble('cached_latitude');
      double? longitude = prefs.getDouble('cached_longitude');
      String cityName = prefs.getString('cached_city_name') ?? '';

      // 2. If we don't have cached coordinates OR we are forcing a refresh, request location via GPS.
      if (forceRefresh || latitude == null || longitude == null) {
        // Request location permission first
        await LocationServices.checkAndRequestPermission();

        // Check and prompt location service enablement
        await LocationServices.checkAndPromptLocationService();

        // Retrieve GPS position using centralized LocationServices
        final Position? position = await LocationServices.determinePosition(
          accuracy: LocationAccuracy.high,
          timeout: const Duration(seconds: 10),
        );

        // If we got a fresh position, update cache coordinates and fetch city name
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
          await prefs.setDouble('cached_latitude', latitude);
          await prefs.setDouble('cached_longitude', longitude);

          cityName = await LocationServices.getCityName(latitude, longitude);
          if (cityName.isNotEmpty) {
            await prefs.setString('cached_city_name', cityName);
          }
        }
      }

      // If we still don't have coordinates (failed to fetch and no cached values), return.
      if (latitude == null || longitude == null) {
        locationName.value = 'يرجى تفعيل الموقع والاتصال بالإنترنت لأول مرة';
        _loadLocalCachedData(prefs);
        isLoading.value = false;
        return;
      }

      // 3. Fetch from API using coordinates
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$date?latitude=$latitude&longitude=$longitude&method=4',
      );

      try {
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final timings = data['data']['timings'];
          final timezone = data['data']['meta']['timezone'] ?? '';

          final String displayLoc = cityName.isNotEmpty
              ? cityName
              : 'موقعك الحالي ($timezone)';

          prayerTimes.value = {
            'الفجر': _formatTime(timings['Fajr']),
            'الشروق': _formatTime(timings['Sunrise']),
            'الظهر': _formatTime(timings['Dhuhr']),
            'العصر': _formatTime(timings['Asr']),
            'المغرب': _formatTime(timings['Maghrib']),
            'العشاء': _formatTime(timings['Isha']),
          };

          _calculateNextPrayer(timings);
          locationName.value = displayLoc;

          // Schedule Notifications with Athan Sound
          NotificationServices.schedulePrayerNotifications(
            Map<String, String>.from(timings),
          );

          // Save timings, locName, and date to local cache
          await prefs.setString('cached_prayer_times', jsonEncode(timings));
          await prefs.setString('cached_location_name', displayLoc);
          await prefs.setString('cached_prayer_date', date);
        } else {
          _loadLocalCachedData(prefs);
        }
      } catch (apiError) {
        debugPrint('API Error: $apiError');
        _loadLocalCachedData(prefs);
      }
    } catch (e) {
      debugPrint('General Error in fetchPrayerTimes: $e');
      _loadLocalCachedData(prefs);
    } finally {
      isLoading.value = false;
    }
  }

  void _loadLocalCachedData(SharedPreferences prefs) {
    final cachedTimesStr = prefs.getString('cached_prayer_times');
    final cachedLoc = prefs.getString('cached_location_name');
    final cachedDate = prefs.getString('cached_prayer_date') ?? '';

    if (cachedTimesStr != null) {
      final Map<String, dynamic> timings = jsonDecode(cachedTimesStr);
      prayerTimes.value = {
        'الفجر': _formatTime(timings['Fajr']),
        'الشروق': _formatTime(timings['Sunrise']),
        'الظهر': _formatTime(timings['Dhuhr']),
        'العصر': _formatTime(timings['Asr']),
        'المغرب': _formatTime(timings['Maghrib']),
        'العشاء': _formatTime(timings['Isha']),
      };
      _calculateNextPrayer(timings);

      // Schedule Notifications with Athan Sound from cache
      NotificationServices.schedulePrayerNotifications(
        Map<String, String>.from(timings),
      );

      final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
      if (cachedDate == todayStr) {
        locationName.value = cachedLoc ?? 'موقعك الحالي (محفوظ)';
      } else {
        locationName.value = '${cachedLoc ?? 'موقعك الحالي'} (بيانات سابقة)';
      }
    } else {
      locationName.value = 'لا توجد بيانات محفوظة. يرجى الاتصال بالإنترنت';
    }
  }

  String _formatTime(String time) {
    time;
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var temp = time;
    for (var i = 0; i < english.length; i++) {
      temp = temp.replaceAll(english[i], arabic[i]);
    }
    return temp;
  }

  void _calculateNextPrayer(Map<String, dynamic> timings) {
    final now = DateTime.now();
    final format = DateFormat('HH:mm');

    final prayers = [
      {'name': 'الفجر', 'time': timings['Fajr']},
      {'name': 'الظهر', 'time': timings['Dhuhr']},
      {'name': 'العصر', 'time': timings['Asr']},
      {'name': 'المغرب', 'time': timings['Maghrib']},
      {'name': 'العشاء', 'time': timings['Isha']},
    ];

    for (var prayer in prayers) {
      final prayerTime = format.parse(prayer['time']!);
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayerTime.hour,
        prayerTime.minute,
      );

      if (prayerDateTime.isAfter(now)) {
        nextPrayerName.value = prayer['name']!;
        nextPrayerTime.value = _formatTime(prayer['time']!);
        return;
      }
    }

    // If all prayers passed, next is tomorrow's Fajr
    nextPrayerName.value = 'الفجر';
    nextPrayerTime.value = _formatTime(timings['Fajr']);
  }
}

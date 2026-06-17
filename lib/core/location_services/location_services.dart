import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationServices {
  /// Checks and requests location permission.
  static Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Checks if location services are enabled on the device.
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Checks if location services are enabled.
  /// If not, displays a friendly dialog prompting the user to open system settings.
  static Future<bool> checkAndPromptLocationService() async {
    final bool enabled = await isLocationServiceEnabled();
    if (!enabled) {
      final isAr = Get.locale?.languageCode == 'ar';
      await Get.defaultDialog(
        title: isAr ? 'تفعيل الموقع الجغرافي' : 'Enable Location Services',
        middleText: isAr
            ? 'خدمات الموقع الجغرافي (GPS) معطلة على هاتفك. يرجى تفعيلها للحصول على مواقيت الصلاة والقبلة بدقة.'
            : 'GPS location services are disabled. Please enable them to get accurate prayer times and Qibla.',
        textConfirm: isAr ? 'الذهاب للإعدادات' : 'Go to Settings',
        textCancel: isAr ? 'إلغاء' : 'Cancel',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFC5A059), // Gold color
        onConfirm: () async {
          Get.back(); // Close dialog
          await Geolocator.openLocationSettings();
        },
      );
      return false;
    }
    return true;
  }

  /// Attempts to get the current phone coordinates with the specified accuracy and timeout.
  /// Automatically falls back to the last known position on failure.
  static Future<Position?> determinePosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Fallback to last known position even if services are off, in case it is cached
        try {
          return await Geolocator.getLastKnownPosition();
        } catch (_) {
          return null;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout,
        ),
      );
    } catch (e) {
      debugPrint('Error determining position: $e');
      
      // Fallback to last known position
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Gets the city name from coordinates using reverse geocoding API.
  static Future<String> getCityName(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lng&localityLanguage=ar',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final city = data['city'] as String?;
        final locality = data['locality'] as String?;
        final subdivision = data['principalSubdivision'] as String?;
        
        if (city != null && city.isNotEmpty) return city;
        if (locality != null && locality.isNotEmpty) return locality;
        if (subdivision != null && subdivision.isNotEmpty) return subdivision;
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
    return '';
  }
}
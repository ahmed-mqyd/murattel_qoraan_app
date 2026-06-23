import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('test fallback models', () async {
    final String apiKey = 'AQ.Ab8RN6JvhKgZRgVaxgL_B7r00prHb2JcqzPUgUI7_IKkEnDaMw'; 
    
    // List of models to test
    final models = ['gemini-1.5-flash', 'gemini-2.0-flash', 'gemini-2.5-flash'];
    
    for (var model in models) {
      final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
      try {
        final response = await http.post(
          Uri.parse('$apiUrl?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [{'parts': [{'text': 'hi'}]}]
          }),
        );
        debugPrint('Model: $model, Status: ${response.statusCode}, Body: ${response.body.substring(0, 80)}...');
      } catch (e) {
        debugPrint('Model $model failed: $e');
      }
    }
  });
}

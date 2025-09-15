import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('API Integration Tests', () {
    test('Gemini API should respond successfully', () async {
      const String apiKey = 'AIzaSyCR_ZOtSEaG4OFm9gCqthV-cqyFqeSBBWU';
      const String baseUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'You are an expert farming assistant. Provide helpful advice about wheat farming. User question: What is the best time to plant wheat in North India?',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      expect(response.statusCode, equals(200));

      final data = jsonDecode(response.body);
      expect(data, isNotNull);
      expect(data['candidates'], isNotNull);
      expect(data['candidates'][0]['content']['parts'][0]['text'], isNotEmpty);
    });

    test('OpenWeather API should respond successfully', () async {
      const String apiKey = '9b02c225a1d5d8ff85adcdc1fa0127c2';
      const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

      final response = await http.get(
        Uri.parse('$baseUrl?q=Delhi,IN&appid=$apiKey&units=metric'),
      );

      expect(response.statusCode, equals(200));

      final data = jsonDecode(response.body);
      expect(data, isNotNull);
      expect(data['name'], equals('Delhi'));
      expect(data['main']['temp'], isA<double>());
      expect(data['weather'][0]['description'], isNotEmpty);
      expect(data['main']['humidity'], isA<int>());
    });
  });
}

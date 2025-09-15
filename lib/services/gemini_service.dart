import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyCR_ZOtSEaG4OFm9gCqthV-cqyFqeSBBWU';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<String> sendMessage(String message) async {
    try {
      return await _callGeminiAPI(message);
    } catch (e) {
      // Fallback to simulated response if API fails
      return _simulateGeminiResponse(message);
    }
  }

  Future<String> _callGeminiAPI(String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'You are an expert farming assistant. Provide helpful, accurate advice about farming, agriculture, crops, and related topics. Keep responses concise but informative. User question: $message',
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception(
        'Failed to get response from Gemini API: ${response.statusCode}',
      );
    }
  }

  // Simulated responses for demonstration
  String _simulateGeminiResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('weather') ||
        lowerMessage.contains('rain') ||
        lowerMessage.contains('temperature')) {
      return "Based on current weather conditions, I recommend:\n\n• Monitor soil moisture levels regularly\n• Consider adjusting irrigation schedules\n• Protect crops from extreme weather if needed\n• Check weather forecasts for the next 5-7 days for planning\n\nWould you like specific advice for your crop type?";
    }

    if (lowerMessage.contains('disease') ||
        lowerMessage.contains('pest') ||
        lowerMessage.contains('insect')) {
      return "For crop disease and pest management:\n\n• Early detection is crucial - inspect crops regularly\n• Use integrated pest management (IPM) techniques\n• Consider organic solutions first\n• Ensure proper crop rotation\n• Maintain good field hygiene\n\nCan you describe the symptoms you're seeing? I can provide more specific guidance.";
    }

    if (lowerMessage.contains('fertilizer') ||
        lowerMessage.contains('nutrient') ||
        lowerMessage.contains('soil')) {
      return "For optimal soil and nutrient management:\n\n• Test your soil pH and nutrient levels\n• Use organic compost when possible\n• Apply fertilizers based on soil test results\n• Consider split applications for better efficiency\n• Monitor plant growth for nutrient deficiency signs\n\nWhat type of crops are you growing? I can suggest specific fertilizer recommendations.";
    }

    if (lowerMessage.contains('irrigation') ||
        lowerMessage.contains('water') ||
        lowerMessage.contains('watering')) {
      return "Smart irrigation practices:\n\n• Water early morning or late evening to reduce evaporation\n• Use drip irrigation for water efficiency\n• Monitor soil moisture at root depth\n• Adjust watering based on crop growth stage\n• Consider rainwater harvesting\n\nWhat's your current irrigation method? I can suggest improvements.";
    }

    if (lowerMessage.contains('harvest') ||
        lowerMessage.contains('crop timing') ||
        lowerMessage.contains('when to harvest')) {
      return "Harvest timing is critical for quality and yield:\n\n• Monitor crop maturity indicators specific to your crop\n• Check market prices before harvesting\n• Ensure proper storage facilities are ready\n• Plan labor requirements in advance\n• Consider weather conditions for harvesting\n\nWhich crop are you planning to harvest? I can provide specific timing guidance.";
    }

    if (lowerMessage.contains('market') ||
        lowerMessage.contains('price') ||
        lowerMessage.contains('sell')) {
      return "For better market outcomes:\n\n• Monitor market trends regularly\n• Consider value-added processing\n• Explore direct-to-consumer sales\n• Join farmer cooperatives for better prices\n• Time your sales based on demand patterns\n\nWhat crops are you looking to sell? I can suggest market strategies.";
    }

    // Default farming advice
    return "I'm here to help with all your farming questions! I can assist with:\n\n🌱 Crop management and planning\n🐛 Pest and disease control\n💧 Irrigation and water management\n🌡️ Weather-related farming advice\n🌾 Harvest timing and techniques\n💰 Market strategies\n🧪 Soil health and fertilization\n\nWhat specific farming challenge would you like help with today?";
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GeminiService {
  // Dedicated Gemini AI API key
  static const String _apiKey = 'AIzaSyDh38YuDNlxZouReiVEu90Cmd2EGgCRtCU';

  // Available Gemini models (Flash models are faster and more cost-effective)
  static const String _model =
      'gemini-2.5-flash'; // Latest Gemini 2.5 Flash model with consistent API

  // Speech-to-text and TTS instances
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isListening = false;
  String _currentLocale = 'en-US';

  // Supported languages for voice input
  static const Map<String, String> supportedLanguages = {
    'en-US': 'English',
    'hi-IN': 'हिंदी',
    'bn-IN': 'বাংলা',
    'te-IN': 'తెలుగు',
    'mr-IN': 'मराठी',
    'ta-IN': 'தமிழ்',
    'gu-IN': 'ગુજરાતી',
    'kn-IN': 'ಕನ್ನಡ',
    'or-IN': 'ଓଡ଼ିଆ',
    'pa-IN': 'ਪੰਜਾਬੀ',
  };

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get currentLocale => _currentLocale;
  List<String> get availableLanguages => supportedLanguages.keys.toList();

  /// Initialize speech services
  Future<bool> initializeSpeech() async {
    try {
      // Request microphone permission
      final permissionStatus = await Permission.microphone.request();
      if (permissionStatus != PermissionStatus.granted) {
        debugPrint('Microphone permission denied');
        return false;
      }

      // Initialize speech to text
      _isInitialized = await _speechToText.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          _isListening = status == 'listening';
        },
        onError: (error) {
          debugPrint('Speech error: $error');
          _isListening = false;
        },
      );

      // Initialize text to speech
      await _initializeTts();

      debugPrint('Speech service initialized: $_isInitialized');
      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing speech service: $e');
      return false;
    }
  }

  /// Initialize Text-to-Speech
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(_currentLocale);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  /// Set the current language for speech recognition and TTS
  Future<void> setLanguage(String localeId) async {
    if (supportedLanguages.containsKey(localeId)) {
      _currentLocale = localeId;
      await _flutterTts.setLanguage(localeId);
      debugPrint('Language set to: $localeId');
    }
  }

  /// Start listening for speech input
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      bool initialized = await initializeSpeech();
      if (!initialized) {
        onError?.call('Speech service not initialized');
        return;
      }
    }

    // Stop any existing listening session first
    if (_isListening || _speechToText.isListening) {
      debugPrint('Stopping existing listening session');
      await _speechToText.stop();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (_isListening) {
      debugPrint('Still listening after stop attempt');
      return;
    }

    try {
      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          final recognizedText = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            onResult(recognizedText);
            debugPrint('Final result: $recognizedText');
          } else {
            onPartialResult?.call(recognizedText);
            debugPrint('Partial result: $recognizedText');
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: _currentLocale,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    } catch (e) {
      onError?.call('Error starting speech recognition: $e');
      debugPrint('Error starting listening: $e');
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      debugPrint('Stopped listening');
    }
  }

  /// Cancel current listening session
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speechToText.cancel();
      _isListening = false;
      debugPrint('Cancelled listening');
    }
  }

  /// Speak text using TTS
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
      debugPrint('Speaking: $text');
    } catch (e) {
      debugPrint('Error speaking text: $e');
    }
  }

  /// Stop TTS if currently speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      debugPrint('Stopped speaking');
    } catch (e) {
      debugPrint('Error stopping speech: $e');
    }
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<String> sendMessage(String message) async {
    try {
      // Validate input
      if (message.trim().isEmpty) {
        return "Please provide a farming-related question and I'll be happy to help!";
      }

      // Try the primary API call with fallback
      final response = await _callGeminiAPIWithFallback(message);
      debugPrint('✅ Gemini API response received successfully');
      return response;
    } catch (e) {
      debugPrint('❌ Gemini API error: $e');

      // Check specific error types
      final errorString = e.toString();

      if (errorString.contains('401') || errorString.contains('403')) {
        return "🔑 Authentication issue: Please check the API key configuration and try again.";
      } else if (errorString.contains('429')) {
        return "⏱️ Rate limit exceeded: Please wait a moment before making another request.";
      } else if (errorString.contains('404')) {
        return "🔧 Model not found: The AI model may be temporarily unavailable.";
      } else if (errorString.contains('400')) {
        return "📝 Invalid request: Please try rephrasing your question.";
      } else if (errorString.contains('TimeoutException') ||
          errorString.contains('SocketException') ||
          errorString.contains('network')) {
        return "🌐 Connection issue: Please check your internet connection and try again.";
      } else if (errorString.contains('Invalid response structure')) {
        // This is our specific error - provide helpful message
        return "🔧 Technical issue: The AI service response format has changed. The response was received but couldn't be processed correctly. This is a temporary issue that should resolve itself.";
      }

      // Only use simulation as last resort with clear indication
      debugPrint('🔄 Falling back to simulated response due to: $errorString');
      final simulatedResponse = _simulateGeminiResponse(message);
      return "⚡ Demo Mode Active: $simulatedResponse";
    }
  }

  /// Try alternative models if the primary one fails
  Future<String> _callGeminiAPIWithFallback(String message) async {
    final modelsToTry = [
      'gemini-2.5-flash',
      'gemini-2.5-pro',
      'gemini-2.0-flash',
    ];

    for (int i = 0; i < modelsToTry.length; i++) {
      try {
        final model = modelsToTry[i];
        debugPrint(
          '🔄 Trying model: $model (attempt ${i + 1}/${modelsToTry.length})',
        );

        final response = await _callGeminiAPIWithModel(message, model);
        if (response.isNotEmpty) {
          debugPrint('✅ Success with model: $model');
          return response;
        }
      } catch (e) {
        debugPrint('❌ Model $modelsToTry[i] failed: $e');
        if (i == modelsToTry.length - 1) {
          // Last model failed, re-throw the error
          rethrow;
        }
      }
    }

    throw Exception('All fallback models failed');
  }

  Future<String> _callGeminiAPI(String message) async {
    return _callGeminiAPIWithModel(message, _model);
  }

  Future<String> _callGeminiAPIWithModel(
    String message,
    String modelName,
  ) async {
    debugPrint(
      '🚀 Calling Gemini API with model: $modelName, message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...',
    );

    // Construct farming-specific prompt
    final systemPrompt =
        'You are an expert farming assistant specializing in agriculture, crops, livestock, and sustainable farming practices. Provide helpful, accurate advice based on modern agricultural science and traditional farming wisdom. Keep responses informative but concise (under 300 words). Always be encouraging and supportive to farmers.';
    final fullPrompt = '$systemPrompt\n\nUser question: $message';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': fullPrompt},
          ],
          'role': 'user',
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens':
            2048, // Increased limit for detailed agricultural responses
        'candidateCount': 1,
        'stopSequences': [],
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
      ],
    };

    debugPrint('📡 Making HTTP request to Gemini API...');

    final apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent';

    final response = await http
        .post(
          Uri.parse('$apiUrl?key=$_apiKey'),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-client': 'flutter-app/1.0.0',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint('📨 API Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('✅ API Response received successfully');
      debugPrint('📊 Full API Response: $data');

      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final candidate = data['candidates'][0];
        debugPrint('🔍 Full candidate data: $candidate');

        // Handle different response structures
        String? responseText;

        // Try new format first (with parts array)
        if (candidate['content'] != null &&
            candidate['content']['parts'] != null &&
            candidate['content']['parts'].isNotEmpty &&
            candidate['content']['parts'][0]['text'] != null) {
          responseText = candidate['content']['parts'][0]['text'];
          debugPrint('✅ Found text in parts[0].text');
        }
        // Try alternative format (direct text in content)
        else if (candidate['content'] != null &&
            candidate['content']['text'] != null) {
          responseText = candidate['content']['text'];
          debugPrint('✅ Found text in content.text');
        }
        // Try direct text in candidate
        else if (candidate['text'] != null) {
          responseText = candidate['text'];
          debugPrint('✅ Found text in candidate.text');
        }
        // Handle case where content is a string
        else if (candidate['content'] is String) {
          responseText = candidate['content'];
          debugPrint('✅ Found text as string content');
        }
        // Handle new Gemini 2.5 response format where parts might be missing
        else if (candidate['content'] != null &&
            candidate['content'] is Map &&
            candidate['content']['role'] == 'model') {
          // This seems to be the issue - content has role but no parts
          debugPrint(
            '⚠️ New response format detected: content has role but no parts',
          );
          debugPrint('🔍 Trying to find text in other locations...');

          // Check if there's text elsewhere in the response
          if (data.toString().contains('text":')) {
            // Try to extract text from the raw response
            final responseStr = data.toString();
            final textMatch = RegExp(
              r'"text":\s*"([^"]+)"',
            ).firstMatch(responseStr);
            if (textMatch != null) {
              responseText = textMatch.group(1);
              debugPrint('✅ Extracted text using regex');
            }
          }
        }

        if (responseText != null && responseText.isNotEmpty) {
          debugPrint('📝 Response text length: ${responseText.length}');
          return responseText.trim();
        } else {
          debugPrint('⚠️ No valid text found in API response');
          debugPrint('🔍 Candidate structure: ${candidate.keys}');
          if (candidate['content'] != null) {
            debugPrint(
              '🔍 Content structure: ${candidate['content'].runtimeType} - ${candidate['content']}',
            );
          }
          debugPrint('🔍 Full response for debugging: $data');
        }
      }

      // If we get here, the response structure is unexpected
      debugPrint('⚠️ Unexpected API response structure: $data');

      // Check if there's a usage limit or content policy issue
      if (data['error'] != null) {
        final error = data['error'];
        debugPrint('❌ API Error in response: $error');
        throw Exception(
          'Gemini API Error: ${error['message'] ?? 'Unknown error'}',
        );
      }

      // Check for finish reason that might indicate issues
      if (data['candidates'] != null &&
          data['candidates'].isNotEmpty &&
          data['candidates'][0]['finishReason'] != null) {
        final finishReason = data['candidates'][0]['finishReason'];
        if (finishReason == 'MAX_TOKENS') {
          debugPrint('! Response hit MAX_TOKENS limit');
          // The Gemini 2.5 API sometimes returns empty content with MAX_TOKENS
          // This indicates the response was cut off before any content was generated
          // Return a helpful message asking for a more specific question
          return "I apologize, but my response was cut short due to length limits. Please ask for a more specific question, and I'll provide a focused answer.";
        } else if (finishReason == 'SAFETY') {
          return "I cannot provide a response to this query due to safety guidelines. Please rephrase your question about farming or agricultural topics.";
        }
      }

      throw Exception('Invalid response structure from Gemini API');
    } else {
      final errorBody = response.body;
      debugPrint('❌ API Error: ${response.statusCode} - $errorBody');

      // Try to extract error details
      try {
        final errorData = jsonDecode(errorBody);
        if (errorData['error'] != null) {
          final error = errorData['error'];
          final message = error['message'] ?? 'Unknown error';
          final status = error['status'] ?? 'UNKNOWN';
          throw Exception('Gemini API Error ($status): $message');
        }
      } catch (e) {
        // If we can't parse the error, use the raw response
      }

      throw Exception('Gemini API Error ${response.statusCode}: $errorBody');
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

  /// Test API connection and key validity
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Testing Gemini API connection...');
      await _callGeminiAPI('Hello, can you respond?');
      debugPrint('✅ API connection test successful');
      return true;
    } catch (e) {
      debugPrint('❌ API connection test failed: $e');
      return false;
    }
  }

  /// Check if API key is configured
  bool isApiKeyConfigured() {
    final isConfigured =
        _apiKey.isNotEmpty && _apiKey != 'YOUR_GEMINI_API_KEY_HERE';
    debugPrint('🔑 API Key configured: $isConfigured');
    return isConfigured;
  }

  /// Get current model being used
  String getCurrentModel() {
    return _model;
  }

  /// List available Gemini models
  Future<List<Map<String, String>>> getAvailableModels() async {
    try {
      debugPrint('📋 Fetching available models...');
      final response = await http
          .get(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = <Map<String, String>>[];

        if (data['models'] != null) {
          for (final model in data['models']) {
            final modelName = model['name'].toString();
            if (modelName.contains('gemini') &&
                !modelName.contains('embedding') &&
                !modelName.contains('aqa') &&
                !modelName.contains('imagen')) {
              models.add({
                'name': modelName.replaceFirst('models/', ''),
                'displayName': model['displayName']?.toString() ?? '',
                'description': model['description']?.toString() ?? '',
              });
            }
          }
        }

        debugPrint('✅ Found ${models.length} available Gemini models');
        return models;
      } else {
        debugPrint('❌ Failed to fetch models: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching models: $e');
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    debugPrint('Gemini service disposed');
  }
}

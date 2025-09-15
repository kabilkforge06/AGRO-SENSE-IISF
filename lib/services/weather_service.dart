import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'location_service.dart';
import 'package:geolocator/geolocator.dart';

class WeatherData {
  final double temperature;
  final String description;
  final String main;
  final int humidity;
  final double windSpeed;
  final String cityName;
  final String icon;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.main,
    required this.humidity,
    required this.windSpeed,
    required this.cityName,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      main: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      cityName: json['name'],
      icon: json['weather'][0]['icon'],
    );
  }
}

class WeatherService {
  static const String _apiKey = '9b02c225a1d5d8ff85adcdc1fa0127c2';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData> getWeatherByLocation(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      return _getFallbackWeather(
        cityName:
            'Location (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})',
      );
    }
  }

  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=$cityName&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      return _getFallbackWeather();
    }
  }

  Future<WeatherData> getFarmingWeather({
    double? latitude,
    double? longitude,
  }) async {
    if (latitude != null && longitude != null) {
      return await getWeatherByLocation(latitude, longitude);
    } else {
      return await getWeatherByCity('Delhi,IN');
    }
  }

  // Get weather based on current GPS location
  Future<WeatherData?> getWeatherByCurrentLocation() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        return await getWeatherByLocation(
          position.latitude,
          position.longitude,
        );
      }

      // Fallback to last known location
      Position? lastKnown = await LocationService.getLastKnownLocation();
      if (lastKnown != null) {
        return await getWeatherByLocation(
          lastKnown.latitude,
          lastKnown.longitude,
        );
      }

      return null;
    } catch (e) {
      developer.log('Error getting weather by current location: $e');
      return null;
    }
  }

  WeatherData _getFallbackWeather({String? cityName}) {
    return WeatherData(
      temperature: 28.0,
      description: 'partly cloudy',
      main: 'Clouds',
      humidity: 65,
      windSpeed: 12.0,
      cityName: cityName ?? 'Delhi',
      icon: '02d',
    );
  }

  String getFarmingAdvice(WeatherData weather) {
    if (weather.main.toLowerCase().contains('rain')) {
      return '🌧️ Good time for planting! Ensure proper drainage.';
    } else if (weather.temperature > 35) {
      return '🌡️ Hot weather - increase irrigation and provide shade.';
    } else if (weather.temperature < 10) {
      return '❄️ Cold weather - protect crops from frost.';
    } else if (weather.humidity > 80) {
      return '💧 High humidity - watch for fungal diseases.';
    } else if (weather.windSpeed > 20) {
      return '💨 Windy conditions - secure support for tall crops.';
    } else {
      return '🌱 Perfect weather for farming activities!';
    }
  }

  String getWeatherEmoji(String iconCode) {
    switch (iconCode.substring(0, 2)) {
      case '01':
        return '☀️';
      case '02':
        return '⛅';
      case '03':
      case '04':
        return '☁️';
      case '09':
      case '10':
        return '🌧️';
      case '11':
        return '⛈️';
      case '13':
        return '❄️';
      case '50':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  // Get time-based greeting
  String getTimeBasedGreeting({String language = 'English'}) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning: 5 AM to 12 PM
      switch (language) {
        case 'Hindi':
          return 'सुप्रभात';
        case 'Tamil':
          return 'காலை வணக்கம்';
        case 'Telugu':
          return 'శుభోదయం';
        default:
          return 'Good Morning';
      }
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: 12 PM to 5 PM
      switch (language) {
        case 'Hindi':
          return 'नमस्कार';
        case 'Tamil':
          return 'மதிய வணக்கம்';
        case 'Telugu':
          return 'మధ్యాహ్న శుభాకాంక్షలు';
        default:
          return 'Good Afternoon';
      }
    } else {
      // Evening/Night: 5 PM to 5 AM (avoiding "Good Night")
      switch (language) {
        case 'Hindi':
          return 'शुभ संध्या';
        case 'Tamil':
          return 'மாலை வணக்கம்';
        case 'Telugu':
          return 'శుభ సాయంత్రం';
        default:
          return 'Good Evening';
      }
    }
  }

  // Get time-based subtitle message
  String getTimeBasedSubtitle({String language = 'English'}) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning: 5 AM to 12 PM
      switch (language) {
        case 'Hindi':
          return 'आज अपने खेत को फलने-फूलने के लिए तैयार हैं?';
        case 'Tamil':
          return 'இன்று உங்கள் பண்ணையை செழிக்க வைக்க தயாரா?';
        case 'Telugu':
          return 'ఈరోజు మీ వ్యవసాయాన్ని వర్ధిల్లించడానికి సిద్ధంగా ఉన్నారా?';
        default:
          return 'Ready to make your farm thrive today?';
      }
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: 12 PM to 5 PM
      switch (language) {
        case 'Hindi':
          return 'आज दोपहर खेती के लिए बेहतरीन समय है!';
        case 'Tamil':
          return 'இன்று மதியம் விவசாயத்திற்கு சிறந்த நேரம்!';
        case 'Telugu':
          return 'ఈరోజు మధ్యాహ్నం వ్యవసాయానికి గొప్ప సమయం!';
        default:
          return 'Perfect afternoon for farming activities!';
      }
    } else {
      // Evening: 5 PM onwards
      switch (language) {
        case 'Hindi':
          return 'शाम की शांति में अपने खेत की योजना बनाएं!';
        case 'Tamil':
          return 'மாலை அமைதியில் உங்கள் பண்ணையின் திட்டமிடுங்கள்!';
        case 'Telugu':
          return 'సాయంత్రం ప్రశాంతతలో మీ వ్యవసాయ ప్రణాళికలు రూపొందించండి!';
        default:
          return 'Plan your farming activities for tomorrow!';
      }
    }
  }
}

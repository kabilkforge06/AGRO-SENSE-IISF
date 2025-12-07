import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization_service.dart';

class AppStateService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _landLocationKey = 'land_location';
  static const String _usernameKey = 'username';
  static const String _isLoggedInKey = 'is_logged_in';

  String _selectedLanguage = ''; // Empty string to force language selection
  double? _landLatitude;
  double? _landLongitude;
  String _username = '';
  bool _isLoggedIn = false;
  bool _hasSelectedLand = false;
  Locale _locale = const Locale('en'); // Default locale

  // Getters
  String get selectedLanguage => _selectedLanguage;
  double? get landLatitude => _landLatitude;
  double? get landLongitude => _landLongitude;
  String get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasSelectedLand => _hasSelectedLand;
  Locale get locale => _locale;

  // Language options
  static const Map<String, String> supportedLanguages = {
    'English': 'en',
    'Hindi': 'hi',
    'Tamil': 'ta',
    'Telugu': 'te',
  };

  AppStateService() {
    _loadStateFromStorage();
  }

  // Load saved state from SharedPreferences
  Future<void> _loadStateFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedLanguage =
          prefs.getString(_languageKey) ??
          ''; // Empty string to force language selection
      if (_selectedLanguage.isNotEmpty) {
        _locale = Locale(
          LocalizationService.getLanguageCode(_selectedLanguage),
        );
      }
      _username = prefs.getString(_usernameKey) ?? '';
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      final locationData = prefs.getString(_landLocationKey);
      if (locationData != null && locationData.isNotEmpty) {
        final coords = locationData.split(',');
        if (coords.length == 2) {
          _landLatitude = double.tryParse(coords[0]);
          _landLongitude = double.tryParse(coords[1]);
          _hasSelectedLand = _landLatitude != null && _landLongitude != null;
        }
      }

      notifyListeners();
    } catch (e) {
      // Error loading app state, using defaults
    }
  }

  // Login with simple username/password
  Future<bool> login(String username, String password) async {
    // Simple mock authentication
    if (username.isNotEmpty && password.length >= 3) {
      _username = username;
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      await prefs.setBool(_isLoggedInKey, true);

      notifyListeners();
      return true;
    }
    return false;
  }

  // Set selected language
  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    _locale = Locale(LocalizationService.getLanguageCode(language));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);

    notifyListeners();
  }

  // Set land location
  Future<void> setLandLocation(double latitude, double longitude) async {
    _landLatitude = latitude;
    _landLongitude = longitude;
    _hasSelectedLand = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_landLocationKey, '$latitude,$longitude');

    notifyListeners();
  }

  // Skip land selection
  Future<void> skipLandSelection() async {
    _hasSelectedLand = true;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _username = '';
    _isLoggedIn = false;
    _hasSelectedLand = false;
    _landLatitude = null;
    _landLongitude = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  // Get greeting based on selected language
  String getGreeting() {
    return LocalizationService.translate('hello', _locale.languageCode);
  }

  // Get weather label based on selected language
  String getWeatherLabel() {
    return LocalizationService.translate('weather', _locale.languageCode);
  }

  // Get translated text
  String translate(String key) {
    return LocalizationService.translate(key, _locale.languageCode);
  }
}

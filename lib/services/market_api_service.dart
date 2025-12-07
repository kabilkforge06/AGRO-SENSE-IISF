import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Service to handle API calls to Indian Government Data.gov.in
/// for real-time market and commodity price data
///
/// IMPORTANT: Update _resourceId with the actual resource ID from Data.gov.in
/// API documentation for "Current Daily Price of Various Commodities from Various Markets (Mandi)"
class MarketApiService {
  // Data.gov.in API configuration
  static const String _baseUrl = 'https://api.data.gov.in/resource';
  static const String _apiKey =
      '579b464db66ec23bdd00000110359264742a4a8d6d23943d26dc0a24';

  static const String _resourceId = '9ef84268-d588-465a-a308-a864a43d0070';

  // HTTP client configuration
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetches market prices for a specific market from Data.gov.in API
  ///
  /// [market] - Name of the market to fetch prices for
  /// Returns the 'records' array from the API response
  Future<List<Map<String, dynamic>>> fetchMarketPrices(String market) async {
    try {
      // Check if running on web (browser) - CORS issues
      if (kIsWeb) {
        developer.log(
          'Running on web - using fallback data due to CORS restrictions',
        );
        return _getFallbackMarketData();
      }

      // Check network connectivity
      if (!await _hasNetworkConnection()) {
        throw Exception('No network connection available');
      }

      // Build API URL with filters
      final url = Uri.parse(
        '$_baseUrl/$_resourceId?api-key=$_apiKey&format=json&filters[market]=$market&limit=200',
      );

      developer.log('Fetching market prices from: ${url.toString()}');

      // Make HTTP request with timeout
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validate response structure
        if (data is Map<String, dynamic> && data.containsKey('records')) {
          final records = data['records'] as List<dynamic>;
          return records.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Invalid API response structure');
        }
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Unable to connect to Data.gov.in API');
    } on HttpException {
      throw Exception('HTTP error: Invalid response from server');
    } on FormatException {
      throw Exception('Data format error: Invalid JSON response');
    } catch (e) {
      developer.log('Error fetching market prices: $e');
      rethrow;
    }
  }

  /// Fetches all available markets from the API
  /// Returns unique list of market names
  Future<List<String>> fetchAllMarkets() async {
    try {
      // Check if running on web (browser) - CORS issues
      if (kIsWeb) {
        developer.log(
          'Running on web - using fallback markets due to CORS restrictions',
        );
        return _getFallbackMarkets();
      }

      // Check network connectivity
      if (!await _hasNetworkConnection()) {
        throw Exception('No network connection available');
      }

      // Build API URL to get all records
      final url = Uri.parse(
        '$_baseUrl/$_resourceId?api-key=$_apiKey&format=json&limit=1000',
      );

      developer.log('Fetching all markets from: ${url.toString()}');

      // Make HTTP request with timeout
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validate response structure
        if (data is Map<String, dynamic> && data.containsKey('records')) {
          final records = data['records'] as List<dynamic>;

          // Extract unique market names
          final Set<String> uniqueMarkets = {};
          for (final record in records) {
            if (record is Map<String, dynamic> &&
                record.containsKey('market')) {
              final marketName = record['market']?.toString();
              if (marketName != null && marketName.isNotEmpty) {
                uniqueMarkets.add(marketName);
              }
            }
          }

          return uniqueMarkets.toList()..sort();
        } else {
          throw Exception('Invalid API response structure');
        }
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Unable to connect to Data.gov.in API');
    } on HttpException {
      throw Exception('HTTP error: Invalid response from server');
    } on FormatException {
      throw Exception('Data format error: Invalid JSON response');
    } catch (e) {
      developer.log('Error fetching markets: $e');
      rethrow;
    }
  }

  /// Fetches markets filtered by state or district for nearby market functionality
  ///
  /// [state] - State name to filter markets by
  /// [district] - Optional district name for more specific filtering
  Future<List<String>> fetchMarketsByLocation({
    required String state,
    String? district,
  }) async {
    try {
      // Check if running on web (browser) - CORS issues
      if (kIsWeb) {
        developer.log(
          'Running on web - using fallback markets for location due to CORS restrictions',
        );
        return _getFallbackMarkets();
      }

      // Check network connectivity
      if (!await _hasNetworkConnection()) {
        throw Exception('No network connection available');
      }

      // Build API URL with state filter
      String filters = 'filters[state]=$state';
      if (district != null && district.isNotEmpty) {
        filters += '&filters[district]=$district';
      }

      final url = Uri.parse(
        '$_baseUrl/$_resourceId?api-key=$_apiKey&format=json&$filters&limit=200',
      );

      developer.log('Fetching markets by location from: ${url.toString()}');

      // Make HTTP request with timeout
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validate response structure
        if (data is Map<String, dynamic> && data.containsKey('records')) {
          final records = data['records'] as List<dynamic>;

          // Extract unique market names
          final Set<String> uniqueMarkets = {};
          for (final record in records) {
            if (record is Map<String, dynamic> &&
                record.containsKey('market')) {
              final marketName = record['market']?.toString();
              if (marketName != null && marketName.isNotEmpty) {
                uniqueMarkets.add(marketName);
              }
            }
          }

          return uniqueMarkets.toList()..sort();
        } else {
          throw Exception('Invalid API response structure');
        }
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Unable to connect to Data.gov.in API');
    } on HttpException {
      throw Exception('HTTP error: Invalid response from server');
    } on FormatException {
      throw Exception('Data format error: Invalid JSON response');
    } catch (e) {
      developer.log('Error fetching markets by location: $e');
      rethrow;
    }
  }

  /// Checks if device has network connection
  /// Returns true if network is available, false otherwise
  Future<bool> _hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Fallback market data for web browsers (CORS limitations)
  List<Map<String, dynamic>> _getFallbackMarketData() {
    return [
      {
        'state': 'Maharashtra',
        'district': 'Mumbai',
        'market': 'Crawford Market',
        'commodity': 'Rice',
        'variety': 'Basmati',
        'grade': 'A',
        'arrival_date': '29/11/2025',
        'min_price': '4000',
        'max_price': '4500',
        'modal_price': '4200',
      },
      {
        'state': 'Karnataka',
        'district': 'Bangalore',
        'market': 'KR Market',
        'commodity': 'Onion',
        'variety': 'Red',
        'grade': 'Medium',
        'arrival_date': '29/11/2025',
        'min_price': '2000',
        'max_price': '2800',
        'modal_price': '2400',
      },
      {
        'state': 'Tamil Nadu',
        'district': 'Chennai',
        'market': 'Koyambedu Market',
        'commodity': 'Tomato',
        'variety': 'Local',
        'grade': 'Good',
        'arrival_date': '29/11/2025',
        'min_price': '1500',
        'max_price': '2000',
        'modal_price': '1800',
      },
      {
        'state': 'Punjab',
        'district': 'Ludhiana',
        'market': 'Grain Market',
        'commodity': 'Wheat',
        'variety': 'PBW-343',
        'grade': 'FAQ',
        'arrival_date': '29/11/2025',
        'min_price': '2200',
        'max_price': '2400',
        'modal_price': '2300',
      },
      {
        'state': 'Gujarat',
        'district': 'Ahmedabad',
        'market': 'APMC Market',
        'commodity': 'Cotton',
        'variety': 'Medium Staple',
        'grade': 'Good',
        'arrival_date': '29/11/2025',
        'min_price': '5500',
        'max_price': '6000',
        'modal_price': '5800',
      },
      {
        'state': 'Uttar Pradesh',
        'district': 'Agra',
        'market': 'Sadar Market',
        'commodity': 'Potato',
        'variety': 'Local',
        'grade': 'Good',
        'arrival_date': '29/11/2025',
        'min_price': '800',
        'max_price': '1200',
        'modal_price': '1000',
      },
      {
        'state': 'Rajasthan',
        'district': 'Jaipur',
        'market': 'Muhana Market',
        'commodity': 'Chillies',
        'variety': 'Red Dry',
        'grade': 'FAQ',
        'arrival_date': '29/11/2025',
        'min_price': '12000',
        'max_price': '15000',
        'modal_price': '13500',
      },
      {
        'state': 'Haryana',
        'district': 'Hisar',
        'market': 'Grain Market',
        'commodity': 'Mustard',
        'variety': 'Black',
        'grade': 'FAQ',
        'arrival_date': '29/11/2025',
        'min_price': '5200',
        'max_price': '5800',
        'modal_price': '5500',
      },
    ];
  }

  /// Fallback market names for web browsers
  List<String> _getFallbackMarkets() {
    return [
      'Crawford Market',
      'KR Market',
      'Koyambedu Market',
      'Grain Market',
      'APMC Market',
      'Sadar Market',
      'Muhana Market',
      'Central Market',
      'Vegetable Market',
      'Wholesale Market',
    ];
  }
}

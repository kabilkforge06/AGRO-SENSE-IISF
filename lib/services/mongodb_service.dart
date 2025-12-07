import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/government_scheme.dart';

class MongoDBService {
  static MongoDBService? _instance;
  static MongoDBService get instance => _instance ??= MongoDBService._();

  MongoDBService._();

  static const String _baseUrl = 'http://localhost:3000/api';
  bool _isConnected = false;

  static Future<void> connect() async {
    try {
      // Test connection to Node.js API
      final response = await http
          .get(Uri.parse('$_baseUrl/schemes/count'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        instance._isConnected = true;
        print('✅ Connected to MongoDB API successfully');
      } else {
        throw Exception('API not responding');
      }
    } catch (e) {
      print('❌ Failed to connect to MongoDB API: $e');
      print('📝 Make sure to start Node.js server first:');
      print('   1. cd mongodb-api');
      print('   2. npm install');
      print('   3. npm start');
      // Fallback to sample data for demo
      instance._isConnected = false;
    }
  }

  static Future<void> close() async {
    instance._isConnected = false;
  }

  // Government Schemes Methods
  static Future<List<GovernmentScheme>> getSchemes({
    String? category,
    String? state,
    int limit = 50,
  }) async {
    if (!instance._isConnected) {
      // Return sample data if not connected to API
      return _getSampleSchemes();
    }

    try {
      final queryParams = <String, String>{'limit': limit.toString()};

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (state != null && state.isNotEmpty) {
        queryParams['state'] = state;
      }

      final uri = Uri.parse(
        '$_baseUrl/schemes',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => GovernmentScheme.fromMap(item)).toList();
      } else {
        throw Exception('Failed to load schemes');
      }
    } catch (e) {
      print('Error fetching schemes from API: $e');
      return _getSampleSchemes();
    }
  }

  static Future<void> insertScheme(GovernmentScheme scheme) async {
    if (!instance._isConnected) {
      print('⚠️ Cannot insert scheme: API not connected');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/schemes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(scheme.toMap()),
      );

      if (response.statusCode == 200) {
        print('✅ Scheme inserted to MongoDB: ${scheme.name}');
      } else {
        throw Exception('Failed to insert scheme');
      }
    } catch (e) {
      print('❌ Error inserting scheme: $e');
    }
  }

  static Future<void> insertManySchemes(List<GovernmentScheme> schemes) async {
    if (!instance._isConnected) {
      print('⚠️ Cannot insert schemes: API not connected');
      print('📝 Using sample data instead');
      return;
    }

    try {
      final schemesData = schemes.map((scheme) => scheme.toMap()).toList();

      final response = await http.post(
        Uri.parse('$_baseUrl/schemes/bulk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'schemes': schemesData}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
          '✅ Inserted ${data['insertedCount']} schemes to MongoDB database!',
        );
        print('🔍 Check MongoDB Compass to see the data');
      } else {
        throw Exception('Failed to insert schemes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error inserting schemes to MongoDB: $e');
    }
  }

  static Future<List<GovernmentScheme>> searchSchemes(String query) async {
    if (!instance._isConnected) {
      return _getSampleSchemes()
          .where(
            (scheme) =>
                scheme.name.toLowerCase().contains(query.toLowerCase()) ||
                scheme.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl/schemes/search',
      ).replace(queryParameters: {'q': query});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => GovernmentScheme.fromMap(item)).toList();
      } else {
        throw Exception('Failed to search schemes');
      }
    } catch (e) {
      print('Error searching schemes: $e');
      return [];
    }
  }

  static Future<int> getSchemesCount() async {
    if (!instance._isConnected) {
      return _getSampleSchemes().length;
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/schemes/count'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      } else {
        throw Exception('Failed to get schemes count');
      }
    } catch (e) {
      print('Error getting schemes count: $e');
      return 0;
    }
  }

  static Future<void> clearAllData() async {
    if (!instance._isConnected) {
      print('Cannot clear data: API not connected');
      return;
    }

    try {
      final response = await http.delete(Uri.parse('$_baseUrl/schemes'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Cleared ${data['deletedCount']} schemes from MongoDB');
      } else {
        throw Exception('Failed to clear schemes');
      }
    } catch (e) {
      print('Error clearing schemes: $e');
    }
  }

  static Future<Map<String, int>> getSchemesByCategory() async {
    try {
      final schemes = await getSchemes();
      final Map<String, int> categoryCounts = {};

      for (final scheme in schemes) {
        categoryCounts[scheme.category] =
            (categoryCounts[scheme.category] ?? 0) + 1;
      }

      return categoryCounts;
    } catch (e) {
      print('Error getting category stats: $e');
      return {};
    }
  }

  // Sample schemes for fallback when API is not available
  static List<GovernmentScheme> _getSampleSchemes() {
    return [
      GovernmentScheme(
        id: '1',
        name: 'PM-KISAN',
        description: 'Direct income support to small and marginal farmers',
        category: 'Agriculture',
        type: 'Central',
        states: ['All States'],
        districts: [],
        eligibilityCriteria: {'landSize': 'Up to 2 hectares'},
        subsidyPercentage: null,
        maxSubsidyAmount: 6000,
        minSubsidyAmount: null,
        requiredDocuments: [
          'Aadhaar Card',
          'Bank Account Details',
          'Land Records',
        ],
        applicationSteps: [],
        startDate: null,
        expiryDate: null,
        applicationUrl: 'https://pmkisan.gov.in',
        helplineNumber: '155261',
        officialWebsite: 'https://pmkisan.gov.in',
        isActive: true,
        lastUpdated: DateTime.now(),
        subsidyCalculatorParams: null,
        benefitDetails: ['₹6000 per year in 3 installments of ₹2000 each'],
        departmentName: 'Ministry of Agriculture',
        additionalInfo: null,
      ),
      GovernmentScheme(
        id: '2',
        name: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
        description:
            'Crop insurance scheme providing financial support to farmers',
        category: 'Insurance',
        type: 'Central',
        states: ['All States'],
        districts: [],
        eligibilityCriteria: {
          'eligibility': 'All farmers growing notified crops',
        },
        subsidyPercentage: 50,
        maxSubsidyAmount: null,
        minSubsidyAmount: null,
        requiredDocuments: [
          'Aadhaar Card',
          'Bank Account',
          'Land Records',
          'Sowing Certificate',
        ],
        applicationSteps: [],
        startDate: null,
        expiryDate: null,
        applicationUrl: 'https://pmfby.gov.in',
        helplineNumber: '14447',
        officialWebsite: 'https://pmfby.gov.in',
        isActive: true,
        lastUpdated: DateTime.now(),
        subsidyCalculatorParams: null,
        benefitDetails: [
          'Comprehensive risk cover',
          'Low premium rates',
          'Quick claim settlement',
        ],
        departmentName: 'Ministry of Agriculture',
        additionalInfo: null,
      ),
      GovernmentScheme(
        id: '3',
        name: 'Soil Health Card Scheme',
        description:
            'Promotes soil testing and provides soil health cards to farmers',
        category: 'Agriculture',
        type: 'Central',
        states: ['All States'],
        districts: [],
        eligibilityCriteria: {'eligibility': 'All farmers'},
        subsidyPercentage: null,
        maxSubsidyAmount: null,
        minSubsidyAmount: null,
        requiredDocuments: ['Land ownership documents', 'Aadhaar Card'],
        applicationSteps: [],
        startDate: null,
        expiryDate: null,
        applicationUrl: 'https://soilhealth.dac.gov.in',
        helplineNumber: '1800-180-1551',
        officialWebsite: 'https://soilhealth.dac.gov.in',
        isActive: true,
        lastUpdated: DateTime.now(),
        subsidyCalculatorParams: null,
        benefitDetails: [
          'Free soil testing',
          'Nutrient recommendations',
          'Improved crop yield',
        ],
        departmentName: 'Ministry of Agriculture',
        additionalInfo: null,
      ),
    ];
  }

  // Placeholder methods for other collections
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async =>
      null;
  static Future<void> saveUserProfile(
    String userId,
    Map<String, dynamic> profile,
  ) async {}
  static Future<List<Map<String, dynamic>>> getMarketPrices({
    String? crop,
    String? state,
    int limit = 100,
  }) async => [];
  static Future<void> saveMarketPrices(
    List<Map<String, dynamic>> prices,
  ) async {}
  static Future<List<Map<String, dynamic>>> getChatHistory(
    String userId,
  ) async => [];
  static Future<void> saveChatMessage(
    String userId,
    Map<String, dynamic> message,
  ) async {}
}

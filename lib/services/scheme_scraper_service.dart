import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/government_scheme.dart';

/// Service to fetch real-time government schemes using Gemini AI
class SchemeScraperService {
  static const String _apiKey = 'AIzaSyDzKAlSQXKMs7RAi4kibJXf3fRLUyFcnX4';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Fetch latest government schemes for farmers in India
  Future<List<Map<String, dynamic>>> fetchLatestSchemes({
    String? state,
    String? category,
    int limit = 20,
  }) async {
    try {
      final prompt = _buildSchemeSearchPrompt(
        state: state,
        category: category,
        limit: limit,
      );

      final responseText = await _callGeminiAPI(prompt);

      if (responseText.isEmpty) {
        developer.log(
          'Empty response from Gemini',
          name: 'SchemeScraperService',
        );
        return [];
      }

      // Parse the JSON response
      final schemes = _parseSchemeResponse(responseText);
      developer.log(
        'Fetched ${schemes.length} schemes',
        name: 'SchemeScraperService',
      );

      return schemes;
    } catch (e) {
      developer.log('Error fetching schemes: $e', name: 'SchemeScraperService');
      return [];
    }
  }

  /// Fetch schemes for a specific state
  Future<List<Map<String, dynamic>>> fetchStateSchemes(String state) async {
    return fetchLatestSchemes(state: state);
  }

  /// Fetch schemes by category
  Future<List<Map<String, dynamic>>> fetchSchemesByCategory(
    String category,
  ) async {
    return fetchLatestSchemes(category: category, limit: 5);
  }

  /// Fetch detailed information for a specific scheme
  Future<Map<String, dynamic>?> fetchSchemeDetails(
    String schemeName,
    String? state,
  ) async {
    try {
      final prompt = _buildSchemeDetailPrompt(schemeName, state);

      final responseText = await _callGeminiAPI(prompt);

      if (responseText.isEmpty) {
        return null;
      }

      final schemes = _parseSchemeResponse(responseText);
      return schemes.isNotEmpty ? schemes.first : null;
    } catch (e) {
      developer.log(
        'Error fetching scheme details: $e',
        name: 'SchemeScraperService',
      );
      return null;
    }
  }

  /// Call Gemini API with a prompt
  Future<String> _callGeminiAPI(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.4,
                'topK': 40,
                'topP': 0.95,
                'maxOutputTokens': 4096,
              },
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              developer.log(
                'Gemini API request timed out after 30 seconds',
                name: 'SchemeScraperService',
              );
              return http.Response('', 408);
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        developer.log(
          'Gemini API error: ${response.statusCode} - ${response.body}',
          name: 'SchemeScraperService',
        );
        return '';
      }
    } catch (e) {
      developer.log(
        'Error calling Gemini API: $e',
        name: 'SchemeScraperService',
      );
      return '';
    }
  }

  /// Build prompt for searching schemes
  String _buildSchemeSearchPrompt({
    String? state,
    String? category,
    required int limit,
  }) {
    final stateFilter = state != null ? ' in $state' : ' in India';
    final categoryFilter = category != null ? ' under $category category' : '';

    return '''
You are a government schemes information expert. Search and provide the latest active government schemes for farmers$stateFilter$categoryFilter as of 2025.

Please provide $limit schemes with complete and accurate information in the following JSON format:

```json
[
  {
    "name": "Scheme Name",
    "description": "Brief description of the scheme",
    "category": "Financial Aid/Machinery Subsidy/Irrigation/Crop Insurance/Training/Fertilizer Subsidy/Seed Subsidy/Loan Scheme/Market Access/Other",
    "type": "Central/State/District",
    "states": ["List of applicable states"],
    "districts": ["List of applicable districts if any"],
    "eligibilityCriteria": {
      "requiresAadhar": true/false,
      "requiresBankAccount": true/false,
      "maxLandHolding": number or null,
      "minLandHolding": number or null,
      "farmerCategories": ["Small", "Marginal", "Large"],
      "applicableCrops": ["List of crops or All"],
      "maxAnnualIncome": number or null,
      "requiresBPL": true/false,
      "scstOnly": true/false
    },
    "subsidyPercentage": number or null,
    "maxSubsidyAmount": number or null,
    "minSubsidyAmount": number or null,
    "requiredDocuments": ["List of required documents"],
    "applicationSteps": [
      {
        "stepNumber": 1,
        "title": "Step title",
        "description": "Step description",
        "requiredActions": ["List of actions"],
        "url": "URL if available"
      }
    ],
    "startDate": "ISO date string or null",
    "expiryDate": "ISO date string or null",
    "applicationUrl": "URL",
    "helplineNumber": "Number",
    "officialWebsite": "URL",
    "benefitDetails": ["List of benefits"],
    "departmentName": "Department name"
  }
]
```

Important guidelines:
1. Only include ACTIVE schemes that are currently accepting applications in 2025
2. Provide accurate and up-to-date information from official sources
3. Include complete application process details with at least 3 steps
4. Ensure all URLs are valid official government websites
5. Use current dates and deadlines
6. Return ONLY the JSON array, no additional text before or after

Focus on schemes from:
- PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)
- PMFBY (Pradhan Mantri Fasal Bima Yojana)
- Kisan Credit Card (KCC)
- PM-KUSUM (Solar Pump Scheme)
- National Agriculture Market (e-NAM)
- Soil Health Card Scheme
- Paramparagat Krishi Vikas Yojana (Organic Farming)
- Rashtriya Krishi Vikas Yojana (RKVY)
- State-specific schemes
- Recent announcements from Ministry of Agriculture & Farmers Welfare
''';
  }

  /// Build prompt for fetching detailed scheme information
  String _buildSchemeDetailPrompt(String schemeName, String? state) {
    final stateFilter = state != null ? ' in $state' : '';

    return '''
You are a government schemes information expert. Provide complete and detailed information about the scheme "$schemeName"$stateFilter as of 2025.

Provide the information in the following JSON format as a single-item array:

```json
[
  {
    "name": "$schemeName",
    "description": "Comprehensive description with latest updates",
    "category": "Category",
    "type": "Central/State/District",
    "states": ["Applicable states"],
    "districts": ["Applicable districts"],
    "eligibilityCriteria": {
      "requiresAadhar": true/false,
      "requiresBankAccount": true/false,
      "maxLandHolding": number or null,
      "minLandHolding": number or null,
      "farmerCategories": ["Categories"],
      "applicableCrops": ["Crops"],
      "maxAnnualIncome": number or null,
      "requiresBPL": true/false,
      "scstOnly": true/false
    },
    "subsidyPercentage": number or null,
    "maxSubsidyAmount": number or null,
    "minSubsidyAmount": number or null,
    "requiredDocuments": ["Complete list"],
    "applicationSteps": [
      {
        "stepNumber": number,
        "title": "Title",
        "description": "Detailed description",
        "requiredActions": ["Actions"],
        "url": "URL"
      }
    ],
    "startDate": "ISO date string",
    "expiryDate": "ISO date string or null",
    "applicationUrl": "Official URL",
    "helplineNumber": "Number",
    "officialWebsite": "Official website",
    "benefitDetails": ["Detailed benefits"],
    "departmentName": "Department",
    "additionalInfo": {
      "lastUpdated": "Current date",
      "totalBeneficiaries": "Approximate number"
    }
  }
]
```

Provide the most accurate and current information available for 2025. Return ONLY the JSON array, no additional text.
''';
  }

  /// Parse Gemini response and extract scheme data
  List<Map<String, dynamic>> _parseSchemeResponse(String response) {
    try {
      // Extract JSON from markdown code blocks if present
      String jsonText = response.trim();

      // Remove markdown code block markers
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }

      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }

      jsonText = jsonText.trim();

      // Parse JSON
      final dynamic parsed = jsonDecode(jsonText);

      if (parsed is List) {
        return List<Map<String, dynamic>>.from(
          parsed.map((item) => Map<String, dynamic>.from(item)),
        );
      } else if (parsed is Map) {
        return [Map<String, dynamic>.from(parsed)];
      }

      return [];
    } catch (e) {
      developer.log(
        'Error parsing scheme response: $e',
        name: 'SchemeScraperService',
      );
      developer.log('Response text: $response', name: 'SchemeScraperService');
      return [];
    }
  }

  /// Convert raw scheme data to GovernmentScheme objects
  List<GovernmentScheme> convertToSchemeObjects(
    List<Map<String, dynamic>> rawSchemes,
  ) {
    return rawSchemes.map((data) {
      try {
        return GovernmentScheme(
          id: _generateSchemeId(data['name'] as String),
          name: data['name'] as String,
          description: data['description'] as String,
          category: data['category'] as String,
          type: data['type'] as String,
          states: List<String>.from(data['states'] ?? []),
          districts: List<String>.from(data['districts'] ?? []),
          eligibilityCriteria: Map<String, dynamic>.from(
            data['eligibilityCriteria'] ?? {},
          ),
          subsidyPercentage: (data['subsidyPercentage'] as num?)?.toDouble(),
          maxSubsidyAmount: (data['maxSubsidyAmount'] as num?)?.toDouble(),
          minSubsidyAmount: (data['minSubsidyAmount'] as num?)?.toDouble(),
          requiredDocuments: List<String>.from(data['requiredDocuments'] ?? []),
          applicationSteps:
              (data['applicationSteps'] as List?)
                  ?.map(
                    (step) => ApplicationStep(
                      stepNumber: step['stepNumber'] as int,
                      title: step['title'] as String,
                      description: step['description'] as String,
                      requiredActions: List<String>.from(
                        step['requiredActions'] ?? [],
                      ),
                      url: step['url'] as String?,
                    ),
                  )
                  .toList() ??
              [],
          startDate: data['startDate'] != null
              ? DateTime.tryParse(data['startDate'] as String)
              : null,
          expiryDate: data['expiryDate'] != null
              ? DateTime.tryParse(data['expiryDate'] as String)
              : null,
          applicationUrl: data['applicationUrl'] as String?,
          helplineNumber: data['helplineNumber'] as String?,
          officialWebsite: data['officialWebsite'] as String?,
          isActive: true,
          lastUpdated: DateTime.now(),
          benefitDetails: List<String>.from(data['benefitDetails'] ?? []),
          departmentName: data['departmentName'] as String?,
          additionalInfo: data['additionalInfo'] != null
              ? Map<String, String>.from(data['additionalInfo'])
              : null,
        );
      } catch (e) {
        developer.log(
          'Error converting scheme: ${data['name']}, Error: $e',
          name: 'SchemeScraperService',
        );
        rethrow;
      }
    }).toList();
  }

  /// Generate a unique ID for a scheme based on its name
  String _generateSchemeId(String schemeName) {
    return schemeName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Verify and validate scheme data
  bool validateSchemeData(Map<String, dynamic> schemeData) {
    final requiredFields = [
      'name',
      'description',
      'category',
      'type',
      'states',
    ];

    for (final field in requiredFields) {
      if (!schemeData.containsKey(field) || schemeData[field] == null) {
        developer.log(
          'Missing required field: $field in scheme: ${schemeData['name']}',
          name: 'SchemeScraperService',
        );
        return false;
      }
    }

    return true;
  }
}

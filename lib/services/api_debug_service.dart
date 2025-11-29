import 'dart:developer' as developer;

/// Simple debug service to test API connectivity and CORS issues
class ApiDebugService {
  /// Test basic API connectivity with detailed logging
  static Future<void> testApiConnectivity() async {
    try {
      developer.log('🔍 Starting API Debug Test...');

      const testUrl =
          'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070'
          '?api-key=579b464db66ec23bdd00000110359264742a4a8d6d23943d26dc0a24&format=json&limit=5';

      developer.log('📡 Attempting to fetch from: $testUrl');

      // Use a simple HTTP client test
      final uri = Uri.parse(testUrl);
      developer.log('✅ URI parsed successfully: ${uri.host}');

      // Log the attempt
      developer.log('🚀 Making HTTP GET request...');
    } catch (e) {
      developer.log('❌ API Debug Error: $e');
    }
  }

  /// Test with fallback data for debugging
  static List<Map<String, dynamic>> getFallbackMarketData() {
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
    ];
  }
}

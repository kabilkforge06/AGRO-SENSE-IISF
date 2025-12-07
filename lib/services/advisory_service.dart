import 'dart:convert';
import 'package:http/http.dart' as http;

class AdvisoryService {
  // Google API Key specifically for Maps/Geocoding services
  static const String googleApiKey = "AIzaSyAJGtHXs2kIsOpjup29JtshFGD6qCEPUX0";

  /// --------------------------------------------------------
  /// GET ADDRESS FROM LAT/LONG USING GOOGLE GEOCODING API
  /// --------------------------------------------------------
  static Future<String?> getAddressFromLatLng(double lat, double lng) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["status"] == "OK") {
        return data["results"][0]["formatted_address"];
      }
    }

    return null;
  }

  /// --------------------------------------------------------
  /// BUILD ADVISORY PROMPT FOR GEMINI
  /// --------------------------------------------------------
  static String buildAdvisoryPrompt({
    required String crop,
    required String soil,
    required String season,
    String? address,
  }) {
    return """
Provide detailed and practical agricultural advisory for the following:

Crop: $crop
Soil Type: $soil
Season: $season
Location: ${address ?? "Location unavailable"}

Include the following sections:
1. Ideal soil preparation
2. Watering & irrigation schedule
3. Fertilizer recommendation (NPK values)
4. Pest & disease prevention
5. Growth stage instructions
6. Harvest timing & storage tips
7. Market pricing considerations

Keep the language simple, useful, and farmer-friendly.
""";
  }
}

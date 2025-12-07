import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/models/cold_storage_facility.dart';
// Ensure you have this location service or remove if using raw Geolocator
// import 'location_service.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ColdStorageService {
  static const String _googlePlacesApiKey =
      'AIzaSyA-Fy_Jpvkq0hg6Lv7Psz3PG9cVULJXuTs';

  // NEW Places API v1 base URL
  static const String _placesApiV1 = 'https://places.googleapis.com/v1';

  // Proxy server URL for web platform to avoid CORS issues
  static const String _proxyBaseUrl = 'http://localhost:3001/api/places';

  /// 1. Get Facilities by GPS (Nearby)
  Future<List<ColdStorageFacility>> getNearbyFacilities({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    try {
      final radiusMeters = (radiusKm * 1000).toInt();

      // We use a specific keyword search to get better results than generic 'nearby'
      return await _searchPlacesAPI(
        query: 'cold storage warehouse',
        latitude: latitude,
        longitude: longitude,
        radius: radiusMeters,
      );
    } catch (e) {
      developer.log('Error fetching nearby facilities: $e');
      throw Exception('Failed to fetch real-time data: $e');
    }
  }

  /// 2. Get Facilities by State and District (Text Search)
  Future<List<ColdStorageFacility>> searchByStateAndDistrict(
    String state,
    String district,
  ) async {
    try {
      // Construct a specific query for the API
      final query = 'Cold storage in $district, $state';
      developer.log('Searching API for: $query');

      // For text search, we don't strictly need lat/lng, but biasing helps if available.
      // Here we rely purely on the text query.
      return await _searchPlacesAPI(query: query);
    } catch (e) {
      developer.log('Error searching by location: $e');
      throw Exception('Failed to search location: $e');
    }
  }

  /// 3. General Search (Name, specific crop, etc.)
  Future<List<ColdStorageFacility>> searchFacilities(String query) async {
    return await _searchPlacesAPI(query: query);
  }

  /// CORE METHOD: Communicates with Google Places API
  Future<List<ColdStorageFacility>> _searchPlacesAPI({
    required String query,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    try {
      developer.log('Searching for: $query');
      developer.log(
        'Platform: ${kIsWeb ? 'Web' : (!kIsWeb && Platform.isAndroid ? 'Android' : 'iOS')}',
      );

      // Use proxy server for web platform to avoid CORS issues
      String urlString;
      Map<String, dynamic> requestBody = {'query': query};

      if (latitude != null && longitude != null && radius != null) {
        requestBody['location'] = '$latitude,$longitude';
        requestBody['radius'] = radius.toString();
      }

      if (kIsWeb) {
        // Use proxy server for web
        urlString = '$_proxyBaseUrl/textsearch';
      } else {
        // For mobile, use NEW Places API directly
        urlString = 'https://places.googleapis.com/v1/places:searchText';
      }

      developer.log('API URL: $urlString');

      final url = Uri.parse(urlString);

      // Create HTTP client with proper headers for cross-platform support
      final client = http.Client();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // For mobile, add required headers for NEW Places API
      if (!kIsWeb) {
        headers['X-Goog-Api-Key'] = _googlePlacesApiKey;
        headers['X-Goog-FieldMask'] =
            'places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.photos,places.types';

        // Transform request body for NEW API
        requestBody = {'textQuery': query};

        if (latitude != null && longitude != null && radius != null) {
          requestBody['locationBias'] = {
            'circle': {
              'center': {'latitude': latitude, 'longitude': longitude},
              'radius': radius,
            },
          };
        }
      }

      final response = await client
          .post(url, headers: headers, body: json.encode(requestBody))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle both old format (from proxy) and new format (direct API)
        List<dynamic> results = [];

        if (data['status'] == 'OK' && data['results'] != null) {
          // Old format from proxy
          results = data['results'];
        } else if (data['places'] != null) {
          // New format from direct API - transform to old format
          results = (data['places'] as List)
              .map(
                (place) => {
                  'place_id': place['id'],
                  'name': place['displayName']?['text'] ?? 'Unknown',
                  'formatted_address':
                      place['formattedAddress'] ?? 'Address not available',
                  'geometry': {
                    'location': {
                      'lat': place['location']?['latitude'] ?? 0,
                      'lng': place['location']?['longitude'] ?? 0,
                    },
                  },
                  'rating': place['rating'] ?? 0,
                  'user_ratings_total': place['userRatingCount'] ?? 0,
                  'photos':
                      (place['photos'] as List?)
                          ?.map((photo) => {'photo_reference': photo['name']})
                          .toList() ??
                      [],
                },
              )
              .toList();
        }

        if (results.isEmpty) {
          return [];
        }

        final List<ColdStorageFacility> facilities = [];
        for (var result in results) {
          final facility = await _mapJsonToFacility(result);
          if (facility != null) {
            facilities.add(facility);
          }
        }
        return facilities;
      } else {
        final errorBody = response.body.isNotEmpty
            ? response.body
            : 'No error details';
        throw Exception('HTTP Error ${response.statusCode}: $errorBody');
      }
    } on http.ClientException catch (e) {
      developer.log('Network error: $e');
      throw Exception(
        'Network connection failed. Please check your internet connection.',
      );
    } catch (e) {
      developer.log('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Helper: Map JSON result to ColdStorageFacility Model
  Future<ColdStorageFacility?> _mapJsonToFacility(
    Map<String, dynamic> json,
  ) async {
    try {
      final geometry = json['geometry'];
      final location = geometry['location'];

      // Extract photos - NEW PLACES API FORMAT
      List<String> photoUrls = [];
      if (json['photos'] != null) {
        for (var photo in json['photos'].take(2)) {
          // Limit to 2 photos to save data/calls
          final photoReference = photo['photo_reference'];
          if (photoReference != null) {
            // NEW Places API (v1) photo URL format
            photoUrls.add(
              '$_placesApiV1/$photoReference/media?maxHeightPx=400&maxWidthPx=400&key=$_googlePlacesApiKey',
            );
          }
        }
      }
      // Fallback image
      if (photoUrls.isEmpty) {
        photoUrls.add(
          'https://images.unsplash.com/photo-1581093458791-9d42cc04e6e8?w=400',
        );
      }

      return ColdStorageFacility(
        id: json['place_id'],
        name: json['name'] ?? 'Unknown Facility',
        address: json['formatted_address'] ?? 'Address not available',
        latitude: location['lat']?.toDouble() ?? 0.0,
        longitude: location['lng']?.toDouble() ?? 0.0,
        contactNumber:
            'Available on Maps', // Text Search usually doesn't return phone without Details API call
        rating: (json['rating'] ?? 0.0).toDouble(),
        reviewCount: json['user_ratings_total'] ?? 0,
        imageUrls: photoUrls,
        isActive: true, // Assuming active if returned by API
        // Fill defaults for fields API doesn't provide directly without extra calls
        email: 'Not Available',
        capacity: 0,
        supportedCrops: ['General Storage'],
        pricePerTon: 0.0,
        facilityType: 'Cold Storage',
        amenities: {'Security': true, 'Loading': true},
        ownerName: 'N/A',
        description: 'Real-time facility data from Google Maps.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      developer.log('Error mapping facility: $e');
      return null;
    }
  }

  // --- DATA SOURCES ---

  Future<List<String>> getAvailableStates() async {
    return _indianStatesAndDistricts.keys.toList()..sort();
  }

  Future<List<String>> getDistrictsForState(String state) async {
    List<String> districts = List.from(_indianStatesAndDistricts[state] ?? []);
    districts.sort();
    return districts;
  }

  // Comprehensive List of Indian States & Districts
  static const Map<String, List<String>> _indianStatesAndDistricts = {
    'Andhra Pradesh': [
      'Anantapur',
      'Chittoor',
      'East Godavari',
      'Guntur',
      'Krishna',
      'Kurnool',
      'Nellore',
      'Prakasam',
      'Srikakulam',
      'Visakhapatnam',
      'Vizianagaram',
      'West Godavari',
      'YSR Kadapa',
    ],
    'Arunachal Pradesh': [
      'Tawang',
      'West Kameng',
      'East Kameng',
      'Papum Pare',
      'Kurung Kumey',
      'Kra Daadi',
      'Lower Subansiri',
      'Upper Subansiri',
      'West Siang',
      'East Siang',
      'Siang',
      'Upper Siang',
      'Lower Siang',
      'Lower Dibang Valley',
      'Dibang Valley',
      'Anjaw',
      'Lohit',
      'Namsai',
      'Changlang',
      'Tirap',
      'Longding',
    ],
    'Assam': [
      'Baksa',
      'Barpeta',
      'Biswanath',
      'Bongaigaon',
      'Cachar',
      'Charaideo',
      'Chirang',
      'Darrang',
      'Dhemaji',
      'Dhubri',
      'Dibrugarh',
      'Dima Hasao',
      'Goalpara',
      'Golaghat',
      'Hailakandi',
      'Hojai',
      'Jorhat',
      'Kamrup',
      'Kamrup Metropolitan',
      'Karbi Anglong',
      'Karimganj',
      'Kokrajhar',
      'Lakhimpur',
      'Majuli',
      'Morigaon',
      'Nagaon',
      'Nalbari',
      'Sivasagar',
      'Sonitpur',
      'South Salmara-Mankachar',
      'Tinsukuda',
      'Udalguri',
      'West Karbi Anglong',
    ],
    'Bihar': [
      'Araria',
      'Arwal',
      'Aurangabad',
      'Banka',
      'Begusarai',
      'Bhagalpur',
      'Bhojpur',
      'Buxar',
      'Darbhanga',
      'East Champaran',
      'Gaya',
      'Gopalganj',
      'Jamui',
      'Jehanabad',
      'Kaimur',
      'Katihar',
      'Khagaria',
      'Kishanganj',
      'Lakhisarai',
      'Madhepura',
      'Madhubani',
      'Munger',
      'Muzaffarpur',
      'Nalanda',
      'Nawada',
      'Patna',
      'Purnia',
      'Rohtas',
      'Saharsa',
      'Samastipur',
      'Saran',
      'Sheikhpura',
      'Sheohar',
      'Sitamarhi',
      'Siwan',
      'Supaul',
      'Vaishali',
      'West Champaran',
    ],
    'Chhattisgarh': [
      'Balod',
      'Baloda Bazar',
      'Balrampur',
      'Bastar',
      'Bemetara',
      'Bijapur',
      'Bilaspur',
      'Dantewada',
      'Dhamtari',
      'Durg',
      'Gariaband',
      'Gaurela-Pendra-Marwahi',
      'Janjgir-Champa',
      'Jashpur',
      'Kabirdham',
      'Kanker',
      'Kondagaon',
      'Korba',
      'Koriya',
      'Mahasamund',
      'Mungeli',
      'Narayanpur',
      'Raigarh',
      'Raipur',
      'Rajnandgaon',
      'Sukma',
      'Surajpur',
      'Surguja',
    ],
    'Goa': ['North Goa', 'South Goa'],
    'Gujarat': [
      'Ahmedabad',
      'Amreli',
      'Anand',
      'Aravalli',
      'Banaskantha',
      'Bharuch',
      'Bhavnagar',
      'Botad',
      'Chhota Udaipur',
      'Dahod',
      'Dang',
      'Devbhoomi Dwarka',
      'Gandhinagar',
      'Gir Somnath',
      'Jamnagar',
      'Junagadh',
      'Kheda',
      'Kutch',
      'Mahisagar',
      'Mehsana',
      'Morbi',
      'Narmada',
      'Navsari',
      'Panchmahal',
      'Patan',
      'Porbandar',
      'Rajkot',
      'Sabarkantha',
      'Surat',
      'Surendranagar',
      'Tapi',
      'Vadodara',
      'Valsad',
    ],
    'Haryana': [
      'Ambala',
      'Bhiwani',
      'Charkhi Dadri',
      'Faridabad',
      'Fatehabad',
      'Gurugram',
      'Hisar',
      'Jhajjar',
      'Jind',
      'Kaithal',
      'Karnal',
      'Kurukshetra',
      'Mahendragarh',
      'Nuh',
      'Palwal',
      'Panchkula',
      'Panipat',
      'Rewari',
      'Rohtak',
      'Sirsa',
      'Sonipat',
      'Yamunanagar',
    ],
    'Himachal Pradesh': [
      'Bilaspur',
      'Chamba',
      'Hamirpur',
      'Kangra',
      'Kinnaur',
      'Kullu',
      'Lahaul and Spiti',
      'Mandi',
      'Shimla',
      'Sirmaur',
      'Solan',
      'Una',
    ],
    'Jharkhand': [
      'Bokaro',
      'Chatra',
      'Deoghar',
      'Dhanbad',
      'Dumka',
      'East Singhbhum',
      'Garhwa',
      'Giridih',
      'Godda',
      'Gumla',
      'Hazaribagh',
      'Jamtara',
      'Khunti',
      'Koderma',
      'Latehar',
      'Lohardaga',
      'Pakur',
      'Palamu',
      'Ramgarh',
      'Ranchi',
      'Sahibganj',
      'Seraikela Kharsawan',
      'Simdega',
      'West Singhbhum',
    ],
    'Karnataka': [
      'Bagalkot',
      'Ballari',
      'Belagavi',
      'Bengaluru Rural',
      'Bengaluru Urban',
      'Bidar',
      'Chamarajanagar',
      'Chikkaballapur',
      'Chikkamagaluru',
      'Chitradurga',
      'Dakshina Kannada',
      'Davangere',
      'Dharwad',
      'Gadag',
      'Hassan',
      'Haveri',
      'Kalaburagi',
      'Kodagu',
      'Kolar',
      'Koppal',
      'Mandya',
      'Mysuru',
      'Raichur',
      'Ramanagara',
      'Shivamogga',
      'Tumakuru',
      'Udupi',
      'Uttara Kannada',
      'Vijayapura',
      'Yadgir',
    ],
    'Kerala': [
      'Alappuzha',
      'Ernakulam',
      'Idukki',
      'Kannur',
      'Kasaragod',
      'Kollam',
      'Kottayam',
      'Kozhikode',
      'Malappuram',
      'Palakkad',
      'Pathanamthitta',
      'Thiruvananthapuram',
      'Thrissur',
      'Wayanad',
    ],
    'Madhya Pradesh': [
      'Agar Malwa',
      'Alirajpur',
      'Anuppur',
      'Ashoknagar',
      'Balaghat',
      'Barwani',
      'Betul',
      'Bhind',
      'Bhopal',
      'Burhanpur',
      'Chhatarpur',
      'Chhindwara',
      'Damoh',
      'Datia',
      'Dewas',
      'Dhar',
      'Dindori',
      'Guna',
      'Gwalior',
      'Harda',
      'Hoshangabad',
      'Indore',
      'Jabalpur',
      'Jhabua',
      'Katni',
      'Khandwa',
      'Khargone',
      'Mandla',
      'Mandsaur',
      'Morena',
      'Narsinghpur',
      'Neemuch',
      'Panna',
      'Raisen',
      'Rajgarh',
      'Ratlam',
      'Rewa',
      'Sagar',
      'Satna',
      'Sehore',
      'Seoni',
      'Shahdol',
      'Shajapur',
      'Sheopur',
      'Shivpuri',
      'Sidhi',
      'Singrauli',
      'Tikamgarh',
      'Ujjain',
      'Umaria',
      'Vidisha',
    ],
    'Maharashtra': [
      'Ahmednagar',
      'Akola',
      'Amravati',
      'Aurangabad',
      'Beed',
      'Bhandara',
      'Buldhana',
      'Chandrapur',
      'Dhule',
      'Gadchiroli',
      'Gondia',
      'Hingoli',
      'Jalgaon',
      'Jalna',
      'Kolhapur',
      'Latur',
      'Mumbai City',
      'Mumbai Suburban',
      'Nagpur',
      'Nanded',
      'Nandurbar',
      'Nashik',
      'Osmanabad',
      'Palghar',
      'Parbhani',
      'Pune',
      'Raigad',
      'Ratnagiri',
      'Sangli',
      'Satara',
      'Sindhudurg',
      'Solapur',
      'Thane',
      'Wardha',
      'Washim',
      'Yavatmal',
    ],
    'Manipur': [
      'Bishnupur',
      'Chandel',
      'Churachandpur',
      'Imphal East',
      'Imphal West',
      'Jiribam',
      'Kakching',
      'Kamjong',
      'Kangpokpi',
      'Noney',
      'Pherzawl',
      'Senapati',
      'Tamenglong',
      'Tengnoupal',
      'Thoubal',
      'Ukhrul',
    ],
    'Meghalaya': [
      'East Garo Hills',
      'East Jaintia Hills',
      'East Khasi Hills',
      'North Garo Hills',
      'Ri Bhoi',
      'South Garo Hills',
      'South West Garo Hills',
      'South West Khasi Hills',
      'West Garo Hills',
      'West Jaintia Hills',
      'West Khasi Hills',
    ],
    'Mizoram': [
      'Aizawl',
      'Champhai',
      'Kolasib',
      'Lawngtlai',
      'Lunglei',
      'Mamit',
      'Saiha',
      'Serchhip',
    ],
    'Nagaland': [
      'Dimapur',
      'Kiphire',
      'Kohima',
      'Longleng',
      'Mokokchung',
      'Mon',
      'Peren',
      'Phek',
      'Tuensang',
      'Wokha',
      'Zunheboto',
    ],
    'Odisha': [
      'Angul',
      'Balangir',
      'Balasore',
      'Bargarh',
      'Bhadrak',
      'Boudh',
      'Cuttack',
      'Deogarh',
      'Dhenkanal',
      'Gajapati',
      'Ganjam',
      'Jagatsinghpur',
      'Jajpur',
      'Jharsuguda',
      'Kalahandi',
      'Kandhamal',
      'Kendrapara',
      'Kendujhar',
      'Khordha',
      'Koraput',
      'Malkangiri',
      'Mayurbhanj',
      'Nabarangpur',
      'Nayagarh',
      'Nuapada',
      'Puri',
      'Rayagada',
      'Sambalpur',
      'Subarnapur',
      'Sundargarh',
    ],
    'Punjab': [
      'Amritsar',
      'Barnala',
      'Bathinda',
      'Faridkot',
      'Fatehgarh Sahib',
      'Fazilka',
      'Ferozepur',
      'Gurdaspur',
      'Hoshiarpur',
      'Jalandhar',
      'Kapurthala',
      'Ludhiana',
      'Mansa',
      'Moga',
      'Mohali',
      'Muktsar',
      'Pathankot',
      'Patiala',
      'Rupnagar',
      'Sangrur',
      'Shaheed Bhagat Singh Nagar',
      'Tarn Taran',
    ],
    'Rajasthan': [
      'Ajmer',
      'Alwar',
      'Banswara',
      'Baran',
      'Barmer',
      'Bharatpur',
      'Bhilwara',
      'Bikaner',
      'Bundi',
      'Chittorgarh',
      'Churu',
      'Dausa',
      'Dholpur',
      'Dungarpur',
      'Hanumangarh',
      'Jaipur',
      'Jaisalmer',
      'Jalore',
      'Jhalawar',
      'Jhunjhunu',
      'Jodhpur',
      'Karauli',
      'Kota',
      'Nagaur',
      'Pali',
      'Pratapgarh',
      'Rajsamand',
      'Sawai Madhopur',
      'Sikar',
      'Sirohi',
      'Sri Ganganagar',
      'Tonk',
      'Udaipur',
    ],
    'Sikkim': ['East Sikkim', 'North Sikkim', 'South Sikkim', 'West Sikkim'],
    'Tamil Nadu': [
      'Ariyalur',
      'Chengalpattu',
      'Chennai',
      'Coimbatore',
      'Cuddalore',
      'Dharmapuri',
      'Dindigul',
      'Erode',
      'Kallakurichi',
      'Kanchipuram',
      'Kanyakumari',
      'Karur',
      'Krishnagiri',
      'Madurai',
      'Mayiladuthurai',
      'Nagapattinam',
      'Namakkal',
      'Nilgiris',
      'Perambalur',
      'Pudukkottai',
      'Ramanathapuram',
      'Ranipet',
      'Salem',
      'Sivaganga',
      'Tenkasi',
      'Thanjavur',
      'Theni',
      'Thoothukudi',
      'Tiruchirappalli',
      'Tirunelveli',
      'Tirupattur',
      'Tiruppur',
      'Tiruvallur',
      'Tiruvannamalai',
      'Tiruvarur',
      'Vellore',
      'Viluppuram',
      'Virudhunagar',
    ],
    'Telangana': [
      'Adilabad',
      'Bhadradri Kothagudem',
      'Hyderabad',
      'Jagtial',
      'Jangaon',
      'Jayashankar Bhupalpally',
      'Jogulamba Gadwal',
      'Kamareddy',
      'Karimnagar',
      'Khammam',
      'Komaram Bheem',
      'Mahabubabad',
      'Mahabubnagar',
      'Mancherial',
      'Medak',
      'Medchal',
      'Nagarkurnool',
      'Nalgonda',
      'Nirmal',
      'Nizamabad',
      'Peddapalli',
      'Rajanna Sircilla',
      'Ranga Reddy',
      'Sangareddy',
      'Siddipet',
      'Suryapet',
      'Vikarabad',
      'Wanaparthy',
      'Warangal Rural',
      'Warangal Urban',
      'Yadadri Bhuvanagiri',
    ],
    'Tripura': [
      'Dhalai',
      'Gomati',
      'Khowai',
      'North Tripura',
      'Sepahijala',
      'South Tripura',
      'Unakoti',
      'West Tripura',
    ],
    'Uttar Pradesh': [
      'Agra',
      'Aligarh',
      'Ambedkar Nagar',
      'Amethi',
      'Amroha',
      'Auraiya',
      'Ayodhya',
      'Azamgarh',
      'Baghpat',
      'Bahraich',
      'Ballia',
      'Balrampur',
      'Banda',
      'Barabanki',
      'Bareilly',
      'Basti',
      'Bhadohi',
      'Bijnor',
      'Budaun',
      'Bulandshahr',
      'Chandauli',
      'Chitrakoot',
      'Deoria',
      'Etah',
      'Etawah',
      'Farrukhabad',
      'Fatehpur',
      'Firozabad',
      'Gautam Buddha Nagar',
      'Ghaziabad',
      'Ghazipur',
      'Gonda',
      'Gorakhpur',
      'Hamirpur',
      'Hapur',
      'Hardoi',
      'Hathras',
      'Jalaun',
      'Jaunpur',
      'Jhansi',
      'Kannauj',
      'Kanpur Dehat',
      'Kanpur Nagar',
      'Kasganj',
      'Kaushambi',
      'Kushinagar',
      'Lakhimpur Kheri',
      'Lalitpur',
      'Lucknow',
      'Maharajganj',
      'Mahoba',
      'Mainpuri',
      'Mathura',
      'Mau',
      'Meerut',
      'Mirzapur',
      'Moradabad',
      'Muzaffarnagar',
      'Pilibhit',
      'Pratapgarh',
      'Prayagraj',
      'Raebareli',
      'Rampur',
      'Saharanpur',
      'Sambhal',
      'Sant Kabir Nagar',
      'Shahjahanpur',
      'Shamli',
      'Shravasti',
      'Siddharthnagar',
      'Sitapur',
      'Sonbhadra',
      'Sultanpur',
      'Unnao',
      'Varanasi',
    ],
    'Uttarakhand': [
      'Almora',
      'Bageshwar',
      'Chamoli',
      'Champawat',
      'Dehradun',
      'Haridwar',
      'Nainital',
      'Pauri Garhwal',
      'Pithoragarh',
      'Rudraprayag',
      'Tehri Garhwal',
      'Udham Singh Nagar',
      'Uttarkashi',
    ],
    'West Bengal': [
      'Alipurduar',
      'Bankura',
      'Birbhum',
      'Cooch Behar',
      'Dakshin Dinajpur',
      'Darjeeling',
      'Hooghly',
      'Howrah',
      'Jalpaiguri',
      'Jhargram',
      'Kalimpong',
      'Kolkata',
      'Malda',
      'Murshidabad',
      'Nadia',
      'North 24 Parganas',
      'Paschim Bardhaman',
      'Paschim Medinipur',
      'Purba Bardhaman',
      'Purba Medinipur',
      'Purulia',
      'South 24 Parganas',
      'Uttar Dinajpur',
    ],
    'Andaman and Nicobar Islands': [
      'Nicobar',
      'North and Middle Andaman',
      'South Andaman',
    ],
    'Chandigarh': ['Chandigarh'],
    'Dadra and Nagar Haveli and Daman and Diu': [
      'Dadra and Nagar Haveli',
      'Daman',
      'Diu',
    ],
    'Delhi': [
      'Central Delhi',
      'East Delhi',
      'New Delhi',
      'North Delhi',
      'North East Delhi',
      'North West Delhi',
      'Shahdara',
      'South Delhi',
      'South East Delhi',
      'South West Delhi',
      'West Delhi',
    ],
    'Jammu and Kashmir': [
      'Anantnag',
      'Bandipora',
      'Baramulla',
      'Budgam',
      'Doda',
      'Ganderbal',
      'Jammu',
      'Kathua',
      'Kishtwar',
      'Kulgam',
      'Kupwara',
      'Poonch',
      'Pulwama',
      'Rajouri',
      'Ramban',
      'Reasi',
      'Samba',
      'Shopian',
      'Srinagar',
      'Udhampur',
    ],
    'Ladakh': ['Kargil', 'Leh'],
    'Lakshadweep': ['Lakshadweep'],
    'Puducherry': ['Karaikal', 'Mahe', 'Puducherry', 'Yanam'],
  };
}

import 'package:flutter/material.dart';

class LocalizationService {
  static final Map<String, Map<String, String>> _translations = {
    // Common
    'welcome': {
      'en': 'Welcome',
      'hi': 'स्वागत',
      'ta': 'வரவேற்பு',
      'te': 'స్వాగతం',
    },
    'hello': {'en': 'Hello', 'hi': 'नमस्ते', 'ta': 'வணக்கம்', 'te': 'నమస్కారం'},
    'continue': {
      'en': 'Continue',
      'hi': 'जारी रखें',
      'ta': 'தொடர்க',
      'te': 'కొనసాగించు',
    },
    'back': {'en': 'Back', 'hi': 'वापस', 'ta': 'பின்செல்', 'te': 'వెనక్కి'},
    'submit': {
      'en': 'Submit',
      'hi': 'जमा करें',
      'ta': 'சமர்ப்பி',
      'te': 'సమర్పించు',
    },
    'cancel': {
      'en': 'Cancel',
      'hi': 'रद्द करें',
      'ta': 'ரத்துசெய்',
      'te': 'రద్దుచేయి',
    },
    'skip': {'en': 'Skip', 'hi': 'छोड़ें', 'ta': 'தவிர்', 'te': 'దాటవేయి'},
    'save': {'en': 'Save', 'hi': 'सहेजें', 'ta': 'சேமி', 'te': 'సేవ్చేయి'},
    'search': {'en': 'Search', 'hi': 'खोजें', 'ta': 'தேடு', 'te': 'వెతకండి'},
    'loading': {
      'en': 'Loading...',
      'hi': 'लोड हो रहा है...',
      'ta': 'ஏற்றுகிறது...',
      'te': 'లోడ్ అవుతోంది...',
    },
    'error': {'en': 'Error', 'hi': 'त्रुटि', 'ta': 'பிழை', 'te': 'లోపం'},
    'success': {'en': 'Success', 'hi': 'सफलता', 'ta': 'வெற்றி', 'te': 'విజయం'},
    'yes': {'en': 'Yes', 'hi': 'हाँ', 'ta': 'ஆம்', 'te': 'అవును'},
    'no': {'en': 'No', 'hi': 'नहीं', 'ta': 'இல்லை', 'te': 'కాదు'},

    // Language Selection Screen
    'select_language': {
      'en': 'Select Language',
      'hi': 'भाषा चुनें',
      'ta': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'te': 'భాషను ఎంచుకోండి',
    },
    'choose_your_language': {
      'en': 'Choose Your Language',
      'hi': 'अपनी भाषा चुनें',
      'ta': 'உங்கள் மொழியைத் தேர்வுசெய்க',
      'te': 'మీ భాషను ఎంచుకోండి',
    },
    'select_preferred_language': {
      'en': 'Select your preferred language for the app interface',
      'hi': 'ऐप इंटरफ़ेस के लिए अपनी पसंदीदा भाषा चुनें',
      'ta':
          'பயன்பாட்டு இடைமுகத்திற்கு உங்கள் விருப்ப மொழியைத் தேர்ந்தெடுக்கவும்',
      'te': 'యాప్ ఇంటర్‌ఫేస్ కోసం మీ ఇష్టమైన భాషను ఎంచుకోండి',
    },
    'language_code': {
      'en': 'Language Code',
      'hi': 'भाषा कोड',
      'ta': 'மொழி குறியீடு',
      'te': 'భాష కోడ్',
    },

    // Login Screen
    'login': {'en': 'Login', 'hi': 'लॉगिन', 'ta': 'உள்நுழைய', 'te': 'లాగిన్'},
    'enter_username': {
      'en': 'Enter your username',
      'hi': 'अपना उपयोगकर्ता नाम दर्ज करें',
      'ta': 'உங்கள் பயனர்பெயரை உள்ளிடவும்',
      'te': 'మీ యూజర్‌నేమ్ నమోదు చేయండి',
    },
    'enter_password': {
      'en': 'Enter your password',
      'hi': 'अपना पासवर्ड दर्ज करें',
      'ta': 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்',
      'te': 'మీ పాస్‌వర్డ్ నమోదు చేయండి',
    },
    'username': {
      'en': 'Username',
      'hi': 'उपयोगकर्ता नाम',
      'ta': 'பயனர்பெயர்',
      'te': 'యూజర్‌నేమ్',
    },
    'password': {
      'en': 'Password',
      'hi': 'पासवर्ड',
      'ta': 'கடவுச்சொல்',
      'te': 'పాస్‌వర్డ్',
    },

    // Land Selection Screen
    'land_selection': {
      'en': 'Land Selection',
      'hi': 'भूमि चयन',
      'ta': 'நில தேர்வு',
      'te': 'భూమి ఎంపిక',
    },
    'select_your_land': {
      'en': 'Select Your Land Location',
      'hi': 'अपनी भूमि का स्थान चुनें',
      'ta': 'உங்கள் நிலத்தின் இடத்தைத் தேர்ந்தெடுக்கவும்',
      'te': 'మీ భూమి స్థానాన్ని ఎంచుకోండి',
    },
    'tap_on_map': {
      'en': 'Tap on the map to select your land location',
      'hi': 'अपनी भूमि का स्थान चुनने के लिए मानचित्र पर टैप करें',
      'ta': 'உங்கள் நிலத்தின் இடத்தைத் தேர்ந்தெடுக்க வரைபடத்தைத் தொடவும்',
      'te': 'మీ భూమి స్థానాన్ని ఎంచుకోవడానికి మ్యాప్‌పై ట్యాప్ చేయండి',
    },
    'use_current_location': {
      'en': 'Use Current Location',
      'hi': 'वर्तमान स्थान का उपयोग करें',
      'ta': 'தற்போதைய இடத்தைப் பயன்படுத்து',
      'te': 'ప్రస్తుత స్థానాన్ని ఉపయోగించండి',
    },
    'confirm_location': {
      'en': 'Confirm Location',
      'hi': 'स्थान की पुष्टि करें',
      'ta': 'இடத்தை உறுதிசெய்க',
      'te': 'స్థానాన్ని నిర్ధారించండి',
    },

    // Dashboard
    'dashboard': {
      'en': 'Dashboard',
      'hi': 'डैशबोर्ड',
      'ta': 'முகப்பு',
      'te': 'డాష్‌బోర్డ్',
    },
    'weather': {
      'en': 'Weather',
      'hi': 'मौसम',
      'ta': 'வானிலை',
      'te': 'వాతావరణం',
    },
    'temperature': {
      'en': 'Temperature',
      'hi': 'तापमान',
      'ta': 'வெப்பநிலை',
      'te': 'ఉష్ణోగ్రత',
    },
    'humidity': {
      'en': 'Humidity',
      'hi': 'आर्द्रता',
      'ta': 'ஈரப்பதம்',
      'te': 'తేమ',
    },
    'crop_advisory': {
      'en': 'Crop Advisory',
      'hi': 'फसल सलाह',
      'ta': 'பயிர் ஆலோசனை',
      'te': 'పంట సలహా',
    },
    'leaf_scanner': {
      'en': 'Leaf Scanner',
      'hi': 'पत्ती स्कैनर',
      'ta': 'இலை ஸ்கேனர்',
      'te': 'లీఫ్ స్కానర్',
    },
    'market_prices': {
      'en': 'Market Prices',
      'hi': 'बाजार मूल्य',
      'ta': 'சந்தை விலைகள்',
      'te': 'మార్కెట్ ధరలు',
    },
    'ai_assistant': {
      'en': 'AI Assistant',
      'hi': 'एआई सहायक',
      'ta': 'AI உதவியாளர்',
      'te': 'AI అసిస్టెంట్',
    },
    'quick_actions': {
      'en': 'Quick Actions',
      'hi': 'त्वरित क्रियाएं',
      'ta': 'விரைவு செயல்கள்',
      'te': 'త్వరిత చర్యలు',
    },

    // Advisory Screen
    'advisory': {'en': 'Advisory', 'hi': 'सलाह', 'ta': 'ஆலோசனை', 'te': 'సలహా'},
    'crop_recommendations': {
      'en': 'Crop Recommendations',
      'hi': 'फसल सिफारिशें',
      'ta': 'பயிர் பரிந்துரைகள்',
      'te': 'పంట సిఫార్సులు',
    },
    'weather_based_tips': {
      'en': 'Weather-Based Tips',
      'hi': 'मौसम आधारित सुझाव',
      'ta': 'வானிலை அடிப்படையிலான குறிப்புகள்',
      'te': 'వాతావరణ ఆధారిత చిట్కాలు',
    },
    'seasonal_advice': {
      'en': 'Seasonal Advice',
      'hi': 'मौसमी सलाह',
      'ta': 'பருவகால ஆலோசனை',
      'te': 'కాలానుగుణ సలహా',
    },

    // Scan Leaf Screen
    'scan_leaf': {
      'en': 'Scan Leaf',
      'hi': 'पत्ती स्कैन करें',
      'ta': 'இலையை ஸ்கேன் செய்யுங்கள்',
      'te': 'లీఫ్ స్కాన్ చేయండి',
    },
    'take_photo': {
      'en': 'Take Photo',
      'hi': 'फोटो लें',
      'ta': 'புகைப்படம் எடு',
      'te': 'ఫోటో తీయండి',
    },
    'choose_from_gallery': {
      'en': 'Choose from Gallery',
      'hi': 'गैलरी से चुनें',
      'ta': 'கேலரியிலிருந்து தேர்வுசெய்',
      'te': 'గ్యాలరీ నుండి ఎంచుకోండి',
    },
    'analyzing_image': {
      'en': 'Analyzing image...',
      'hi': 'छवि का विश्लेषण किया जा रहा है...',
      'ta': 'படத்தை பகுப்பாய்வு செய்கிறது...',
      'te': 'చిత్రాన్ని విశ్లేషిస్తోంది...',
    },
    'disease_detected': {
      'en': 'Disease Detected',
      'hi': 'रोग का पता चला',
      'ta': 'நோய் கண்டறியப்பட்டது',
      'te': 'వ్యాధి కనుగొనబడింది',
    },
    'healthy_leaf': {
      'en': 'Healthy Leaf',
      'hi': 'स्वस्थ पत्ती',
      'ta': 'ஆரோக்கியமான இலை',
      'te': 'ఆరోగ్యకరమైన ఆకు',
    },
    'treatment': {
      'en': 'Treatment',
      'hi': 'उपचार',
      'ta': 'சிகிச்சை',
      'te': 'చికిత్స',
    },

    // Market Screen
    'market': {'en': 'Market', 'hi': 'बाजार', 'ta': 'சந்தை', 'te': 'మార్కెట్'},
    'today_prices': {
      'en': "Today's Prices",
      'hi': 'आज के मूल्य',
      'ta': 'இன்றைய விலைகள்',
      'te': 'నేటి ధరలు',
    },
    'price': {'en': 'Price', 'hi': 'मूल्य', 'ta': 'விலை', 'te': 'ధర'},
    'per_quintal': {
      'en': 'per quintal',
      'hi': 'प्रति क्विंटल',
      'ta': 'குவிண்டலுக்கு',
      'te': 'క్వింటాల్‌కు',
    },
    'commodity': {
      'en': 'Commodity',
      'hi': 'वस्तु',
      'ta': 'பொருள்',
      'te': 'వస్తువు',
    },
    'compare_markets': {
      'en': 'Compare Markets',
      'hi': 'बाजारों की तुलना करें',
      'ta': 'சந்தைகளை ஒப்பிடுக',
      'te': 'మార్కెట్లను పోల్చండి',
    },
    'nearby_markets': {
      'en': 'Nearby Markets',
      'hi': 'निकटवर्ती बाजार',
      'ta': 'அருகிலுள்ள சந்தைகள்',
      'te': 'సమీప మార్కెట్లు',
    },

    // AI Chat Screen
    'ai_chat': {
      'en': 'AI Chat',
      'hi': 'एआई चैट',
      'ta': 'AI அரட்டை',
      'te': 'AI చాట్',
    },
    'type_message': {
      'en': 'Type your message...',
      'hi': 'अपना संदेश टाइप करें...',
      'ta': 'உங்கள் செய்தியை தட்டச்சு செய்க...',
      'te': 'మీ సందేశాన్ని టైప్ చేయండి...',
    },
    'ask_anything': {
      'en': 'Ask me anything about farming',
      'hi': 'खेती के बारे में मुझसे कुछ भी पूछें',
      'ta': 'விவசாயம் பற்றி என்னிடம் எதையும் கேளுங்கள்',
      'te': 'వ్యవసాయం గురించి నన్ను ఏదైనా అడగండి',
    },
    'voice_input': {
      'en': 'Voice Input',
      'hi': 'वॉयस इनपुट',
      'ta': 'குரல் உள்ளீடு',
      'te': 'వాయిస్ ఇన్‌పుట్',
    },

    // Cold Storage Screen
    'cold_storage': {
      'en': 'Cold Storage',
      'hi': 'कोल्ड स्टोरेज',
      'ta': 'குளிர்பதன சேமிப்பு',
      'te': 'కోల్డ్ స్టోరేజ్',
    },
    'find_cold_storage': {
      'en': 'Find Cold Storage',
      'hi': 'कोल्ड स्टोरेज खोजें',
      'ta': 'குளிர்பதன சேமிப்பு கண்டுபிடி',
      'te': 'కోల్డ్ స్టోరేజ్ కనుగొనండి',
    },
    'storage_facilities': {
      'en': 'Storage Facilities',
      'hi': 'भंडारण सुविधाएं',
      'ta': 'சேமிப்பு வசதிகள்',
      'te': 'నిల్వ సౌకర్యాలు',
    },

    // Government Schemes
    'government_schemes': {
      'en': 'Government Schemes',
      'hi': 'सरकारी योजनाएं',
      'ta': 'அரசு திட்டங்கள்',
      'te': 'ప్రభుత్వ పథకాలు',
    },
    'schemes': {
      'en': 'Schemes',
      'hi': 'योजनाएं',
      'ta': 'திட்டங்கள்',
      'te': 'పథకాలు',
    },
    'view_details': {
      'en': 'View Details',
      'hi': 'विवरण देखें',
      'ta': 'விவரங்களைப் பார்க்க',
      'te': 'వివరాలు చూడండి',
    },
    'apply_now': {
      'en': 'Apply Now',
      'hi': 'अभी आवेदन करें',
      'ta': 'இப்போது விண்ணப்பிக்கவும்',
      'te': 'ఇప్పుడు దరఖాస్తు చేయండి',
    },

    // Navigation
    'home': {'en': 'Home', 'hi': 'होम', 'ta': 'முகப்பு', 'te': 'హోమ్'},
    'profile': {
      'en': 'Profile',
      'hi': 'प्रोफ़ाइल',
      'ta': 'சுயவிவரம்',
      'te': 'ప్రొఫైల్',
    },
    'settings': {
      'en': 'Settings',
      'hi': 'सेटिंग्स',
      'ta': 'அமைப்புகள்',
      'te': 'సెట్టింగ్‌లు',
    },
    'logout': {
      'en': 'Logout',
      'hi': 'लॉगआउट',
      'ta': 'வெளியேறு',
      'te': 'లాగౌట్',
    },

    // Messages
    'select_language_first': {
      'en': 'Please select a language first',
      'hi': 'कृपया पहले एक भाषा चुनें',
      'ta': 'முதலில் ஒரு மொழியைத் தேர்ந்தெடுக்கவும்',
      'te': 'దయచేసి ముందుగా ఒక భాషను ఎంచుకోండి',
    },
    'login_failed': {
      'en': 'Login failed. Please check your credentials.',
      'hi': 'लॉगिन विफल रहा। कृपया अपनी साख जांचें।',
      'ta': 'உள்நுழைவு தோல்வியடைந்தது. உங்கள் சான்றுகளைச் சரிபார்க்கவும்.',
      'te': 'లాగిన్ విఫలమైంది. దయచేసి మీ ఆధారాలను తనిఖీ చేయండి.',
    },
    'location_permission_denied': {
      'en': 'Location permission denied',
      'hi': 'स्थान अनुमति अस्वीकृत',
      'ta': 'இடம் அனுமதி மறுக்கப்பட்டது',
      'te': 'స్థానం అనుమతి తిరస్కరించబడింది',
    },
    'no_data_available': {
      'en': 'No data available',
      'hi': 'कोई डेटा उपलब्ध नहीं',
      'ta': 'தரவு எதுவும் கிடைக்கவில்லை',
      'te': 'డేటా అందుబాటులో లేదు',
    },

    // Crops
    'wheat': {'en': 'Wheat', 'hi': 'गेहूं', 'ta': 'கோதுமை', 'te': 'గోధుమ'},
    'rice': {'en': 'Rice', 'hi': 'चावल', 'ta': 'அரிசி', 'te': 'బియ్యం'},
    'corn': {'en': 'Corn', 'hi': 'मक्का', 'ta': 'சோளம்', 'te': 'మొక్కజొన్న'},
    'tomato': {'en': 'Tomato', 'hi': 'टमाटर', 'ta': 'தக்காளி', 'te': 'టమోటా'},
    'potato': {
      'en': 'Potato',
      'hi': 'आलू',
      'ta': 'உருளைக்கிழங்கு',
      'te': 'బంగాళాదుంప',
    },
    'onion': {
      'en': 'Onion',
      'hi': 'प्याज',
      'ta': 'வெங்காயம்',
      'te': 'ఉల్లిపాయ',
    },

    // Days of week
    'monday': {
      'en': 'Monday',
      'hi': 'सोमवार',
      'ta': 'திங்கள்',
      'te': 'సోమవారం',
    },
    'tuesday': {
      'en': 'Tuesday',
      'hi': 'मंगलवार',
      'ta': 'செவ்வாய்',
      'te': 'మంగళవారం',
    },
    'wednesday': {
      'en': 'Wednesday',
      'hi': 'बुधवार',
      'ta': 'புதன்',
      'te': 'బుధవారం',
    },
    'thursday': {
      'en': 'Thursday',
      'hi': 'गुरुवार',
      'ta': 'வியாழன்',
      'te': 'గురువారం',
    },
    'friday': {
      'en': 'Friday',
      'hi': 'शुक्रवार',
      'ta': 'வெள்ளி',
      'te': 'శుక్రవారం',
    },
    'saturday': {
      'en': 'Saturday',
      'hi': 'शनिवार',
      'ta': 'சனி',
      'te': 'శనివారం',
    },
    'sunday': {'en': 'Sunday', 'hi': 'रविवार', 'ta': 'ஞாயிறு', 'te': 'ఆదివారం'},

    // Additional common phrases
    'farming_assist': {
      'en': 'Farming Assist',
      'hi': 'खेती सहायक',
      'ta': 'விவசாய உதவி',
      'te': 'వ్యవసాయ సహాయం',
    },
    'your_farming_companion': {
      'en': 'Your Farming Companion',
      'hi': 'आपका खेती साथी',
      'ta': 'உங்கள் விவசாய துணை',
      'te': 'మీ వ్యవసాయ సహచరుడు',
    },
    'powered_by_ai': {
      'en': 'Powered by AI',
      'hi': 'एआई द्वारा संचालित',
      'ta': 'AI மூலம் இயக்கப்படுகிறது',
      'te': 'AI ద్వారా నడుపబడుతుంది',
    },
  };

  /// Get translation for a key based on the language code
  static String translate(String key, String languageCode) {
    // Default to English if key or language not found
    if (!_translations.containsKey(key)) {
      return key; // Return the key itself if translation not found
    }

    final translations = _translations[key]!;
    return translations[languageCode] ?? translations['en'] ?? key;
  }

  /// Get translation using locale
  static String get(String key, Locale locale) {
    return translate(key, locale.languageCode);
  }

  /// Check if a key exists
  static bool hasKey(String key) {
    return _translations.containsKey(key);
  }

  /// Get all supported locales
  static List<Locale> get supportedLocales {
    return const [Locale('en'), Locale('hi'), Locale('ta'), Locale('te')];
  }

  /// Get language name from code
  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      case 'ta':
        return 'Tamil';
      case 'te':
        return 'Telugu';
      default:
        return 'English';
    }
  }

  /// Get language code from name
  static String getLanguageCode(String name) {
    switch (name) {
      case 'Hindi':
        return 'hi';
      case 'Tamil':
        return 'ta';
      case 'Telugu':
        return 'te';
      case 'English':
      default:
        return 'en';
    }
  }
}

/// Extension to make translations easier to use
extension LocalizationExtension on String {
  String tr(String languageCode) {
    return LocalizationService.translate(this, languageCode);
  }
}

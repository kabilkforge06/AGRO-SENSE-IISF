import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/app_state_service.dart';
import '../services/weather_service.dart';

class LandSelectionScreen extends StatefulWidget {
  const LandSelectionScreen({super.key});

  @override
  State<LandSelectionScreen> createState() => _LandSelectionScreenState();
}

class _LandSelectionScreenState extends State<LandSelectionScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  WeatherData? _weatherData;
  bool _isLoadingWeather = false;
  final WeatherService _weatherService = WeatherService();

  // Default center on India
  final LatLng _defaultCenter = const LatLng(20.5937, 78.9629);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateService>(context);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text(_getTitle(appState.selectedLanguage)),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Instruction card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade600, size: 24),
                const SizedBox(height: 8),
                Text(
                  _getInstructionText(appState.selectedLanguage),
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Map container
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 5.0,
                    onTap: (tapPosition, point) {
                      _selectLocation(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.farming_assist',
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Weather info card (if location selected)
          if (_selectedLocation != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _getWeatherTitle(appState.selectedLanguage),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingWeather)
                    const Center(child: CircularProgressIndicator())
                  else if (_weatherData != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weatherData!.temperature.round()}°C - ${_weatherData!.description}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Humidity: ${_weatherData!.humidity}% | Wind: ${_weatherData!.windSpeed.round()} km/h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Location: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Continue button (only if location selected)
                if (_selectedLocation != null)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await appState.setLandLocation(
                          _selectedLocation!.latitude,
                          _selectedLocation!.longitude,
                        );
                        _navigateToDashboard();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _getContinueText(appState.selectedLanguage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // Skip button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () async {
                      await appState.skipLandSelection();
                      _navigateToDashboard();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _getSkipText(appState.selectedLanguage),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectLocation(LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _weatherData = null;
      _isLoadingWeather = true;
    });

    try {
      final weather = await _weatherService.getWeatherByLocation(
        point.latitude,
        point.longitude,
      );
      setState(() {
        _weatherData = weather;
        _isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  void _navigateToDashboard() {
    // No need to navigate manually - the Consumer in main.dart will handle this automatically
    // The state change will trigger the navigation
  }

  String _getTitle(String language) {
    switch (language) {
      case 'Hindi':
        return 'अपनी भूमि चुनें';
      case 'Tamil':
        return 'உங்கள் நிலத்தைத் தேர்ந்தெடுக்கவும்';
      case 'Telugu':
        return 'మీ భూమిని ఎంచుకోండి';
      default:
        return 'Select Your Land';
    }
  }

  String _getInstructionText(String language) {
    switch (language) {
      case 'Hindi':
        return 'मानचित्र पर क्लिक करके अपनी कृषि भूमि का स्थान चुनें';
      case 'Tamil':
        return 'வரைபடத்தில் கிளிக் செய்து உங்கள் விவசாய நிலத்தின் இடத்தைத் தேர்ந்தெடுக்கவும்';
      case 'Telugu':
        return 'మ్యాప్‌లో క్లిక్ చేసి మీ వ్యవసాయ భూమి స్థానాన్ని ఎంచుకోండి';
      default:
        return 'Tap on the map to select your farming land location';
    }
  }

  String _getWeatherTitle(String language) {
    switch (language) {
      case 'Hindi':
        return 'मौसम की जानकारी';
      case 'Tamil':
        return 'வானிலை தகவல்';
      case 'Telugu':
        return 'వాతావరణ సమాచారం';
      default:
        return 'Weather Information';
    }
  }

  String _getContinueText(String language) {
    switch (language) {
      case 'Hindi':
        return 'जारी रखें';
      case 'Tamil':
        return 'தொடரவும்';
      case 'Telugu':
        return 'కొనసాగించు';
      default:
        return 'Continue with Selected Location';
    }
  }

  String _getSkipText(String language) {
    switch (language) {
      case 'Hindi':
        return 'छोड़ें और डैशबोर्ड पर जाएं';
      case 'Tamil':
        return 'தவிர்த்து டாஷ்போர்டுக்குச் செல்லுங்கள்';
      case 'Telugu':
        return 'దాటవేసి డ్యాష్‌బోర్డుకు వెళ్లండి';
      default:
        return 'Skip and Go to Dashboard';
    }
  }
}

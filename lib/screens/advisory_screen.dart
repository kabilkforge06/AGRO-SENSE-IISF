import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/location_service.dart';
import '../services/advisory_service.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
  final GeminiService _geminiService = GeminiService();

  String? _selectedCrop;
  String? _selectedSoilType;
  String? _selectedSeason;

  String _aiAdvice = '';
  bool _isLoading = false;

  String? _userAddress;

  final List<String> _crops = [
    'Wheat','Rice','Corn','Cotton','Sugarcane','Soybean',
    'Mustard','Barley','Chickpea','Lentil','Potato','Tomato',
  ];

  final List<String> _soilTypes = [
    'Alluvial','Black Cotton','Red Laterite','Sandy',
    'Clay','Loamy','Saline','Alkaline',
  ];

  final List<String> _seasons = [
    'Kharif (Summer)', 'Rabi (Winter)', 'Zaid (Spring)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Advisory"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(
              label: "Select Crop",
              value: _selectedCrop,
              items: _crops,
              onChanged: (v) => setState(() => _selectedCrop = v),
              icon: Icons.agriculture,
            ),
            const SizedBox(height: 16),

            _buildDropdown(
              label: "Select Soil Type",
              value: _selectedSoilType,
              items: _soilTypes,
              onChanged: (v) => setState(() => _selectedSoilType = v),
              icon: Icons.terrain,
            ),
            const SizedBox(height: 16),

            _buildDropdown(
              label: "Select Season",
              value: _selectedSeason,
              items: _seasons,
              onChanged: (v) => setState(() => _selectedSeason = v),
              icon: Icons.wb_sunny,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _canGetAdvice() ? _getAIAdvice : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(14),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Get AI Advisory",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),

            if (_aiAdvice.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                "AI Advisory",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _aiAdvice,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 6),
        DropdownButtonFormField(
          initialValue: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  bool _canGetAdvice() {
    return _selectedCrop != null &&
        _selectedSoilType != null &&
        _selectedSeason != null &&
        !_isLoading;
  }

  Future<void> _getAIAdvice() async {
    setState(() {
      _isLoading = true;
      _aiAdvice = "";
    });

    try {
      // Get location
      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        _userAddress = await AdvisoryService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );
      }

      // Build AI prompt
      final prompt = AdvisoryService.buildAdvisoryPrompt(
        crop: _selectedCrop!,
        soil: _selectedSoilType!,
        season: _selectedSeason!,
        address: _userAddress,
      );

      final response = await _geminiService.sendMessage(prompt);

      setState(() {
        _aiAdvice = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _aiAdvice = "Error generating advisory. Please try again.";
        _isLoading = false;
      });
    }
  }
}

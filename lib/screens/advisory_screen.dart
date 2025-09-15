import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/location_service.dart';

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

  final List<String> _crops = [
    'Wheat',
    'Rice',
    'Corn',
    'Cotton',
    'Sugarcane',
    'Soybean',
    'Mustard',
    'Barley',
    'Chickpea',
    'Lentil',
    'Potato',
    'Tomato',
  ];

  final List<String> _soilTypes = [
    'Alluvial',
    'Black Cotton',
    'Red Laterite',
    'Sandy',
    'Clay',
    'Loamy',
    'Saline',
    'Alkaline',
  ];

  final List<String> _seasons = [
    'Kharif (Summer)',
    'Rabi (Winter)',
    'Zaid (Spring)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Advisory'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: Colors.green.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI-Powered Farming Advisory',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          Text(
                            'Get personalized farming advice based on your crop, soil, and season',
                            style: TextStyle(color: Colors.green.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Crop Selection
            _buildDropdown(
              label: 'Select Crop',
              value: _selectedCrop,
              items: _crops,
              onChanged: (value) => setState(() => _selectedCrop = value),
              icon: Icons.agriculture,
            ),

            const SizedBox(height: 16),

            // Soil Type Selection
            _buildDropdown(
              label: 'Select Soil Type',
              value: _selectedSoilType,
              items: _soilTypes,
              onChanged: (value) => setState(() => _selectedSoilType = value),
              icon: Icons.terrain,
            ),

            const SizedBox(height: 16),

            // Season Selection
            _buildDropdown(
              label: 'Select Season',
              value: _selectedSeason,
              items: _seasons,
              onChanged: (value) => setState(() => _selectedSeason = value),
              icon: Icons.wb_sunny,
            ),

            const SizedBox(height: 24),

            // Get Advice Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canGetAdvice() ? _getAIAdvice : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Get AI Advisory',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // AI Advice Display
            if (_aiAdvice.isNotEmpty) ...[
              Text(
                'AI Advisory',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Personalized Recommendation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _aiAdvice,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
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
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.green.shade600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            hint: Text('Choose $label'),
            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
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
      _aiAdvice = '';
    });

    try {
      // Get location for weather context
      String locationContext = '';
      try {
        final position = await LocationService.getCurrentLocation();
        if (position != null) {
          locationContext =
              ' Location: ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}.';
        }
      } catch (e) {
        // Location not available, continue without it
      }

      final prompt =
          '''
As an agricultural expert, provide detailed farming advice for:
- Crop: $_selectedCrop
- Soil Type: $_selectedSoilType
- Season: $_selectedSeason$locationContext

Please provide specific recommendations including:
1. Best practices for this crop in this soil and season
2. Irrigation requirements and schedule
3. Fertilizer recommendations
4. Pest and disease prevention
5. Harvest timing and techniques
6. Expected yield and market considerations

Keep the advice practical and actionable for farmers.
''';

      final advice = await _geminiService.sendMessage(prompt);

      setState(() {
        _aiAdvice = advice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _aiAdvice =
            'Unable to generate advice at this time. Please check your internet connection and try again.';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting AI advice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

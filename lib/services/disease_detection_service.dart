import 'dart:io';
import 'dart:math';

class DiseaseDetectionService {
  // Simulate disease detection
  // In production, this would use a machine learning model or API
  Future<DiseaseDetectionResult> detectDisease(File imageFile) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random detection for demo purposes
    final random = Random();
    final diseases = [
      DiseaseDetectionResult(
        diseaseName: 'Healthy Leaf',
        confidence: 0.85 + random.nextDouble() * 0.14,
        isHealthy: true,
        description:
            'The leaf appears to be healthy with no visible signs of disease.',
        treatment: 'Continue regular care and monitoring.',
      ),
      DiseaseDetectionResult(
        diseaseName: 'Wheat Rust',
        confidence: 0.75 + random.nextDouble() * 0.24,
        isHealthy: false,
        description:
            'Wheat rust is a fungal disease that appears as orange to reddish-brown pustules on leaves. It can significantly reduce yield if not treated promptly.',
        treatment:
            'Apply fungicide spray containing propiconazole or tebuconazole. Ensure good air circulation and avoid overhead irrigation. Remove affected plant debris.',
      ),
      DiseaseDetectionResult(
        diseaseName: 'Leaf Blight',
        confidence: 0.70 + random.nextDouble() * 0.29,
        isHealthy: false,
        description:
            'Leaf blight causes brown or black spots on leaves that may have yellow halos. The disease spreads rapidly in humid conditions.',
        treatment:
            'Remove affected leaves immediately. Apply copper-based fungicide. Improve air circulation and avoid watering leaves directly. Practice crop rotation.',
      ),
      DiseaseDetectionResult(
        diseaseName: 'Powdery Mildew',
        confidence: 0.80 + random.nextDouble() * 0.19,
        isHealthy: false,
        description:
            'Powdery mildew appears as white, powdery growth on leaf surfaces. It thrives in warm, dry conditions with high humidity.',
        treatment:
            'Spray with neem oil or sulfur-based fungicide. Increase air circulation around plants. Avoid overcrowding and water at soil level.',
      ),
      DiseaseDetectionResult(
        diseaseName: 'Nutrient Deficiency',
        confidence: 0.65 + random.nextDouble() * 0.34,
        isHealthy: false,
        description:
            'Yellow or pale leaves may indicate nutrient deficiency, commonly nitrogen, potassium, or magnesium deficiency.',
        treatment:
            'Apply balanced fertilizer based on soil test results. For nitrogen deficiency, use urea or ammonium sulfate. Ensure proper soil pH.',
      ),
    ];

    // Return a random result for demonstration
    return diseases[random.nextInt(diseases.length)];
  }
}

class DiseaseDetectionResult {
  final String diseaseName;
  final double confidence;
  final bool isHealthy;
  final String description;
  final String treatment;

  DiseaseDetectionResult({
    required this.diseaseName,
    required this.confidence,
    required this.isHealthy,
    required this.description,
    required this.treatment,
  });
}

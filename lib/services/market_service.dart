import 'dart:math';
import 'dart:developer' as developer;
import 'location_service.dart';
import 'package:geolocator/geolocator.dart';

class MarketService {
  // Get user's nearby markets based on GPS location
  Future<List<String>> getNearbyMarkets() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      if (position == null) {
        return _getDefaultMarkets();
      }

      // In a real app, this would query a markets database
      // For demo, we'll simulate location-based markets
      return _getMarketsForLocation(position.latitude, position.longitude);
    } catch (e) {
      developer.log('Error getting nearby markets: $e');
      return _getDefaultMarkets();
    }
  }

  List<String> _getDefaultMarkets() {
    return [
      'Delhi - APMC Market',
      'Mumbai - Vashi Market',
      'Bangalore - KR Market',
      'Chennai - Koyambedu Market',
      'Kolkata - Posta Market',
    ];
  }

  List<String> _getMarketsForLocation(double lat, double lon) {
    // Simulate location-based market selection
    final allMarkets = [
      'Delhi - APMC Market',
      'Gurgaon Mandi',
      'Noida Agricultural Market',
      'Mumbai - Vashi Market',
      'Pune Agricultural Market',
      'Bangalore - KR Market',
      'Mysore Mandi',
      'Chennai - Koyambedu Market',
      'Coimbatore Market',
      'Kolkata - Posta Market',
      'Burdwan Mandi',
      'Hyderabad Market',
      'Vijayawada Mandi',
      'Ahmedabad Market',
      'Vadodara Mandi',
      'Jaipur Agricultural Market',
      'Jodhpur Mandi',
      'Lucknow Market',
      'Kanpur Mandi',
      'Patna Agricultural Market',
    ];

    // Return random selection based on location (in real app, use actual proximity)
    final random = Random();
    allMarkets.shuffle(random);
    return allMarkets.take(8).toList();
  }

  // Search markets by name or region
  Future<List<String>> searchMarkets(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allMarkets = [
      'Delhi - APMC Market',
      'Gurgaon Mandi',
      'Noida Agricultural Market',
      'Mumbai - Vashi Market',
      'Pune Agricultural Market',
      'Bangalore - KR Market',
      'Mysore Mandi',
      'Chennai - Koyambedu Market',
      'Coimbatore Market',
      'Kolkata - Posta Market',
      'Burdwan Mandi',
      'Hyderabad Market',
      'Vijayawada Mandi',
      'Ahmedabad Market',
      'Vadodara Mandi',
      'Jaipur Agricultural Market',
      'Jodhpur Mandi',
      'Lucknow Market',
      'Kanpur Mandi',
      'Patna Agricultural Market',
    ];

    return allMarkets
        .where((market) => market.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get price trends for last 7 days
  Future<List<PriceTrendData>> getPriceTrends(
    String cropName,
    String market,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final random = Random();
    final basePrice = _getBasePriceForCrop(cropName);
    final trends = <PriceTrendData>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final variation = (random.nextDouble() - 0.5) * 0.3; // ±15% variation
      final price = basePrice * (1 + variation);

      trends.add(PriceTrendData(date: date, price: price));
    }

    return trends;
  }

  double _getBasePriceForCrop(String cropName) {
    final basePrices = {
      'Wheat': 2500.0,
      'Rice': 3200.0,
      'Cotton': 5800.0,
      'Sugarcane': 350.0,
      'Corn': 2100.0,
      'Barley': 1800.0,
      'Soybean': 4200.0,
      'Mustard': 4500.0,
      'Chickpea': 5500.0,
      'Lentil': 6200.0,
    };
    return basePrices[cropName] ?? 2000.0;
  }

  // Simulate fetching market prices
  // In production, this would fetch from a real market API
  Future<List<CropPrice>> getCropPrices(String market) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final random = Random();

    // Sample crop data with randomized prices for demonstration
    final List<Map<String, dynamic>> cropData = [
      {'name': 'Wheat', 'basePrice': 2500.0},
      {'name': 'Rice', 'basePrice': 3200.0},
      {'name': 'Cotton', 'basePrice': 5800.0},
      {'name': 'Sugarcane', 'basePrice': 350.0},
      {'name': 'Corn', 'basePrice': 2100.0},
      {'name': 'Barley', 'basePrice': 1800.0},
      {'name': 'Soybean', 'basePrice': 4200.0},
      {'name': 'Mustard', 'basePrice': 4500.0},
      {'name': 'Chickpea', 'basePrice': 5500.0},
      {'name': 'Lentil', 'basePrice': 6200.0},
    ];

    return cropData.map((crop) {
      final basePrice = crop['basePrice'] as double;
      final variation = (random.nextDouble() - 0.5) * 0.2; // ±10% variation
      final currentPrice = basePrice * (1 + variation);
      final changePercent = variation * 100;

      PriceTrend trend;
      if (changePercent > 1) {
        trend = PriceTrend.up;
      } else if (changePercent < -1) {
        trend = PriceTrend.down;
      } else {
        trend = PriceTrend.stable;
      }

      return CropPrice(
        cropName: crop['name'] as String,
        currentPrice: currentPrice,
        previousPrice: basePrice,
        changePercent: changePercent,
        trend: trend,
        market: market,
        lastUpdated: DateTime.now(),
      );
    }).toList();
  }
}

enum PriceTrend { up, down, stable }

class CropPrice {
  final String cropName;
  final double currentPrice;
  final double previousPrice;
  final double changePercent;
  final PriceTrend trend;
  final String market;
  final DateTime lastUpdated;

  CropPrice({
    required this.cropName,
    required this.currentPrice,
    required this.previousPrice,
    required this.changePercent,
    required this.trend,
    required this.market,
    required this.lastUpdated,
  });
}

class PriceTrendData {
  final DateTime date;
  final double price;

  PriceTrendData({required this.date, required this.price});
}

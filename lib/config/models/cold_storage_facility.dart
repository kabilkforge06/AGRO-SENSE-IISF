import 'dart:math' as math;

class ColdStorageFacility {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String contactNumber;
  final String email;
  final int capacity; // in tons
  final List<String> supportedCrops;
  final double pricePerTon;
  final String facilityType;
  final Map<String, dynamic> amenities;
  final double rating;
  final int reviewCount;
  final String ownerName;
  final String description;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ColdStorageFacility({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.contactNumber,
    required this.email,
    required this.capacity,
    required this.supportedCrops,
    required this.pricePerTon,
    required this.facilityType,
    required this.amenities,
    required this.rating,
    required this.reviewCount,
    required this.ownerName,
    required this.description,
    required this.imageUrls,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ColdStorageFacility.fromJson(Map<String, dynamic> json) {
    return ColdStorageFacility(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      contactNumber: json['contactNumber'] ?? '',
      email: json['email'] ?? '',
      capacity: json['capacity'] ?? 0,
      supportedCrops: List<String>.from(json['supportedCrops'] ?? []),
      pricePerTon: (json['pricePerTon'] ?? 0.0).toDouble(),
      facilityType: json['facilityType'] ?? 'Standard',
      amenities: Map<String, dynamic>.from(json['amenities'] ?? {}),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      ownerName: json['ownerName'] ?? '',
      description: json['description'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'contactNumber': contactNumber,
      'email': email,
      'capacity': capacity,
      'supportedCrops': supportedCrops,
      'pricePerTon': pricePerTon,
      'facilityType': facilityType,
      'amenities': amenities,
      'rating': rating,
      'reviewCount': reviewCount,
      'ownerName': ownerName,
      'description': description,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double distanceFrom(double userLat, double userLng) {
    // Haversine formula to calculate distance
    const double earthRadius = 6371; // km
    double dLat = _degreesToRadians(latitude - userLat);
    double dLng = _degreesToRadians(longitude - userLng);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(userLat)) *
            math.cos(_degreesToRadians(latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  bool get hasAvailableSpace => isActive;

  String get capacityString => '$capacity tons';

  String get priceString => '₹${pricePerTon.toStringAsFixed(0)}/ton';

  String get ratingString => rating.toStringAsFixed(1);
}

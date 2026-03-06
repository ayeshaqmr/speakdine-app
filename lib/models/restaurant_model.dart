class RestaurantData {
  final String restaurantName;
  final String description;
  final bool isVerified;
  final String phoneNumber;
  final String province;
  final String city;
  final String streetNumber;
  final String? floorNumber;
  final String zipCode;
  final double? latitude;
  final double? longitude;
  final List<BranchLocation> branches;
  final Map<String, OpeningHours> openingHours;

  RestaurantData({
    required this.restaurantName,
    required this.description,
    required this.isVerified,
    required this.phoneNumber,
    required this.province,
    required this.city,
    required this.streetNumber,
    this.floorNumber,
    required this.zipCode,
    this.latitude,
    this.longitude,
    required this.branches,
    required this.openingHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'restaurant_name': restaurantName,
      'description': description,
      'is_verified': isVerified,
      'phone_number': phoneNumber,
      'province': province,
      'city': city,
      'street_number': streetNumber,
      'floor_number': floorNumber,
      'zip_code': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'branches': branches.map((e) => e.toMap()).toList(),
      'opening_hours': openingHours.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory RestaurantData.fromMap(Map<String, dynamic> map) {
    return RestaurantData(
      restaurantName: map['restaurant_name'] ?? '',
      description: map['description'] ?? '',
      isVerified: map['is_verified'] ?? false,
      phoneNumber: map['phone_number'] ?? '',
      province: map['province'] ?? '',
      city: map['city'] ?? '',
      streetNumber: map['street_number'] ?? '',
      floorNumber: map['floor_number'],
      zipCode: map['zip_code'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
      branches: (map['branches'] as List<dynamic>?)
              ?.map((e) => BranchLocation.fromMap(e))
              .toList() ??
          [],
      openingHours: (map['opening_hours'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, OpeningHours.fromMap(value)),
          ) ??
          {},
    );
  }
}

class BranchLocation {
  final String name;
  final double latitude;
  final double longitude;

  BranchLocation({required this.name, required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory BranchLocation.fromMap(Map<String, dynamic> map) {
    return BranchLocation(
      name: map['name'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
    );
  }
}

class OpeningHours {
  final String openTime;
  final String closeTime;
  final bool isClosed;

  OpeningHours({
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'open_time': openTime,
      'close_time': closeTime,
      'is_closed': isClosed,
    };
  }

  factory OpeningHours.fromMap(Map<String, dynamic> map) {
    return OpeningHours(
      openTime: map['open_time'] ?? '',
      closeTime: map['close_time'] ?? '',
      isClosed: map['is_closed'] ?? false,
    );
  }
}

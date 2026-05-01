class Salon {
  final String id;
  final String slug;
  final String name;
  final String? logoUrl;
  final SalonAddress address;
  final double? distanceKm;
  final double? rating;

  const Salon({
    required this.id,
    required this.slug,
    required this.name,
    required this.address,
    this.logoUrl,
    this.distanceKm,
    this.rating,
  });

  String get formattedDistance {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).round()}m';
    return '${distanceKm!.toStringAsFixed(1)}km';
  }
}

class SalonAddress {
  final String street;
  final String city;
  final String state;
  final double? lat;
  final double? lng;

  const SalonAddress({
    required this.street,
    required this.city,
    required this.state,
    this.lat,
    this.lng,
  });

  String get displayAddress => '$street, $city - $state';
}

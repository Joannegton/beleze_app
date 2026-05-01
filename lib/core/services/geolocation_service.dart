import 'dart:math' as math;

class LocationCoordinates {
  final double latitude;
  final double longitude;

  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  double distanceTo(double latitude, double longitude) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((latitude - this.latitude) * p) / 2 +
        math.cos(this.latitude * p) *
            math.cos(latitude * p) *
            (1 - math.cos((longitude - this.longitude) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class LocationPermissionStatus {
  final bool isDenied;
  final bool isGranted;
  final bool isDeniedForever;

  const LocationPermissionStatus({
    required this.isDenied,
    required this.isGranted,
    required this.isDeniedForever,
  });

  bool get isPermanentlyDenied => isDeniedForever;
}

abstract interface class GeolocationService {
  Future<bool> requestPermission();
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationCoordinates?> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
}

class GeolocationServiceImpl implements GeolocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    // Integration with geolocator package:
    // final status = await Geolocator.checkPermission();
    // return LocationPermissionStatus(
    //   isDenied: status == LocationPermission.denied,
    //   isGranted: status == LocationPermission.whileInUse ||
    //       status == LocationPermission.always,
    //   isDeniedForever: status == LocationPermission.deniedForever,
    // );

    return const LocationPermissionStatus(
      isDenied: false,
      isGranted: false,
      isDeniedForever: false,
    );
  }

  @override
  Future<LocationCoordinates?> getCurrentLocation() async {
    // Integration with geolocator package:
    // try {
    //   final position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high,
    //     timeLimit: const Duration(seconds: 10),
    //   );
    //   return LocationCoordinates(
    //     latitude: position.latitude,
    //     longitude: position.longitude,
    //   );
    // } catch (e) {
    //   return null;
    // }

    return null;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    // Integration with geolocator package:
    // return Geolocator.isLocationServiceEnabled();

    return false;
  }

  @override
  Future<bool> requestPermission() async {
    // Integration with geolocator package:
    // final status = await Geolocator.requestPermission();
    // return status == LocationPermission.whileInUse ||
    //     status == LocationPermission.always;

    return false;
  }
}

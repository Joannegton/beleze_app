// Geolocation Integration Guide for ClientHomePage
//
// This file shows how to integrate geolocation to display nearby salons.
//
// Step 1: Add to pubspec.yaml
// ```yaml
// dependencies:
//   geolocator: ^11.0.0
// ```
//
// Step 2: Configure platform permissions
//
// iOS (ios/Runner/Info.plist):
// ```xml
// <key>NSLocationWhenInUseUsageDescription</key>
// <string>Precisamos de sua localização para encontrar salões próximos</string>
// ```
//
// Android (android/app/src/main/AndroidManifest.xml):
// ```xml
// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
// <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
// ```
//
// Step 3: Add to ClientHomePage initState
// ```dart
// @override
// void initState() {
//   super.initState();
//   _requestLocationAndLoadNearby();
// }
//
// Future<void> _requestLocationAndLoadNearby() async {
//   final permission = await _geolocationService.checkPermission();
//
//   if (!permission.isGranted) {
//     final granted = await _geolocationService.requestPermission();
//     if (!granted) return;
//   }
//
//   final isEnabled = await _geolocationService.isLocationServiceEnabled();
//   if (!isEnabled) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Ative localização no seu dispositivo')),
//     );
//     return;
//   }
//
//   final coords = await _geolocationService.getCurrentLocation();
//   if (coords != null && mounted) {
//     context.read<SalonListBloc>().add(
//       SalonListLoadRequested(lat: coords.latitude, lng: coords.longitude),
//     );
//   }
// }
// ```
//
// Step 4: Add button to appbar
// ```dart
// actions: [
//   IconButton(
//     icon: Icon(Icons.location_on, color: AppColors.primaryContainer),
//     onPressed: _requestLocationAndLoadNearby,
//     tooltip: 'Salões próximos',
//   ),
// ]
// ```

// Exemplo de widget para exibir distância
import 'package:flutter/material.dart';

class SalonDistanceWidget extends StatelessWidget {
  final double? distanceKm;
  final Color color;

  const SalonDistanceWidget({
    super.key,
    required this.distanceKm,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    if (distanceKm == null) return const SizedBox.shrink();

    final display = distanceKm! < 1.0
        ? '${(distanceKm! * 1000).round()}m'
        : '${distanceKm!.toStringAsFixed(1)}km';

    return Chip(
      label: Text(display),
      backgroundColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}

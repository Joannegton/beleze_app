# Phase 4 - Integrations Guide
## Firebase FCM, Deep Links, Geolocation, WebSocket

**Status:** Infrastructure Complete | Implementation Ready  
**Date:** 2026-04-30

---

## 1. Deep Links (✅ Implemented)

### What's Done
- Router supports direct salon access via `/:slug` catch-all route
- Deep links pattern: `beleze.app/meu-salao` → `SalonPage(slug: 'meu-salao')`
- Compatible with QR codes

### How It Works
```dart
// app_router.dart line 129
GoRoute(
  path: '/:slug',
  builder: (_, state) {
    final slug = state.pathParameters['slug'];
    if (slug != null && !slug.startsWith('__')) {
      return SalonPage(slug: slug);
    }
    return const SplashPage();
  },
),
```

### To Enable QR Codes
```dart
// In client_home_page.dart or new qr_scanner_page.dart
import 'package:qr_flutter/qr_flutter.dart';

// Generate QR for salon
QrImage(
  data: 'beleze.app/${salon.slug}',
  version: QrVersions.auto,
  size: 200.0,
)
```

---

## 2. Firebase FCM Push Notifications

### Setup Steps

#### Step 1: Add Dependencies
```bash
flutter pub add firebase_core firebase_messaging
```

#### Step 2: Configure Firebase
```dart
// In main.dart - before runApp()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

#### Step 3: Integrate NotificationService
```dart
// In main.dart
final notificationService = NotificationServiceImpl();
await notificationService.initialize();
await notificationService.requestPermission();

// Listen for notifications
notificationService.onNotificationReceived.listen((payload) {
  // Route based on notification type
  notificationService.handleNotificationTap(payload);
});
```

#### Step 4: Implement FCM Listeners
```dart
// In notification_service.dart - replace initialize()
@override
Future<void> initialize() async {
  final messaging = FirebaseMessaging.instance;
  
  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final payload = _parseRemoteMessage(message);
    _notificationController.add(payload);
  });
  
  // Handle background notifications
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final payload = _parseRemoteMessage(message);
    handleNotificationTap(payload);
  });
  
  // Handle terminated app launch
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    final payload = _parseRemoteMessage(initialMessage);
    handleNotificationTap(payload);
  }
}

NotificationPayload _parseRemoteMessage(RemoteMessage message) {
  return NotificationPayload(
    type: NotificationType.values.firstWhere(
      (e) => e.toString() == 'NotificationType.${message.data['type']}',
      orElse: () => NotificationType.custom,
    ),
    title: message.notification?.title ?? '',
    body: message.notification?.body ?? '',
    data: Map<String, String>.from(message.data),
  );
}
```

#### Step 5: Send Token to Backend
```dart
@override
Future<String?> getToken() async {
  final messaging = FirebaseMessaging.instance;
  final token = await messaging.getToken();
  
  // Send to backend: PATCH /users/me/fcm-token
  await _apiClient.patch(
    'users/me/fcm-token',
    data: {'fcmToken': token},
  );
  
  return token;
}
```

### Backend API Endpoints Needed
```
POST /tenants/:tenantId/notifications/appointment-created
  {
    "professionalIds": ["id1", "id2"],
    "title": "Novo agendamento",
    "body": "{{clientName}} agendou um serviço",
    "data": {
      "type": "newAppointment",
      "appointmentId": "...",
      "tenantId": "...",
      "professionalId": "..."
    }
  }

POST /tenants/:tenantId/notifications/appointment-cancelled
  Similar structure for cancellations
```

---

## 3. Geolocation - Nearby Salons

### Setup Steps

#### Step 1: Add Dependencies
```bash
flutter pub add geolocator
```

#### Step 2: Configure Platform-Specific Permissions

**iOS (ios/Runner/Info.plist)**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos de sua localização para encontrar salões próximos</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Salões próximos de você</string>
```

**Android (android/app/src/main/AndroidManifest.xml)**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### Step 3: Complete GeolocationService Implementation
```dart
// In geolocation_service.dart - replace implementations
@override
Future<PermissionStatus> checkPermission() async {
  final status = await Geolocator.checkPermission();
  return PermissionStatus(
    isDenied: status == LocationPermission.denied,
    isGranted: status == LocationPermission.whileInUse ||
        status == LocationPermission.always,
    isDeniedForever: status == LocationPermission.deniedForever,
  );
}

@override
Future<LocationCoordinates?> getCurrentLocation() async {
  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LocationCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (e) {
    return null;
  }
}

@override
Future<bool> requestPermission() async {
  final status = await Geolocator.requestPermission();
  return status == LocationPermission.whileInUse ||
      status == LocationPermission.always;
}
```

#### Step 4: Integrate in SalonListBloc
```dart
// In salon_list_bloc.dart or new event
class SalonListLoadNearbyRequested extends SalonListEvent {
  const SalonListLoadNearbyRequested();
}

// In _mapLoadNearbyToState
void _mapLoadNearbyToState(
  SalonListLoadNearbyRequested event,
  Emitter<SalonListState> emit,
) async {
  emit(const SalonListLoading());
  
  final hasPermission = await _geoService.requestPermission();
  if (!hasPermission) {
    emit(const SalonListError('Permissão de localização negada'));
    return;
  }
  
  final coords = await _geoService.getCurrentLocation();
  if (coords == null) {
    emit(const SalonListError('Não foi possível obter localização'));
    return;
  }
  
  final result = await _salonRepository.getNearbySalons(
    lat: coords.latitude,
    lng: coords.longitude,
  );
  
  result.fold(
    (failure) => emit(SalonListError(failure.message)),
    (salons) {
      // Sort by distance
      salons.sort((a, b) {
        final distA = coords.distanceTo(a.latitude, a.longitude);
        final distB = coords.distanceTo(b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
      emit(SalonListLoaded(salons));
    },
  );
}
```

#### Step 5: UI Button in ClientHomePage
```dart
// Add to appbar actions
IconButton(
  icon: Icon(Icons.location_on, color: AppColors.primaryContainer),
  onPressed: () {
    context.read<SalonListBloc>().add(
      const SalonListLoadNearbyRequested(),
    );
  },
  tooltip: 'Salões próximos',
),
```

---

## 4. WebSocket - Real-time KPI Updates

### Setup Steps

#### Step 1: Add Dependencies
```bash
flutter pub add socket_io_client
```

#### Step 2: Complete WebSocketService Implementation
```dart
// In websocket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketServiceImpl implements WebSocketService {
  late IO.Socket _socket;
  
  @override
  Future<void> connect(String tenantId) async {
    _socket = IO.io(
      'wss://api.beleze.app',
      IO.SocketIoClientOption(
        query: {'tenantId': tenantId},
        reconnection: true,
        reconnectionDelay: const Duration(seconds: 1),
        reconnectionDelayMax: const Duration(seconds: 5),
      ),
    );
    
    _socket.on('kpi:update', (data) {
      final kpi = RealtimeKPI(
        totalAppointments: data['totalAppointments'] as int,
        occupancyRate: (data['occupancyRate'] as num).toDouble(),
        expectedRevenue: (data['expectedRevenue'] as num).toDouble(),
        alerts: List<String>.from(data['alerts'] as List),
      );
      _kpiController.add(kpi);
    });
    
    _socket.on('appointment:created', (data) {
      final event = AppointmentEvent(
        appointmentId: data['appointmentId'] as String,
        status: data['status'] as String,
        professionalName: data['professionalName'] as String,
        serviceName: data['serviceName'] as String,
      );
      _appointmentController.add(event);
    });
    
    _socket.connect();
    _isConnected = true;
  }
  
  @override
  Future<void> disconnect() async {
    _socket.disconnect();
    _isConnected = false;
  }
}
```

#### Step 3: Integrate in OwnerDashboardPage
```dart
// In owner_dashboard_page.dart initState
@override
void initState() {
  super.initState();
  // ... existing code ...
  
  // Connect to WebSocket for real-time updates
  _webSocketService = WebSocketServiceImpl();
  _webSocketService.connect(_tenantId!);
  
  // Listen to KPI updates
  _webSocketService.onKPIUpdate.listen((kpi) {
    if (mounted) {
      setState(() {
        _totalAppointments = kpi.totalAppointments;
        _occupancyRate = kpi.occupancyRate;
        _expectedRevenue = kpi.expectedRevenue;
        _alerts = kpi.alerts;
      });
    }
  });
}

@override
void dispose() {
  _webSocketService.disconnect();
  super.dispose();
}
```

### Backend WebSocket Events
```javascript
// Server should emit these events
socket.emit('kpi:update', {
  totalAppointments: 12,
  occupancyRate: 85.5,
  expectedRevenue: 1200.50,
  alerts: ['no-show: João Silva', 'cancelamento: Cliente A']
});

socket.emit('appointment:created', {
  appointmentId: '507f1f77bcf86cd799439011',
  status: 'confirmed',
  professionalName: 'Maria Silva',
  serviceName: 'Corte de cabelo'
});
```

---

## 5. Implementation Checklist

### Phase 4.1 - Deep Links ✅
- [x] Deep link route handler in AppRouter
- [ ] QR code generation widget
- [ ] QR scanner page
- [ ] Test with actual deep links

### Phase 4.2 - Firebase FCM ⏳
- [ ] Add firebase_core + firebase_messaging
- [ ] Configure Firebase project
- [ ] Implement NotificationServiceImpl fully
- [ ] Add notification handling routes
- [ ] Test foreground/background notifications

### Phase 4.3 - Geolocation ⏳
- [ ] Add geolocator package
- [ ] Complete GeolocationService
- [ ] Add platform-specific permissions
- [ ] Integrate SalonListBloc with geolocation
- [ ] Add "Nearby Salons" button
- [ ] Test on real device

### Phase 4.4 - WebSocket ⏳
- [ ] Add socket_io_client package
- [ ] Complete WebSocketService
- [ ] Integrate OwnerDashboardPage
- [ ] Test real-time updates
- [ ] Handle connection loss gracefully

---

## Files Structure

```
lib/core/services/
  ├── notification_service.dart ✅ (Complete interface)
  ├── geolocation_service.dart ✅ (Complete interface)
  └── websocket_service.dart ✅ (Complete interface)

lib/core/router/
  └── app_router.dart ✅ (Deep links enabled)
```

## Next Steps

1. **Priority 1:** Firebase FCM (user engagement critical)
2. **Priority 2:** Deep Links + QR Scanner
3. **Priority 3:** Geolocation (nice-to-have)
4. **Priority 4:** WebSocket (nice-to-have for real-time)

Each integration can be done independently. Start with Firebase FCM for push notifications.

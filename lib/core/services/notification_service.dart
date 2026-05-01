import 'dart:async';
import 'package:go_router/go_router.dart';

enum NotificationType {
  newAppointment,
  appointmentCancelled,
  appointmentReminder,
  paymentReceived,
  custom,
}

extension NotificationTypeExtension on NotificationType {
  static NotificationType fromString(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => NotificationType.custom,
    );
  }

  String toStringValue() => toString().split('.').last;
}

class NotificationPayload {
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, String> data;
  final DateTime timestamp;

  NotificationPayload({
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String? get appointmentId => data['appointmentId'];
  String? get tenantId => data['tenantId'];
  String? get professionalId => data['professionalId'];
  String? get salonSlug => data['salonSlug'];
  String? get clientName => data['clientName'];
  String? get serviceName => data['serviceName'];
}

abstract interface class NotificationService {
  Future<void> initialize();
  Future<String?> getToken();
  Future<void> sendTokenToBackend(String token);
  Stream<NotificationPayload> get onNotificationReceived;
  Future<void> handleNotificationTap(NotificationPayload payload, GoRouter router);
  Future<void> requestPermission();
  Future<bool> isPermissionGranted();
  void dispose();
}

class NotificationServiceImpl implements NotificationService {
  final _notificationController = StreamController<NotificationPayload>.broadcast();
  String? _fcmToken;

  @override
  Stream<NotificationPayload> get onNotificationReceived =>
      _notificationController.stream;

  @override
  Future<void> initialize() async {
    // Firebase initialization happens in main.dart
    // This method is called after Firebase.initializeApp()
    _fcmToken = await getToken();

    // Listen to foreground notifications
    _listenToForegroundNotifications();

    // Listen to background tap
    _listenToBackgroundTap();
  }

  void _listenToForegroundNotifications() {
    // Firebase FCM implementation with firebase_messaging package
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   final payload = _parseRemoteMessage(message);
    //   _notificationController.add(payload);
    // });
  }

  void _listenToBackgroundTap() {
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   final payload = _parseRemoteMessage(message);
    //   // Router navigation happens in app wrapper listener
    // });
  }

  @override
  Future<String?> getToken() async {
    // return FirebaseMessaging.instance.getToken();
    return null;
  }

  @override
  Future<void> sendTokenToBackend(String token) async {
    // Send FCM token to backend for storing user's notification registration
    // await apiClient.patch('/users/me/fcm-token', data: {'fcmToken': token});
  }

  @override
  Future<void> requestPermission() async {
    // final settings = await FirebaseMessaging.instance.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //   // Permission granted
    // }
  }

  @override
  Future<bool> isPermissionGranted() async {
    // final settings = await FirebaseMessaging.instance.getNotificationSettings();
    // return settings.authorizationStatus == AuthorizationStatus.authorized;
    return false;
  }

  @override
  Future<void> handleNotificationTap(NotificationPayload payload, GoRouter router) async {
    switch (payload.type) {
      case NotificationType.newAppointment:
        if (payload.appointmentId != null) {
          router.push('/professional/appointment/${payload.appointmentId}');
        }
      case NotificationType.appointmentCancelled:
        if (payload.tenantId != null) {
          router.push('/professional/schedule');
        }
      case NotificationType.appointmentReminder:
        if (payload.appointmentId != null) {
          router.push('/professional/appointment/${payload.appointmentId}');
        }
      case NotificationType.paymentReceived:
        router.push('/owner/financials');
      case NotificationType.custom:
        break;
    }
  }

  NotificationPayload _parseRemoteMessage(dynamic message) {
    final data = Map<String, String>.from(message.data ?? {});
    final typeStr = data.remove('type') ?? 'custom';

    return NotificationPayload(
      type: NotificationTypeExtension.fromString(typeStr),
      title: message.notification?.title ?? 'Notificação',
      body: message.notification?.body ?? '',
      data: data,
    );
  }

  void emitNotification(NotificationPayload payload) {
    _notificationController.add(payload);
  }

  void dispose() {
    _notificationController.close();
  }
}

import 'dart:async';

class RealtimeKPI {
  final int totalAppointments;
  final double occupancyRate;
  final double expectedRevenue;
  final List<String> alerts;
  final DateTime timestamp;

  RealtimeKPI({
    required this.totalAppointments,
    required this.occupancyRate,
    required this.expectedRevenue,
    required this.alerts,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory RealtimeKPI.fromJson(Map<String, dynamic> json) {
    return RealtimeKPI(
      totalAppointments: json['totalAppointments'] as int? ?? 0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
      expectedRevenue: (json['expectedRevenue'] as num?)?.toDouble() ?? 0.0,
      alerts: List<String>.from(json['alerts'] as List? ?? []),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
}

class AppointmentEvent {
  final String appointmentId;
  final String status;
  final String professionalName;
  final String serviceName;
  final DateTime createdAt;

  AppointmentEvent({
    required this.appointmentId,
    required this.status,
    required this.professionalName,
    required this.serviceName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppointmentEvent.fromJson(Map<String, dynamic> json) {
    return AppointmentEvent(
      appointmentId: json['appointmentId'] as String,
      status: json['status'] as String,
      professionalName: json['professionalName'] as String,
      serviceName: json['serviceName'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

abstract interface class WebSocketService {
  Future<void> connect(String tenantId);
  Future<void> disconnect();
  Stream<RealtimeKPI> get onKPIUpdate;
  Stream<AppointmentEvent> get onAppointmentEvent;
  bool get isConnected;
  Future<void> reconnect(String tenantId);
}

class WebSocketServiceImpl implements WebSocketService {
  final _kpiController = StreamController<RealtimeKPI>.broadcast();
  final _appointmentController = StreamController<AppointmentEvent>.broadcast();

  bool _isConnected = false;
  String? _currentTenantId;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<RealtimeKPI> get onKPIUpdate => _kpiController.stream;

  @override
  Stream<AppointmentEvent> get onAppointmentEvent =>
      _appointmentController.stream;

  @override
  Future<void> connect(String tenantId) async {
    _currentTenantId = tenantId;

    // Socket.IO integration with socket_io_client package:
    // ```dart
    // import 'package:socket_io_client/socket_io_client.dart' as IO;
    //
    // _socket = IO.io(
    //   'wss://api.beleze.app',
    //   IO.SocketIoClientOption(
    //     query: {'tenantId': tenantId},
    //     reconnection: true,
    //     reconnectionDelay: const Duration(seconds: 1),
    //     reconnectionDelayMax: const Duration(seconds: 5),
    //     reconnectionAttempts: 10,
    //   ),
    // );
    //
    // _socket.on('connect', (_) {
    //   _isConnected = true;
    //   print('WebSocket connected');
    // });
    //
    // _socket.on('disconnect', (_) {
    //   _isConnected = false;
    //   print('WebSocket disconnected');
    // });
    //
    // _socket.on('kpi:update', (data) {
    //   final kpi = RealtimeKPI.fromJson(data as Map<String, dynamic>);
    //   _kpiController.add(kpi);
    // });
    //
    // _socket.on('appointment:created', (data) {
    //   final event = AppointmentEvent.fromJson(data as Map<String, dynamic>);
    //   _appointmentController.add(event);
    // });
    //
    // _socket.on('appointment:updated', (data) {
    //   final event = AppointmentEvent.fromJson(data as Map<String, dynamic>);
    //   _appointmentController.add(event);
    // });
    //
    // _socket.on('error', (error) {
    //   print('WebSocket error: $error');
    // });
    //
    // _socket.connect();
    // ```

    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    // _socket.disconnect();
    _isConnected = false;
  }

  @override
  Future<void> reconnect(String tenantId) async {
    await disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect(tenantId);
  }

  void dispose() {
    _kpiController.close();
    _appointmentController.close();
  }

  // Helper methods for testing/mock notifications
  void emitMockKPIUpdate(RealtimeKPI kpi) {
    _kpiController.add(kpi);
  }

  void emitMockAppointmentEvent(AppointmentEvent event) {
    _appointmentController.add(event);
  }
}

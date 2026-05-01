// WebSocket Integration Guide for OwnerDashboardPage
//
// This file shows how to integrate WebSocket for real-time KPI updates.
//
// Step 1: Add to pubspec.yaml
// ```yaml
// dependencies:
//   socket_io_client: ^2.0.0
// ```
//
// Step 2: Add to OwnerDashboardPage state
// ```dart
// class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
//   late WebSocketService _webSocketService;
//   StreamSubscription<RealtimeKPI>? _kpiSubscription;
//   StreamSubscription<AppointmentEvent>? _appointmentSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     // ... existing code ...
//
//     _webSocketService = WebSocketServiceImpl();
//     _connectWebSocket();
//   }
//
//   Future<void> _connectWebSocket() async {
//     if (_tenantId == null) return;
//
//     await _webSocketService.connect(_tenantId!);
//
//     // Listen to KPI updates
//     _kpiSubscription = _webSocketService.onKPIUpdate.listen((kpi) {
//       if (mounted) {
//         setState(() {
//           _totalAppointments = kpi.totalAppointments;
//           _occupancyRate = kpi.occupancyRate;
//           _expectedRevenue = kpi.expectedRevenue;
//           _alerts = kpi.alerts;
//         });
//       }
//     });
//
//     // Listen to appointment events
//     _appointmentSubscription =
//         _webSocketService.onAppointmentEvent.listen((event) {
//       if (mounted) {
//         // Refresh appointments or show notification
//         _loadToday();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _kpiSubscription?.cancel();
//     _appointmentSubscription?.cancel();
//     _webSocketService.disconnect();
//     super.dispose();
//   }
// }
// ```
//
// Step 3: Backend server setup
// The backend should emit Socket.IO events:
//
// ```javascript
// // Node.js example with socket.io
// io.on('connection', (socket) => {
//   socket.on('subscribe-tenant', (tenantId) => {
//     socket.join(`tenant-${tenantId}`);
//   });
// });
//
// // Send KPI updates to salon owner
// function emitKPIUpdate(tenantId, kpi) {
//   io.to(`tenant-${tenantId}`).emit('kpi:update', {
//     totalAppointments: kpi.count,
//     occupancyRate: kpi.occupancy * 100,
//     expectedRevenue: kpi.revenue,
//     alerts: kpi.alerts,
//     timestamp: new Date().toISOString()
//   });
// }
//
// // Notify when new appointment created
// function notifyNewAppointment(tenantId, appointment) {
//   io.to(`tenant-${tenantId}`).emit('appointment:created', {
//     appointmentId: appointment.id,
//     status: appointment.status,
//     professionalName: appointment.professional.name,
//     serviceName: appointment.service.name,
//     createdAt: new Date().toISOString()
//   });
// }
// ```
//
// Step 4: Test with mock data
// For development/testing without backend:
// ```dart
// // In OwnerDashboardPage
// void _emitMockKPIUpdate() {
//   final kpi = RealtimeKPI(
//     totalAppointments: 8,
//     occupancyRate: 85.5,
//     expectedRevenue: 1200.50,
//     alerts: ['no-show: João Silva', 'cancelamento pendente'],
//   );
//   (_webSocketService as WebSocketServiceImpl).emitMockKPIUpdate(kpi);
// }
// ```

import 'package:flutter/material.dart';

// Widget to display real-time alerts from WebSocket
class RealtimeAlertsList extends StatelessWidget {
  final List<String> alerts;

  const RealtimeAlertsList({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertas em tempo real',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...alerts.map((alert) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

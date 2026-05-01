import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'notification_service.dart';

class AppNotificationListener extends StatefulWidget {
  final Widget child;
  final NotificationService notificationService;

  const AppNotificationListener({
    super.key,
    required this.child,
    required this.notificationService,
  });

  @override
  State<AppNotificationListener> createState() =>
      _AppNotificationListenerState();
}

class _AppNotificationListenerState extends State<AppNotificationListener> {
  late final GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);

    // Listen for incoming notifications
    widget.notificationService.onNotificationReceived.listen((payload) {
      _handleNotification(payload);
    });
  }

  void _handleNotification(NotificationPayload payload) {
    // Show snackbar for foreground notifications
    _showNotificationSnackBar(payload);

    // Route on tap (used when user opens notification from notification center)
    // Router navigation is handled by handleNotificationTap when accessed via
    // notification center taps
  }

  void _showNotificationSnackBar(NotificationPayload payload) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payload.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(payload.body),
          ],
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Abrir',
          onPressed: () {
            widget.notificationService.handleNotificationTap(payload, _router);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    widget.notificationService.dispose();
    super.dispose();
  }
}

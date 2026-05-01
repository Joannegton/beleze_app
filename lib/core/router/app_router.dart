import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/salon/presentation/client/pages/booking_confirmation_page.dart';
import '../../features/salon/presentation/client/pages/booking_page.dart';
import '../../features/salon/presentation/client/pages/client_appointments_page.dart';
import '../../features/salon/presentation/client/pages/client_favorites_page.dart';
import '../../features/salon/presentation/client/pages/client_home_page.dart';
import '../../features/salon/presentation/client/pages/client_profile_page.dart';
import '../../features/salon/presentation/client/pages/qr_scanner_page.dart';
import '../../features/salon/presentation/client/pages/salon_page.dart';
import '../../features/salon/presentation/owner/pages/onboarding_page.dart';
import '../../features/salon/presentation/owner/pages/owner_dashboard_page.dart';
import '../../features/salon/presentation/owner/pages/owner_financials_page.dart';
import '../../features/salon/presentation/owner/pages/owner_schedule_page.dart';
import '../../features/salon/presentation/owner/pages/owner_services_page.dart';
import '../../features/salon/presentation/owner/pages/owner_settings_page.dart';
import '../../features/salon/presentation/owner/pages/owner_team_page.dart';
import '../../features/salon/presentation/professional/pages/appointment_detail_page.dart';
import '../../features/salon/presentation/professional/pages/professional_blocks_page.dart';
import '../../features/salon/presentation/professional/pages/professional_profile_page.dart';
import '../../features/salon/presentation/professional/pages/professional_schedule_page.dart';

class AppRouter {
  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (authState is AuthUnauthenticated && !isAuthRoute) {
          return '/login';
        }
        return null;
      },
      refreshListenable: _AuthBlocListenable(authBloc),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

        // Client routes
        GoRoute(path: '/client/home', builder: (_, __) => const ClientHomePage()),
        GoRoute(path: '/client/qr-scanner', builder: (_, __) => const QRScannerPage()),
        GoRoute(
          path: '/client/salon/:slug',
          builder: (_, state) =>
              SalonPage(slug: state.pathParameters['slug']!),
        ),
        GoRoute(path: '/client/booking', builder: (_, __) => const BookingPage()),
        GoRoute(
          path: '/client/booking/confirmation',
          builder: (_, __) => const BookingConfirmationPage(),
        ),
        GoRoute(
          path: '/client/appointments',
          builder: (_, __) => const ClientAppointmentsPage(),
        ),
        GoRoute(
          path: '/client/profile',
          builder: (_, __) => const ClientProfilePage(),
        ),
        GoRoute(
          path: '/client/favorites',
          builder: (_, __) => const ClientFavoritesPage(),
        ),

        // Professional routes
        GoRoute(
          path: '/professional/schedule',
          builder: (_, __) => const ProfessionalSchedulePage(),
        ),
        GoRoute(
          path: '/professional/appointment/:appointmentId',
          builder: (_, state) => AppointmentDetailPage(
            appointmentId: state.pathParameters['appointmentId']!,
          ),
        ),
        GoRoute(
          path: '/professional/profile',
          builder: (_, __) => const ProfessionalProfilePage(),
        ),
        GoRoute(
          path: '/professional/blocks',
          builder: (_, state) {
            final tenantId = state.uri.queryParameters['tenantId'] ?? '';
            final professionalId =
                state.uri.queryParameters['professionalId'] ?? '';
            return ProfessionalBlocksPage(
              tenantId: tenantId,
              professionalId: professionalId,
            );
          },
        ),

        // Owner routes
        GoRoute(
          path: '/owner/onboarding',
          builder: (_, __) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/owner/dashboard',
          builder: (_, __) => const OwnerDashboardPage(),
        ),
        GoRoute(
          path: '/owner/schedule',
          builder: (_, __) => const OwnerSchedulePage(),
        ),
        GoRoute(
          path: '/owner/services',
          builder: (_, __) => const OwnerServicesPage(),
        ),
        GoRoute(
          path: '/owner/team',
          builder: (_, __) => const OwnerTeamPage(),
        ),
        GoRoute(
          path: '/owner/financials',
          builder: (_, __) => const OwnerFinancialsPage(),
        ),
        GoRoute(
          path: '/owner/settings',
          builder: (_, __) => const OwnerSettingsPage(),
        ),

        // Deep link: direct salon access via slug (e.g., /meu-salao)
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
      ],
    );
  }
}

class _AuthBlocListenable extends ChangeNotifier {
  final AuthBloc _bloc;

  _AuthBlocListenable(this._bloc) {
    _bloc.stream.listen((_) => notifyListeners());
  }
}

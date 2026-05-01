import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_session.dart';
import '../bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckSessionRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _redirectByRole(context, state);
        } else if (state is AuthUnauthenticated || state is AuthFailure) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BELEZE',
                style: GoogleFonts.manrope(
                  color: AppColors.primaryContainer,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(
                color: AppColors.primaryContainer,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _redirectByRole(BuildContext context, AuthAuthenticated state) {
    switch (state.session.role) {
      case UserRole.owner:
        context.go('/owner/dashboard');
      case UserRole.professional:
        context.go('/professional/schedule');
      case UserRole.client:
        context.go('/client/home');
    }
  }
}

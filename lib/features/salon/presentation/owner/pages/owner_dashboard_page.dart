import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/beleze_bottom_nav.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/repositories/appointment_repository.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  List<Appointment>? _todayAppointments;
  bool _loading = true;
  String? _tenantId;
  String? _ownerName;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _tenantId = authState.session.tenantId;
      _ownerName = authState.session.email.split('@').first;
    }
    _loadToday();
  }

  Future<void> _loadToday() async {
    if (_tenantId == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);
    final result = await context.read<AppointmentRepository>().getDaySchedule(
      tenantId: _tenantId!,
      date: DateTime.now(),
    );
    if (!mounted) return;

    result.fold(
      (error) {
        setState(() => _loading = false);
      },
      (listAppointments) {
        setState(() {
          _todayAppointments = listAppointments;
          _loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final confirmed =
        _todayAppointments
            ?.where((a) => a.status == AppointmentStatus.confirmed)
            .length ??
        0;
    final revenue =
        _todayAppointments
            ?.where(
              (a) =>
                  a.status == AppointmentStatus.confirmed ||
                  a.status == AppointmentStatus.completed,
            )
            .fold(0.0, (sum, a) => sum + a.pricePaid) ??
        0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Painel de Gestão',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined, color: AppColors.onSurface),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadToday,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bom dia, ${_ownerName?.split(' ').first ?? 'Proprietário'}!',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(DateTime.now()).capitalize(),
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Agendamentos',
                      value: '${_todayAppointments?.length ?? 0}',
                      icon: Icons.calendar_today_outlined,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      label: 'Confirmados',
                      value: '$confirmed',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _KpiCard(
                label: 'Faturamento previsto',
                value: 'R\$ ${revenue.toStringAsFixed(2).replaceAll('.', ',')}',
                icon: Icons.attach_money,
                color: AppColors.primaryContainer,
                fullWidth: true,
              ),
              const SizedBox(height: 28),
              Text(
                'Agenda de hoje',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  letterSpacing: 0.05,
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryContainer,
                    ),
                  ),
                )
              else if (_todayAppointments == null ||
                  _todayAppointments!.isEmpty)
                const _EmptyToday()
              else
                ..._todayAppointments!.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DayAppointmentTile(a),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BelezeBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          switch (i) {
            case 1:
              context.go('/owner/services');
            case 2:
              context.go('/owner/team');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spa_outlined),
            label: 'Serviços',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Equipe',
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: fullWidth
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.05,
                  ),
                ),
              ],
            ),
    );
  }
}

class _DayAppointmentTile extends StatelessWidget {
  final Appointment appointment;

  const _DayAppointmentTile(this.appointment);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final statusColor = _getStatusColor(appointment.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
          top: BorderSide(color: AppColors.outlineVariant),
          right: BorderSide(color: AppColors.outlineVariant),
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              timeFormat.format(appointment.startTime),
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryContainer,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.serviceName,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'com ${appointment.professionalName}',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'R\$ ${appointment.pricePaid.toStringAsFixed(2).replaceAll('.', ',')}',
            style: GoogleFonts.manrope(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.confirmed => AppColors.success,
      AppointmentStatus.completed => AppColors.primaryContainer,
      AppointmentStatus.cancelled => AppColors.error,
      AppointmentStatus.noShow => AppColors.warning,
      _ => AppColors.outlineVariant,
    };
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum agendamento para hoje.',
              style: GoogleFonts.manrope(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

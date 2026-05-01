import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/beleze_bottom_nav.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/repositories/appointment_repository.dart';

class ClientAppointmentsPage extends StatefulWidget {
  const ClientAppointmentsPage({super.key});

  @override
  State<ClientAppointmentsPage> createState() => _ClientAppointmentsPageState();
}

class _ClientAppointmentsPageState extends State<ClientAppointmentsPage> {
  List<Appointment>? _appointments;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await context.read<AppointmentRepository>().getMyAppointments();
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (list) => setState(() {
        _appointments = list;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Meus Agendamentos',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _appointments!.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: _appointments!.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _AppointmentCard(
                            appointment: _appointments![i],
                            onCancel: _load,
                          ),
                        ),
                      ),
                    ),
      bottomNavigationBar: BelezeBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.go('/client/home');
          if (i == 1) {} // Already on appointments
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Agendamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onCancel;

  const _AppointmentCard({required this.appointment, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat("HH:mm");
    final dateFormat = DateFormat("EEE, d 'de' MMM", 'pt_BR');
    final isPast = appointment.endTime.isBefore(DateTime.now());
    final canCancel = !isPast &&
        (appointment.status == AppointmentStatus.confirmed ||
            appointment.status == AppointmentStatus.pending);

    final statusColor = _getStatusColor(appointment.status);
    final statusLabel = appointment.status.label;

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.serviceName,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'com ${appointment.professionalName}',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                    letterSpacing: 0.05,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppColors.primaryContainer),
              const SizedBox(width: 8),
              Text(
                '${timeFormat.format(appointment.startTime)} - ${timeFormat.format(appointment.endTime)}',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 16, color: AppColors.primaryContainer),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(appointment.startTime).capitalize(),
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'R\$ ${appointment.pricePaid.toStringAsFixed(2).replaceAll('.', ',')}',
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryContainer,
            ),
          ),
          if (canCancel) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => context.push(
                      '/client/booking?appointmentId=${appointment.id}',
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: Text(
                      'Reagendar',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _confirmCancel(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'Cancelar agendamento?',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Deseja realmente cancelar este agendamento?',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Manter',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              'Cancelar',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final result = await context
          .read<AppointmentRepository>()
          .cancelAppointment(appointment.id);
      if (context.mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(f.message),
              backgroundColor: AppColors.error,
            ),
          ),
          (_) {
            onCancel();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Agendamento cancelado com sucesso'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      }
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.confirmed => AppColors.success,
      AppointmentStatus.cancelled => AppColors.error,
      AppointmentStatus.completed => AppColors.primaryContainer,
      AppointmentStatus.noShow => AppColors.warning,
      _ => AppColors.outlineVariant,
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Você não tem agendamentos.',
            style: GoogleFonts.manrope(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/client/home'),
            icon: const Icon(Icons.search),
            label: const Text('Buscar salões'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

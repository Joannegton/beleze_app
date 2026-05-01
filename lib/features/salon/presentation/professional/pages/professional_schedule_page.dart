import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/repositories/appointment_repository.dart';

class ProfessionalSchedulePage extends StatefulWidget {
  const ProfessionalSchedulePage({super.key});

  @override
  State<ProfessionalSchedulePage> createState() =>
      _ProfessionalSchedulePageState();
}

class _ProfessionalSchedulePageState extends State<ProfessionalSchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Appointment>? _appointments;
  bool _loading = false;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule(_selectedDay);
  }

  Future<void> _loadSchedule(DateTime date) async {
    setState(() => _loading = true);
    final result = await context
        .read<AppointmentRepository>()
        .getProfessionalSchedule(date: date);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (list) => setState(() {
        _appointments = list;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Minha Agenda',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: AppColors.onSurface),
            tooltip: 'Perfil',
            onPressed: () => context.push('/professional/profile'),
          ),
          IconButton(
            icon: Icon(Icons.block_outlined, color: AppColors.onSurface),
            tooltip: 'Bloqueios',
            onPressed: () {
              final session =
                  (context.read<AuthBloc>().state as AuthAuthenticated).session;
              context.push(
                '/professional/blocks'
                '?tenantId=${session.tenantId ?? ''}'
                '&professionalId=${session.userId}',
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout_outlined, color: AppColors.onSurface),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surfaceContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 60)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
                _loadSchedule(selected);
              },
              calendarFormat: CalendarFormat.week,
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.primaryContainer, width: 2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                ),
                defaultTextStyle: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
                outsideTextStyle: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
                weekendTextStyle: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.primaryContainer,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.primaryContainer,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.outlineVariant),
          Container(
            color: AppColors.surfaceContainer,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _showHistory ? 'Histórico' : 'Próximos agendamentos',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: _showHistory,
                  onChanged: (v) => setState(() => _showHistory = v),
                  activeThumbColor: AppColors.primaryContainer,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.outlineVariant),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryContainer))
                : _appointments == null || _appointments!.isEmpty
                    ? const _EmptyDay()
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _showHistory
                                  ? 'Agendamentos passados'
                                  : 'Agenda para ${dateFormat.format(_selectedDay).capitalize()}',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.05,
                              ),
                            ),
                          ),
                          ..._appointments!
                              .where((apt) {
                                if (_showHistory) {
                                  return apt.endTime.isBefore(DateTime.now());
                                } else {
                                  return !apt.endTime.isBefore(DateTime.now());
                                }
                              })
                              .map(
                                (apt) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => context.push(
                                      '/professional/appointment/${apt.id}',
                                    ),
                                    child: _AppointmentTile(apt),
                                  ),
                                ),
                              ),
                          const SizedBox(height: 20),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentTile(this.appointment);

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
        children: [
          SizedBox(
            width: 65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeFormat.format(appointment.startTime),
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeFormat.format(appointment.endTime),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${appointment.id.substring(0, 8).toUpperCase()}',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${appointment.pricePaid.toStringAsFixed(2).replaceAll('.', ',')}',
                style: GoogleFonts.manrope(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              _StatusIndicator(status: appointment.status),
            ],
          ),
        ],
      ),
    );
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

class _StatusIndicator extends StatelessWidget {
  final AppointmentStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AppointmentStatus.confirmed => AppColors.success,
      AppointmentStatus.cancelled => AppColors.error,
      AppointmentStatus.completed => AppColors.primaryContainer,
      AppointmentStatus.noShow => AppColors.warning,
      _ => AppColors.outlineVariant,
    };

    final label = status.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Nenhum agendamento para este dia.',
            style: GoogleFonts.manrope(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
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

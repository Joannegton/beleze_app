import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../shared/widgets/beleze_bottom_nav.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/entities/professional.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../domain/repositories/salon_repository.dart';

class OwnerSchedulePage extends StatefulWidget {
  const OwnerSchedulePage({super.key});

  @override
  State<OwnerSchedulePage> createState() => _OwnerSchedulePageState();
}

class _OwnerSchedulePageState extends State<OwnerSchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Appointment>? _appointments;
  List<Professional>? _professionals;
  Professional? _selectedProfessional;
  bool _loading = true;
  String? _tenantId;

  @override
  void initState() {
    super.initState();
    final session =
        (context.read<AuthBloc>().state as AuthAuthenticated?)?.session;
    _tenantId = session?.tenantId;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_tenantId == null) return;
    setState(() => _loading = true);

    final proResult =
        await context.read<SalonRepository>().getSalonProfessionals(_tenantId!);
    final aptResult = await context
        .read<AppointmentRepository>()
        .getDaySchedule(tenantId: _tenantId!, date: _selectedDay);

    if (!mounted) return;

    proResult.fold(
      (_) => setState(() => _loading = false),
      (professionals) {
        aptResult.fold(
          (_) => setState(() => _loading = false),
          (appointments) {
            setState(() {
              _professionals = professionals;
              if (professionals.isNotEmpty) {
                _selectedProfessional = professionals.first;
              }
              _appointments = appointments;
              _loading = false;
            });
          },
        );
      },
    );
  }

  Future<void> _loadSchedule(DateTime date) async {
    if (_tenantId == null) return;
    setState(() => _loading = true);
    final result = await context
        .read<AppointmentRepository>()
        .getDaySchedule(tenantId: _tenantId!, date: date);
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
          'Agenda',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primaryContainer),
            tooltip: 'Novo agendamento',
            onPressed: () {},
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
              lastDay: DateTime.now().add(const Duration(days: 90)),
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
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.outlineVariant),
          if (_professionals != null && _professionals!.isNotEmpty)
            Container(
              color: AppColors.surfaceContainer,
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _professionals!.length,
                itemBuilder: (_, i) {
                  final pro = _professionals![i];
                  final isSelected = _selectedProfessional?.id == pro.id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(pro.name),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedProfessional = pro);
                      },
                      backgroundColor: AppColors.surfaceContainer,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.black : AppColors.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),
          Divider(height: 1, color: AppColors.outlineVariant),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryContainer))
                : _appointments == null || _appointments!.isEmpty
                    ? const _EmptySchedule()
                    : RefreshIndicator(
                        onRefresh: () => _loadSchedule(_selectedDay),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Agenda de ${dateFormat.format(_selectedDay).capitalize()}',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            ..._appointments!.map(
                              (apt) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ScheduleCard(apt),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BelezeBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) {} // Already on schedule
          if (i == 1) context.go('/owner/services');
          if (i == 2) context.go('/owner/team');
          if (i == 3) context.go('/owner/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.local_dining), label: 'Serviços'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Equipe'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Appointment appointment;

  const _ScheduleCard(this.appointment);

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
                  'Prof. ${appointment.professionalName}',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  appointment.status.label,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
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

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

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
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

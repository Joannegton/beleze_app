import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/repositories/appointment_repository.dart';

class AppointmentDetailPage extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailPage({required this.appointmentId, super.key});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  Appointment? _appointment;
  bool _loading = true;
  String? _error;
  bool _updating = false;

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
    final result =
        await context.read<AppointmentRepository>().getAppointmentById(widget.appointmentId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (apt) => setState(() {
        _appointment = apt;
        _loading = false;
      }),
    );
  }

  Future<void> _updateStatus(AppointmentStatus newStatus) async {
    if (_appointment == null) return;
    setState(() => _updating = true);

    final result = await context.read<AppointmentRepository>().updateAppointmentStatus(
          appointmentId: _appointment!.id,
          status: newStatus,
        );

    if (!mounted) return;
    result.fold(
      (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message), backgroundColor: AppColors.error),
        );
        setState(() => _updating = false);
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status atualizado com sucesso'),
            backgroundColor: AppColors.success,
          ),
        );
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Detalhes do Agendamento',
          style: GoogleFonts.manrope(
            fontSize: 18,
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
                      ElevatedButton(onPressed: _load, child: const Text('Tentar novamente')),
                    ],
                  ),
                )
              : _appointment == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusCard(_appointment!),
                          const SizedBox(height: 24),
                          _buildServiceSection(_appointment!),
                          const SizedBox(height: 24),
                          _buildClientSection(_appointment!),
                          const SizedBox(height: 24),
                          _buildDateTimeSection(_appointment!),
                          const SizedBox(height: 24),
                          _buildPriceSection(_appointment!),
                          if (_appointment!.notes != null && _appointment!.notes!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildNotesSection(_appointment!),
                          ],
                          const SizedBox(height: 32),
                          if (_appointment!.status == AppointmentStatus.confirmed) ...[
                            _buildActionButtons(_appointment!),
                            const SizedBox(height: 80),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildStatusCard(Appointment apt) {
    final color = _getStatusColor(apt.status);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            apt.status.label.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection(Appointment apt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SERVIÇO',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                apt.serviceName,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ID do Serviço: ${apt.serviceId.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientSection(Appointment apt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLIENTE',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                  border: Border.all(color: AppColors.primaryContainer),
                ),
                child: Center(
                  child: Text(
                    'C',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cliente',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${apt.id.substring(0, 8).toUpperCase()}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(Appointment apt) {
    final dateFormat = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'pt_BR');
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATA E HORÁRIO',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.primaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateFormat.format(apt.startTime).capitalize(),
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: AppColors.primaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    '${timeFormat.format(apt.startTime)} - ${timeFormat.format(apt.endTime)}',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(Appointment apt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VALOR',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          padding: const EdgeInsets.all(12),
          child: Text(
            'R\$ ${apt.pricePaid.toStringAsFixed(2).replaceAll('.', ',')}',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(Appointment apt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OBSERVAÇÕES',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          padding: const EdgeInsets.all(12),
          child: Text(
            apt.notes ?? '',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Appointment apt) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _updating ? null : () => _updateStatus(AppointmentStatus.completed),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              'Marcar como Concluído',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _updating ? null : () => _updateStatus(AppointmentStatus.noShow),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.warning),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: Icon(Icons.cancel_outlined, color: AppColors.warning),
            label: Text(
              'Marcar como Não Compareceu',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
        ),
      ],
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

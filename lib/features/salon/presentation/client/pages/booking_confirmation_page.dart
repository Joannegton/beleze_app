import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../bloc/booking_bloc.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<BookingBloc>().state;
    if (state is! BookingSuccess) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.go('/client/home'));
      return const SizedBox.shrink();
    }

    final apt = state.appointment;
    final dateFormat = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final timeFormat = DateFormat('HH:mm');
    final confirmationCode = 'BLZ-${apt.id.toUpperCase().substring(0, 8)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, size: 44, color: AppColors.success),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Agendamento\nconfirmado!',
                        style: GoogleFonts.manrope(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Seu agendamento foi realizado com sucesso.',
                        style: GoogleFonts.manrope(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _TicketCard(
                        confirmationCode: confirmationCode,
                        serviceName: apt.serviceName,
                        professionalName: apt.professionalName,
                        date: dateFormat.format(apt.startTime),
                        time: timeFormat.format(apt.startTime),
                        price: 'R\$ ${apt.pricePaid.toStringAsFixed(2).replaceAll('.', ',')}',
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: const Text('Calendário'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                foregroundColor: AppColors.primaryContainer,
                                side: const BorderSide(color: AppColors.primaryContainer),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.location_on, size: 18),
                              label: const Text('Mapa'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                foregroundColor: AppColors.primaryContainer,
                                side: const BorderSide(color: AppColors.primaryContainer),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  AppButton(
                    label: 'Ver meus agendamentos',
                    onPressed: () {
                      context.read<BookingBloc>().add(const BookingReset());
                      context.go('/client/appointments');
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<BookingBloc>().add(const BookingReset());
                        context.go('/client/home');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Voltar ao início',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String confirmationCode;
  final String serviceName;
  final String professionalName;
  final String date;
  final String time;
  final String price;

  const _TicketCard({
    required this.confirmationCode,
    required this.serviceName,
    required this.professionalName,
    required this.date,
    required this.time,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Código de confirmação',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.05,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  confirmationCode,
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryContainer,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          _DashedDivider(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRowDark(
                  label: 'Serviço',
                  value: serviceName,
                  icon: Icons.spa_outlined,
                ),
                const SizedBox(height: 16),
                _DetailRowDark(
                  label: 'Profissional',
                  value: professionalName,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _DetailRowDark(
                  label: 'Data',
                  value: date,
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),
                _DetailRowDark(
                  label: 'Horário',
                  value: time,
                  icon: Icons.schedule_outlined,
                ),
                const SizedBox(height: 16),
                _DetailRowDark(
                  label: 'Valor',
                  value: price,
                  icon: Icons.attach_money_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashedLinePainter(
                color: AppColors.outlineVariant,
                strokeWidth: 1,
                dashWidth: 8,
                dashSpace: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetailRowDark extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRowDark({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryContainer),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.05,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

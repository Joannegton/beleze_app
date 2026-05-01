import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../bloc/booking_bloc.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appointmentId = GoRouterState.of(context).uri.queryParameters['appointmentId'];
      if (appointmentId != null) {
        context.read<BookingBloc>().add(BookingLoadForReschedule(appointmentId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingError) {
          AppSnackbar.showError(context, state.message);
        } else if (state is BookingSuccess) {
          context.go('/client/booking/confirmation');
        }
      },
      builder: (context, state) {
        if (state is BookingInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.canPop()) context.pop();
          });
          return const SizedBox.shrink();
        }

        if (state is! BookingInProgress) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: Icon(Icons.close, color: AppColors.onSurface),
              onPressed: () {
                context.read<BookingBloc>().add(const BookingReset());
                context.pop();
              },
            ),
            title: Text(
              'Agendar',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.service != null) ...[
                      _SectionTitle('Serviço selecionado'),
                      const SizedBox(height: 12),
                      _SelectedServiceCard(
                        name: state.service!.name,
                        price: state.service!.formattedPrice,
                        category: state.service!.category,
                      ),
                      const SizedBox(height: 32),
                    ],
                    _SectionTitle('Profissional'),
                    const SizedBox(height: 12),
                    if (state.availableProfessionals != null)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: state.availableProfessionals!.map((p) {
                            final isSelected = state.professional?.id == p.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () => context
                                    .read<BookingBloc>()
                                    .add(BookingProfessionalSelected(p)),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryContainer
                                              : AppColors.outlineVariant,
                                          width: isSelected ? 3 : 1,
                                        ),
                                        color: AppColors.surfaceContainerHigh,
                                      ),
                                      child: Center(
                                        child: Text(
                                          p.name[0].toUpperCase(),
                                          style: GoogleFonts.manrope(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? AppColors.primaryContainer
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 72,
                                      child: Text(
                                        p.name,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.primaryContainer
                                              : AppColors.onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      const SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primaryContainer),
                        ),
                      ),
                    const SizedBox(height: 32),
                    if (state.professional != null) ...[
                      _SectionTitle('Escolha a data'),
                      const SizedBox(height: 12),
                      _HorizontalDatePicker(
                        selectedDate: state.selectedDate,
                        onDateSelected: (date) =>
                            context.read<BookingBloc>().add(BookingDateSelected(date)),
                      ),
                      const SizedBox(height: 32),
                    ],
                    if (state.selectedDate != null) ...[
                      _SectionTitle('Horário disponível'),
                      const SizedBox(height: 12),
                      if (state.isLoadingSlots)
                        const SizedBox(
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primaryContainer),
                          ),
                        )
                      else if (state.availableSlots != null)
                        _TimeSlotGrid(
                          slots: state.availableSlots!,
                          selectedSlot: state.selectedSlot,
                          onSelected: (slot) => context
                              .read<BookingBloc>()
                              .add(BookingSlotSelected(slot)),
                        ),
                      const SizedBox(height: 120),
                    ],
                  ],
                ),
              ),
              if (state.canConfirm)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: AppButton(
                    label: state.rescheduleAppointmentId != null
                        ? 'Confirmar Reagendamento'
                        : 'Confirmar Agendamento',
                    isLoading: state.isConfirming,
                    onPressed: () {
                      if (state.rescheduleAppointmentId != null) {
                        context.read<BookingBloc>().add(
                          BookingRescheduleConfirmed(
                            appointmentId: state.rescheduleAppointmentId!,
                          ),
                        );
                      } else {
                        context.read<BookingBloc>().add(const BookingConfirmed());
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
    );
  }
}

class _SelectedServiceCard extends StatelessWidget {
  final String name;
  final String price;
  final String category;

  const _SelectedServiceCard({
    required this.name,
    required this.price,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;

  const _HorizontalDatePicker({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<_HorizontalDatePicker> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(
      60,
      (i) => DateTime.now().add(Duration(days: i)),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Row(
        children: dates.map((date) {
          final isSelected = widget.selectedDate != null &&
              date.year == widget.selectedDate!.year &&
              date.month == widget.selectedDate!.month &&
              date.day == widget.selectedDate!.day;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMonthAbbr(date.month),
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const abbrs = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return abbrs[month - 1];
  }
}

class _TimeSlotGrid extends StatelessWidget {
  final List slots;
  final dynamic selectedSlot;
  final void Function(dynamic) onSelected;

  const _TimeSlotGrid({
    required this.slots,
    required this.selectedSlot,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Nenhum horário disponível neste dia.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: slots.map((slot) {
        final isSelected = selectedSlot == slot;
        final isAvailable = slot.available as bool;

        return GestureDetector(
          onTap: isAvailable ? () => onSelected(slot) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryContainer
                  : isAvailable
                      ? AppColors.surfaceContainerHigh
                      : AppColors.surfaceContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              slot.formattedTime,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.onPrimary
                    : isAvailable
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/salon.dart';
import '../../../domain/entities/service.dart';
import '../../../domain/repositories/salon_repository.dart';
import '../bloc/booking_bloc.dart';

class SalonPage extends StatefulWidget {
  final String slug;

  const SalonPage({super.key, required this.slug});

  @override
  State<SalonPage> createState() => _SalonPageState();
}

class _SalonPageState extends State<SalonPage> {
  String? _selectedCategory;
  Salon? _salon;
  List<SalonService> _services = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSalon();
  }

  Future<void> _loadSalon() async {
    final repo = context.read<SalonRepository>();
    final salon = await repo.getSalonBySlug(widget.slug);
    if (!mounted) return;

    salon.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (s) async {
        _salon = s;
        final services = await repo.getSalonServices(s.id);
        if (!mounted) return;
        services.fold(
          (f) => setState(() {
            _error = f.message;
            _loading = false;
          }),
          (list) => setState(() {
            _services = list.where((srv) => srv.active).toList();
            _loading = false;
          }),
        );
      },
    );
  }

  List<String> get _categories =>
      _services.map((s) => s.category).toSet().toList()..sort();

  List<SalonService> get _filteredServices => _selectedCategory == null
      ? _services
      : _services.where((s) => s.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        onPressed: () => context.pop(),
                        child: const Text('Voltar'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 240,
                      floating: true,
                      pinned: true,
                      backgroundColor: AppColors.background,
                      leading: IconButton(
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
                          ),
                          child: Icon(Icons.arrow_back, color: AppColors.onSurface),
                        ),
                        onPressed: () => context.pop(),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: AppColors.surfaceContainer,
                              child: Icon(Icons.image, size: 80, color: AppColors.onSurfaceVariant),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.8)],
                                  ),
                                ),
                                height: 120,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_salon != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _salon!.name,
                                style: GoogleFonts.manrope(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: AppColors.primaryContainer),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _salon!.address.displayAddress,
                                      style: TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_categories.length > 1)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _categories.map((cat) {
                                      final isSelected = _selectedCategory == cat;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: GestureDetector(
                                          onTap: () => setState(() {
                                            _selectedCategory = isSelected ? null : cat;
                                          }),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryContainer
                                                    : AppColors.outlineVariant,
                                                width: isSelected ? 2 : 1,
                                              ),
                                              color: isSelected
                                                  ? AppColors.primaryContainer.withValues(alpha: 0.1)
                                                  : Colors.transparent,
                                            ),
                                            child: Text(
                                              cat,
                                              style: GoogleFonts.manrope(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? AppColors.primaryContainer
                                                    : AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Text(
                                'Serviços',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 0.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final service = _filteredServices[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ServiceCard(
                                service: service,
                                onTap: () {
                                  if (_salon == null) return;
                                  context.read<BookingBloc>().add(
                                        BookingServiceSelected(
                                          tenantId: _salon!.id,
                                          service: service,
                                        ),
                                      );
                                  context.push('/client/booking');
                                },
                              ),
                            );
                          },
                          childCount: _filteredServices.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final SalonService service;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  service.name,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  service.category,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryContainer,
                    letterSpacing: 0.05,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                service.formattedDuration,
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(width: 20),
              Text(
                service.formattedPrice,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              child: Text(
                'Agendar',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

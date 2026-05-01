import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/beleze_bottom_nav.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/entities/service.dart';
import '../../../domain/repositories/salon_repository.dart';

class OwnerServicesPage extends StatefulWidget {
  const OwnerServicesPage({super.key});

  @override
  State<OwnerServicesPage> createState() => _OwnerServicesPageState();
}

class _OwnerServicesPageState extends State<OwnerServicesPage> {
  List<SalonService>? _services;
  bool _loading = true;
  String? _tenantId;

  @override
  void initState() {
    super.initState();
    final session =
        (context.read<AuthBloc>().state as AuthAuthenticated?)?.session;
    _tenantId = session?.tenantId;
    _load();
  }

  Future<void> _load() async {
    if (_tenantId == null) return;
    setState(() => _loading = true);
    final result =
        await context.read<SalonRepository>().getSalonServices(_tenantId!);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (list) => setState(() {
        _services = list;
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
          'Serviços',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryContainer))
          : _services == null || _services!.isEmpty
              ? const _EmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: _services!.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ServiceCard(_services![i]),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceSheet,
        backgroundColor: AppColors.primaryContainer,
        child: Icon(Icons.add, color: AppColors.onPrimary),
      ),
      bottomNavigationBar: BelezeBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.go('/owner/dashboard');
          if (i == 2) context.go('/owner/team');
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

  void _showAddServiceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddServiceSheet(
        tenantId: _tenantId!,
        onSaved: _load,
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final SalonService service;

  const _ServiceCard(this.service);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: service.active
                  ? AppColors.primaryContainer.withValues(alpha: 0.15)
                  : AppColors.outlineVariant.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.spa_outlined,
              color: service.active ? AppColors.primaryContainer : AppColors.outlineVariant,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service.category,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      service.formattedDuration,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                service.formattedPrice,
                style: GoogleFonts.manrope(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: service.active
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  service.active ? 'Ativo' : 'Inativo',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: service.active ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddServiceSheet extends StatefulWidget {
  final String tenantId;
  final VoidCallback onSaved;

  const _AddServiceSheet({required this.tenantId, required this.onSaved});

  @override
  State<_AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<_AddServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Novo serviço',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Nome',
              hint: 'Ex: Corte de cabelo',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Categoria',
              hint: 'Ex: Cabelo',
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Preço (R\$)',
                    hint: '0,00',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Duração (min)',
                    hint: '30',
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Salvar Serviço',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);
    widget.onSaved();
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
          Icon(Icons.spa_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Nenhum serviço cadastrado.',
            style: GoogleFonts.manrope(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Toque no + para adicionar',
            style: GoogleFonts.manrope(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

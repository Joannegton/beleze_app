import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/beleze_bottom_nav.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/entities/professional.dart';
import '../../../domain/repositories/salon_repository.dart';

class OwnerTeamPage extends StatefulWidget {
  const OwnerTeamPage({super.key});

  @override
  State<OwnerTeamPage> createState() => _OwnerTeamPageState();
}

class _OwnerTeamPageState extends State<OwnerTeamPage> {
  List<Professional>? _professionals;
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
        await context.read<SalonRepository>().getSalonProfessionals(_tenantId!);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (list) => setState(() {
        _professionals = list;
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
          'Equipe',
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
          : _professionals == null || _professionals!.isEmpty
              ? const _EmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: _professionals!.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProfessionalCard(
                        _professionals![i],
                        onEdit: () => _showProfessionalForm(_professionals![i]),
                        onDelete: () => _confirmDelete(_professionals![i]),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProfessionalForm(null),
        backgroundColor: AppColors.primaryContainer,
        child: Icon(Icons.person_add, color: AppColors.onPrimary),
      ),
      bottomNavigationBar: BelezeBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.go('/owner/dashboard');
          if (i == 1) context.go('/owner/services');
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

  void _showProfessionalForm(Professional? professional) {
    showDialog(
      context: context,
      builder: (_) => _ProfessionalFormDialog(
        professional: professional,
        tenantId: _tenantId!,
        onSave: _load,
      ),
    );
  }

  void _confirmDelete(Professional professional) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'Deletar Profissional',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Tem certeza que deseja deletar ${professional.name}?',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<SalonRepository>()
                  .deleteProfessional(_tenantId!, professional.id);
              if (mounted) {
                _load();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${professional.name} deletado com sucesso'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(
              'Deletar',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final Professional professional;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProfessionalCard(
    this.professional, {
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: professional.active
                    ? AppColors.primaryContainer.withValues(alpha: 0.15)
                    : AppColors.outlineVariant.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  professional.name[0].toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: professional.active
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.name,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${professional.serviceIds.length} serviço${professional.serviceIds.length != 1 ? 's' : ''}',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: AppColors.primaryContainer),
                      SizedBox(width: 12),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Deletar'),
                    ],
                  ),
                ),
              ],
            ),
            Switch(
              value: professional.active,
              activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.3),
              activeThumbColor: AppColors.primaryContainer,
              inactiveTrackColor: AppColors.outlineVariant.withValues(alpha: 0.2),
              inactiveThumbColor: AppColors.outlineVariant,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
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
          Icon(Icons.group_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Nenhum profissional cadastrado.',
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

class _ProfessionalFormDialog extends StatefulWidget {
  final Professional? professional;
  final String tenantId;
  final VoidCallback onSave;

  const _ProfessionalFormDialog({
    required this.professional,
    required this.tenantId,
    required this.onSave,
  });

  @override
  State<_ProfessionalFormDialog> createState() =>
      _ProfessionalFormDialogState();
}

class _ProfessionalFormDialogState extends State<_ProfessionalFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _specialtiesController;
  late TextEditingController _commissionController;
  bool _isActive = true;
  bool _saving = false;
  final Map<String, String> _workHours = {
    'seg': '09:00-18:00',
    'ter': '09:00-18:00',
    'qua': '09:00-18:00',
    'qui': '09:00-18:00',
    'sex': '09:00-18:00',
    'sab': '09:00-14:00',
    'dom': 'Fechado',
  };

  @override
  void initState() {
    super.initState();
    final pro = widget.professional;
    _nameController = TextEditingController(text: pro?.name ?? '');
    _specialtiesController = TextEditingController(text: pro?.specialties ?? '');
    _commissionController = TextEditingController(text: pro?.commission.toString() ?? '20');
    _isActive = pro?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtiesController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome do profissional é obrigatório'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      if (widget.professional == null) {
        await context.read<SalonRepository>().createProfessional(
          widget.tenantId,
          name: _nameController.text,
          specialties: _specialtiesController.text,
          commission: double.tryParse(_commissionController.text) ?? 20,
          active: _isActive,
          workHours: _workHours,
        );
      } else {
        await context.read<SalonRepository>().updateProfessional(
          widget.tenantId,
          widget.professional!.id,
          name: _nameController.text,
          specialties: _specialtiesController.text,
          commission: double.tryParse(_commissionController.text) ?? 20,
          active: _isActive,
          workHours: _workHours,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.professional == null
                  ? 'Profissional adicionado com sucesso'
                  : 'Profissional atualizado com sucesso',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.professional == null
                  ? 'Adicionar Profissional'
                  : 'Editar Profissional',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Nome', _nameController, 'Maria Silva'),
            const SizedBox(height: 16),
            _buildTextField('Especialidades', _specialtiesController,
                'Cabelo, Coloração, Escova'),
            const SizedBox(height: 16),
            _buildTextField('Comissão (%)', _commissionController, '20'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ativo',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Switch(
                  value: _isActive,
                  activeThumbColor: AppColors.primaryContainer,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Horário de Trabalho',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              ('seg', 'Segunda'),
              ('ter', 'Terça'),
              ('qua', 'Quarta'),
              ('qui', 'Quinta'),
              ('sex', 'Sexta'),
              ('sab', 'Sábado'),
              ('dom', 'Domingo'),
            ].map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.$2,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      _workHours[e.$1] ?? '',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : Text(
                          'Salvar',
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.manrope(fontSize: 14, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryContainer, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

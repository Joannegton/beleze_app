import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/entities/professional.dart';

class ProfessionalProfilePage extends StatefulWidget {
  const ProfessionalProfilePage({super.key});

  @override
  State<ProfessionalProfilePage> createState() => _ProfessionalProfilePageState();
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage> {
  Professional? _professional;
  bool _loading = true;

  late TextEditingController _nameController;
  late TextEditingController _specializationsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _specializationsController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    // For now, we'll create a mock professional from the auth session
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final professional = Professional(
        id: authState.session.userId,
        tenantId: authState.session.tenantId ?? '',
        name: authState.session.email.split('@').first,
        serviceIds: [],
        active: true,
      );

      _nameController.text = professional.name;
      _specializationsController.text = 'Especialista em cabelo e estética';

      setState(() {
        _professional = professional;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Você não está autenticado',
                style: GoogleFonts.manrope(color: AppColors.onSurface),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Meu Perfil',
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
                tooltip: 'Sair',
                onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
              ),
            ],
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryContainer))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppColors.primaryContainer, width: 2),
                                color: AppColors.surfaceContainerHigh,
                              ),
                              child: _professional?.avatarUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _professional!.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            _professional!.name[0].toUpperCase(),
                                            style: GoogleFonts.manrope(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryContainer,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        _professional!.name[0].toUpperCase(),
                                        style: GoogleFonts.manrope(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryContainer,
                                        ),
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryContainer,
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 20, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle('Informações Pessoais'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nome profissional',
                        hint: 'Seu nome completo',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _specializationsController,
                        label: 'Especialidades',
                        hint: 'Ex: Cabelo, Barba, Estética',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      _SectionTitle('Horário de Trabalho'),
                      const SizedBox(height: 12),
                      _buildWorkHourTile('Segunda', '09:00', '18:00'),
                      const SizedBox(height: 12),
                      _buildWorkHourTile('Terça', '09:00', '18:00'),
                      const SizedBox(height: 12),
                      _buildWorkHourTile('Quarta', '09:00', '18:00'),
                      const SizedBox(height: 12),
                      _buildWorkHourTile('Quinta', '09:00', '18:00'),
                      const SizedBox(height: 12),
                      _buildWorkHourTile('Sexta', '09:00', '18:00'),
                      const SizedBox(height: 12),
                      _buildWorkHourTile('Sábado', '09:00', '14:00'),
                      const SizedBox(height: 12),
                      _buildWorkHourTile('Domingo', 'Fechado', 'Fechado', disabled: true),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.save),
                          label: Text(
                            'Salvar Alterações',
                            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
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
          maxLines: maxLines,
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onSurface,
          ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkHourTile(String day, String start, String end, {bool disabled = false}) {
    return Container(
      decoration: BoxDecoration(
        color: disabled ? AppColors.outlineVariant.withValues(alpha: 0.1) : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: disabled ? AppColors.onSurfaceVariant : AppColors.onSurface,
            ),
          ),
          Text(
            '$start - $end',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: disabled ? AppColors.onSurfaceVariant : AppColors.primaryContainer,
            ),
          ),
        ],
      ),
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
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryContainer,
        letterSpacing: 0.3,
      ),
    );
  }
}

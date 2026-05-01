import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/auth/domain/entities/user_session.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../shared/widgets/beleze_bottom_nav.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _emailController = TextEditingController(text: authState.session.email);
    } else {
      _emailController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

        final session = state.session;

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
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryContainer, width: 2),
                        color: AppColors.surfaceContainerHigh,
                      ),
                      child: Center(
                        child: Text(
                          session.email[0].toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Informações Pessoais'),
                  const SizedBox(height: 12),
                  _ProfileField(
                    label: 'Email',
                    value: session.email,
                    isEditable: false,
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    label: 'Tipo de Conta',
                    value: session.role.label,
                    isEditable: false,
                  ),
                  const SizedBox(height: 32),
                  _SectionTitle('Preferências'),
                  const SizedBox(height: 12),
                  _SwitchTile(
                    title: 'Notificações via Push',
                    subtitle: 'Receba notificações sobre agendamentos',
                    value: true,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 12),
                  _SwitchTile(
                    title: 'Notificações via SMS',
                    subtitle: 'Lembretes de agendamentos por SMS',
                    value: false,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 32),
                  _SectionTitle('Segurança e Privacidade'),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.lock_outline,
                    title: 'Alterar Senha',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Política de Privacidade',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.description_outlined,
                    title: 'Termos de Serviço',
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),
                  _SectionTitle('Dados Pessoais (LGPD)'),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.download_outlined,
                    title: 'Baixar meus dados',
                    onTap: () => _showMessage('Seus dados serão enviados em breve.'),
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.delete_outline,
                    title: 'Excluir minha conta',
                    subtitle: 'Esta ação é irreversível',
                    textColor: AppColors.error,
                    onTap: () => _showDeleteDialog(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthLogoutRequested());
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Sair da Conta',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BelezeBottomNav(
            currentIndex: 3,
            onTap: (i) {
              if (i == 0) context.go('/client/home');
              if (i == 1) context.go('/client/appointments');
              if (i == 2) context.go('/client/favorites');
              if (i == 3) {} // Already on profile
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Agendamentos'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'Excluir conta?',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Todos os seus dados, agendamentos e histórico serão permanentemente deletados. Esta ação é irreversível.',
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
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Sua solicitação de exclusão foi enviada.');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              'Deletar',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
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

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditable;

  const _ProfileField({
    required this.label,
    required this.value,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryContainer,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor ?? AppColors.primaryContainer),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? AppColors.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

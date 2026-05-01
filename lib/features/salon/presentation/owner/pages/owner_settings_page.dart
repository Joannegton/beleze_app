import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/beleze_bottom_nav.dart';

class OwnerSettingsPage extends StatefulWidget {
  const OwnerSettingsPage({super.key});

  @override
  State<OwnerSettingsPage> createState() => _OwnerSettingsPageState();
}

class _OwnerSettingsPageState extends State<OwnerSettingsPage> {
  late TextEditingController _slugController;
  late TextEditingController _timezonController;
  late TextEditingController _cancelPolicyController;
  bool _saving = false;
  String _selectedTimezone = 'America/Sao_Paulo';

  @override
  void initState() {
    super.initState();
    _slugController = TextEditingController(text: 'meu-salao');
    _timezonController = TextEditingController(text: 'America/Sao_Paulo');
    _cancelPolicyController = TextEditingController(
      text: 'Cancele até 2 horas antes do agendamento',
    );
  }

  @override
  void dispose() {
    _slugController.dispose();
    _timezonController.dispose();
    _cancelPolicyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Configurações do Salão',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Informações Públicas'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _slugController,
              label: 'Slug (URL)',
              hint: 'seu-salao',
              helper: 'beleze.app/seu-salao',
            ),
            const SizedBox(height: 24),
            _SectionTitle('Horário de Funcionamento'),
            const SizedBox(height: 12),
            _buildWorkHourTile('Segunda', '09:00', '18:00'),
            const SizedBox(height: 8),
            _buildWorkHourTile('Terça', '09:00', '18:00'),
            const SizedBox(height: 8),
            _buildWorkHourTile('Quarta', '09:00', '18:00'),
            const SizedBox(height: 8),
            _buildWorkHourTile('Quinta', '09:00', '18:00'),
            const SizedBox(height: 8),
            _buildWorkHourTile('Sexta', '09:00', '18:00'),
            const SizedBox(height: 8),
            _buildWorkHourTile('Sábado', '09:00', '14:00'),
            const SizedBox(height: 8),
            _buildWorkHourTile('Domingo', 'Fechado', 'Fechado', disabled: true),
            const SizedBox(height: 24),
            _SectionTitle('Configurações Regionais'),
            const SizedBox(height: 12),
            _buildDropdownField(
              label: 'Timezone',
              value: _selectedTimezone,
              items: [
                'America/Sao_Paulo',
                'America/Recife',
                'America/Manaus',
                'America/Cuiaba',
              ],
              onChanged: (value) => setState(() => _selectedTimezone = value!),
            ),
            const SizedBox(height: 24),
            _SectionTitle('Política de Cancelamento'),
            const SizedBox(height: 12),
            _buildTextAreaField(
              controller: _cancelPolicyController,
              label: 'Política',
              hint: 'Descreva sua política de cancelamento',
            ),
            const SizedBox(height: 24),
            _SectionTitle('Intervalo Mínimo Entre Agendamentos'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Intervalo (minutos)',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      '15',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('Notificações'),
            const SizedBox(height: 12),
            _buildNotificationSwitch(
              'Notificar no novo agendamento',
              'Receba notificação quando um cliente agendar',
              true,
            ),
            const SizedBox(height: 12),
            _buildNotificationSwitch(
              'Notificar em cancelamento',
              'Receba notificação quando um cliente cancelar',
              true,
            ),
            const SizedBox(height: 12),
            _buildNotificationSwitch(
              'Lembrete de agendamento',
              'Enviar lembrete para cliente 1h antes',
              true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveSettings,
                icon: const Icon(Icons.save),
                label: Text(
                  'Salvar Configurações',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BelezeBottomNav(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) context.go('/owner/dashboard');
          if (i == 1) context.go('/owner/services');
          if (i == 2) context.go('/owner/team');
          if (i == 3) {} // Already on settings
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.local_dining), label: 'Serviços'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Equipe'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() => _saving = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? helper,
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
            helperText: helper,
            helperStyle: GoogleFonts.manrope(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
          maxLines: 4,
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ))
                .toList(),
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

  Widget _buildNotificationSwitch(String title, String subtitle, bool value) {
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) {},
            activeThumbColor: AppColors.primaryContainer,
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

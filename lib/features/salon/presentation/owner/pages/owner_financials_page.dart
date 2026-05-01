import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/beleze_bottom_nav.dart';

class OwnerFinancialsPage extends StatefulWidget {
  const OwnerFinancialsPage({super.key});

  @override
  State<OwnerFinancialsPage> createState() => _OwnerFinancialsPageState();
}

class _OwnerFinancialsPageState extends State<OwnerFinancialsPage> {
  String _selectedPeriod = 'monthly';
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Financeiro',
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
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildKPICards(),
            const SizedBox(height: 32),
            _SectionTitle('Receita por Profissional'),
            const SizedBox(height: 12),
            _buildProfessionalRevenueTable(),
            const SizedBox(height: 32),
            _SectionTitle('Receita por Serviço'),
            const SizedBox(height: 12),
            _buildServiceRevenueTable(),
            const SizedBox(height: 32),
            _SectionTitle('Comissões'),
            const SizedBox(height: 12),
            _buildCommissionTable(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showExportDialog(),
                icon: const Icon(Icons.download),
                label: Text(
                  'Exportar Relatório',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BelezeBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.go('/owner/schedule');
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

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton('Semanal', 'weekly'),
          ),
          Expanded(
            child: _buildPeriodButton('Mensal', 'monthly'),
          ),
          Expanded(
            child: _buildPeriodButton('Anual', 'yearly'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedPeriod = value),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKPICards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard('Receita Total', 'R\$ 12.540,00', AppColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard('Nº de Serviços', '128', AppColors.primaryContainer),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard('Ticket Médio', 'R\$ 97,97', AppColors.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard('Taxa Cancelamento', '2,3%', AppColors.error),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, Color accentColor) {
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
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalRevenueTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profissional',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
                Text(
                  'Receita',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
          _buildTableRow('Maria Silva', 'R\$ 3.240,00'),
          _buildTableRow('João Santos', 'R\$ 2.890,00'),
          _buildTableRow('Ana Costa', 'R\$ 2.650,00'),
          _buildTableRow('Pedro Oliveira', 'R\$ 2.120,00'),
        ],
      ),
    );
  }

  Widget _buildServiceRevenueTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Serviço',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
                Text(
                  'Receita',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
          _buildTableRow('Corte Cabelo', 'R\$ 5.120,00'),
          _buildTableRow('Coloração', 'R\$ 3.890,00'),
          _buildTableRow('Manicure', 'R\$ 2.340,00'),
          _buildTableRow('Pedicure', 'R\$ 1.190,00'),
        ],
      ),
    );
  }

  Widget _buildCommissionTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profissional',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
                Text(
                  'Comissão',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
          _buildTableRow('Maria Silva', 'R\$ 648,00 (20%)'),
          _buildTableRow('João Santos', 'R\$ 578,00 (20%)'),
          _buildTableRow('Ana Costa', 'R\$ 530,00 (20%)'),
          _buildTableRow('Pedro Oliveira', 'R\$ 424,00 (20%)'),
        ],
      ),
    );
  }

  Widget _buildTableRow(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'Exportar Relatório',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Escolha o formato para exportar:',
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Relatório exportado em CSV'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'CSV',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Relatório exportado em PDF'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'PDF',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryContainer,
              ),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentStep = 0;
  late TextEditingController _salonNameController;
  late TextEditingController _slugController;
  late TextEditingController _addressController;
  late TextEditingController _serviceNameController;
  late TextEditingController _servicePriceController;
  late TextEditingController _professionalNameController;
  late TextEditingController _professionalSpecController;

  final List<String> _services = [];
  final List<String> _professionals = [];

  @override
  void initState() {
    super.initState();
    _salonNameController = TextEditingController();
    _slugController = TextEditingController();
    _addressController = TextEditingController();
    _serviceNameController = TextEditingController();
    _servicePriceController = TextEditingController();
    _professionalNameController = TextEditingController();
    _professionalSpecController = TextEditingController();
  }

  @override
  void dispose() {
    _salonNameController.dispose();
    _slugController.dispose();
    _addressController.dispose();
    _serviceNameController.dispose();
    _servicePriceController.dispose();
    _professionalNameController.dispose();
    _professionalSpecController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Bem-vindo ao Beleze',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surfaceContainer,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= _currentStep
                              ? AppColors.primaryContainer
                              : AppColors.surfaceContainerHigh,
                          border: Border.all(
                            color: i <= _currentStep
                                ? AppColors.primaryContainer
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: i <= _currentStep
                                  ? Colors.black
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ['Salão', 'Serviços', 'Equipe'][i],
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentStep == 0) _buildStep1(),
                  if (_currentStep == 1) _buildStep2(),
                  if (_currentStep == 2) _buildStep3(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.surfaceContainer,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: Text(
                    'Voltar',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    context.go('/owner/dashboard');
                  }
                },
                child: Text(
                  _currentStep < 2 ? 'Próximo' : 'Concluir',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações do Salão',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure os dados básicos do seu salão',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _salonNameController,
          label: 'Nome do Salão',
          hint: 'Meu Salão de Beleza',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _slugController,
          label: 'Slug (URL)',
          hint: 'meu-salao',
          helper: 'beleze.app/meu-salao',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Endereço',
          hint: 'Rua das Flores, 123 - São Paulo, SP',
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryContainer),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.image_outlined, color: AppColors.primaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logo e Fotos',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Você poderá adicionar fotos depois',
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

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicione Serviços',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cadastre pelo menos um serviço',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _serviceNameController,
          label: 'Nome do Serviço',
          hint: 'Corte de Cabelo',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _servicePriceController,
          label: 'Preço (R\$)',
          hint: '50.00',
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_serviceNameController.text.isNotEmpty &&
                  _servicePriceController.text.isNotEmpty) {
                setState(() {
                  _services.add(
                    '${_serviceNameController.text} - R\$ ${_servicePriceController.text}',
                  );
                  _serviceNameController.clear();
                  _servicePriceController.clear();
                });
              }
            },
            icon: const Icon(Icons.add),
            label: Text(
              'Adicionar Serviço',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_services.isNotEmpty) ...[
          Text(
            'Serviços Adicionados',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          ..._services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicione sua Equipe',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cadastre profissionais (opcional)',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _professionalNameController,
          label: 'Nome do Profissional',
          hint: 'Maria Silva',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _professionalSpecController,
          label: 'Especialidades',
          hint: 'Cabelo, Coloração, Escova',
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_professionalNameController.text.isNotEmpty) {
                setState(() {
                  _professionals.add(_professionalNameController.text);
                  _professionalNameController.clear();
                  _professionalSpecController.clear();
                });
              }
            },
            icon: const Icon(Icons.add),
            label: Text(
              'Adicionar Profissional',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_professionals.isNotEmpty) ...[
          Text(
            'Profissionais Adicionados',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          ..._professionals.map(
            (prof) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prof,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
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
}

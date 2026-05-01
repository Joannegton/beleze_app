import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _scanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Ler QR Code',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: _buildScannerPlaceholder(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryContainer,
        onPressed: _scanning ? null : _startScanning,
        child: Icon(
          _scanning ? Icons.stop : Icons.qr_code_2,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }

  Widget _buildScannerPlaceholder() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryContainer, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.qr_code_2,
                  size: 80,
                  color: AppColors.primaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Leia um QR Code',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aponte a câmera para um QR code de salão Beleze',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            _buildIntegrationGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para usar QR Scanner:',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '1. Adicione qr_flutter e mobile_scanner\n'
            '2. Implemente o scanner\n'
            '3. Extraia slug do QR code\n'
            '4. Navegue para /client/salon/:slug',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _startScanning() {
    // When mobile_scanner is integrated:
    // 1. Open mobile_scanner
    // 2. Detect QR code
    // 3. Extract salon slug (URL format: beleze.app/meu-salao)
    // 4. Navigate to /client/salon/meu-salao

    setState(() => _scanning = true);

    // Example QR code processing:
    // if (qrCode.startsWith('beleze.app/')) {
    //   final slug = qrCode.replaceFirst('beleze.app/', '');
    //   context.go('/client/salon/$slug');
    // } else if (qrCode.startsWith('http')) {
    //   final uri = Uri.parse(qrCode);
    //   final slug = uri.pathSegments.last;
    //   context.go('/client/salon/$slug');
    // }

    // Mock navigation for demo
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go('/client/salon/meu-salao-de-exemplo');
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'scan_qrcode_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Text('PRESENÇA', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
            Text('+', style: AppTextStyles.titleMedium.copyWith(color: AppColors.accent, fontSize: 24)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${authProvider.userName ?? "Aluno"}!',
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bem-vindo ao sistema de registro de presença.',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('Ações Disponíveis', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanQrcodeScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04), // <-- Corrigido aqui
                        blurRadius: 10, 
                        offset: const Offset(0, 4)
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1), // <-- Corrigido aqui
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Registrar presença', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            const SizedBox(height: 4),
                            Text('Escanear QR Code e validar geolocalização', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
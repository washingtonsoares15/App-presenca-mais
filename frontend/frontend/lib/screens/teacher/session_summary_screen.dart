import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.verified,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chamada Finalizada e Validada!',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Os registros de presença foram salvos com sucesso.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Resumo dos Dados
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Disciplina', 'Engenharia de Software'),
                    const Divider(height: 24),
                    _buildSummaryRow('Data', '17/09/2026'),
                    const Divider(height: 24),
                    _buildSummaryRow('Total de Presentes', '3 alunos',
                        highlight: true),
                    const Divider(height: 24),
                    _buildSummaryRow('Status', 'Frequência Salva',
                        color: AppColors.success),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/teacher-home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Voltar para a Área do Professor',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? color, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

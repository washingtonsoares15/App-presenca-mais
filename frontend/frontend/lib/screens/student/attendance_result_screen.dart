import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AttendanceResultScreen extends StatelessWidget {
  final bool isSuccess;

  const AttendanceResultScreen({
    super.key,
    this.isSuccess = true,
  });

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
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSuccess
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  size: 80,
                  color: isSuccess ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess
                    ? 'Presença registrada com sucesso!'
                    : 'Não foi possível registrar a presença.',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isSuccess
                    ? 'Sua identidade e localização foram validadas com sucesso.'
                    : 'Você está fora do raio da sala de aula ou a chamada foi encerrada.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Card com Detalhes da Aula
              if (isSuccess)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Disciplina', 'Engenharia de Software'),
                      const Divider(height: 20),
                      _buildDetailRow('Data', '17/09/2026'),
                      const Divider(height: 20),
                      _buildDetailRow('Horário', '10:30'),
                      const Divider(height: 20),
                      _buildDetailRow('Status', 'Confirmada',
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
                      Navigator.pushReplacementNamed(context, '/student-home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Voltar para o Início',
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

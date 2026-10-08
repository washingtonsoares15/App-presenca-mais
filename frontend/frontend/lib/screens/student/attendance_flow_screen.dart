import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AttendanceFlowScreen extends StatefulWidget {
  const AttendanceFlowScreen({super.key});

  @override
  State<AttendanceFlowScreen> createState() => _AttendanceFlowScreenState();
}

class _AttendanceFlowScreenState extends State<AttendanceFlowScreen> {
  int _currentStep = 0;
  bool _isProcessing = false;

  void _processValidation() async {
    setState(() {
      _isProcessing = true;
    });

    // Simula Etapa 1: Captura e Validação Facial
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _currentStep = 1;
    });

    // Simula Etapa 2: Verificação da Geolocalização
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _currentStep = 2;
    });

    // Redireciona para o Resultado
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/attendance-result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Registro de Presença'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Validação em Andamento',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Aguarde a validação do reconhecimento facial e geolocalização.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Indicador de Etapas
              _buildStepItem(
                index: 0,
                title: '1. Captura & Reconhecimento Facial',
                subtitle: 'Validando identidade do aluno...',
              ),
              const SizedBox(height: 24),
              _buildStepItem(
                index: 1,
                title: '2. Verificação de Geolocalização',
                subtitle: 'Confirmando presença no local autorizado...',
              ),
              const SizedBox(height: 24),
              _buildStepItem(
                index: 2,
                title: '3. Confirmação do Registro',
                subtitle: 'Processando presença no sistema...',
              ),

              const Spacer(),

              if (!_isProcessing)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _processValidation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Iniciar Validação',
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

  Widget _buildStepItem({
    required int index,
    required String title,
    required String subtitle,
  }) {
    bool isDone = _currentStep > index;
    bool isCurrent = _currentStep == index && _isProcessing;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.success
                : isCurrent
                    ? AppColors.primary
                    : Colors.grey.shade300,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : isCurrent
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCurrent || isDone
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

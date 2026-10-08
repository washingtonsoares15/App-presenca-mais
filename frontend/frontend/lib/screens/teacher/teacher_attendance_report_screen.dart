import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class TeacherAttendanceReportScreen extends StatelessWidget {
  const TeacherAttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Relatórios de Frequência'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.engineering_rounded,
                  size: 64,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Módulo em Desenvolvimento',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'O módulo de relatórios de frequência detalhados está atualmente em desenvolvimento e estará disponível em breve com novas funcionalidades para acompanhar a presença dos alunos.',
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar ao Painel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
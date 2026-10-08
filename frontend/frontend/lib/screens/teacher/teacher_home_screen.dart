import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'generate_qrcode_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

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
            Text('PRESENÇA',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.primary)),
            Text('+ (Professor)',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.accent, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cartão de Saudação do Professor
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
                      'Olá, Prof. ${authProvider.userName ?? "Docente"}!',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gerencie suas aulas e acompanhe as presenças em tempo real.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Painel de Controlo',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 16),

              // Ação Principal: Gerar QR Code para Chamada
              _buildTeacherActionCard(
                context: context,
                icon: Icons.qr_code_2,
                title: 'Gerar QR Code de Presença',
                subtitle: 'Abra o código dinâmico para os alunos escanearem',
                color: Colors.green,
                onTap: () {
                  // 2. Navegação para o ecrã de QR Code
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GenerateQrcodeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Opção: Minhas Turmas
              _buildTeacherActionCard(
                context: context,
                icon: Icons.class_,
                title: 'Minhas Turmas',
                subtitle: 'Consulte disciplinas e lista de alunos matriculados',
                color: AppColors.primary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gestão de turmas em breve.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Opção: Relatórios de Frequência
              _buildTeacherActionCard(
                context: context,
                icon: Icons.analytics_outlined,
                title: 'Relatórios de Frequência',
                subtitle: 'Visualize quem esteve presente nas aulas',
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Relatórios detalhados em breve.'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
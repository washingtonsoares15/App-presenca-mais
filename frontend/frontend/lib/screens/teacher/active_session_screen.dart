import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  final List<Map<String, String>> _presentStudents = [
    {
      'name': 'João Silva',
      'time': '10:31',
      'status': 'Reconhecimento Facial + GPS OK'
    },
    {
      'name': 'Maria Oliveira',
      'time': '10:33',
      'status': 'Reconhecimento Facial + GPS OK'
    },
    {
      'name': 'Carlos Eduardo',
      'time': '10:35',
      'status': 'Reconhecimento Facial + GPS OK'
    },
  ];

  void _addSimulatedStudent() {
    setState(() {
      _presentStudents.add({
        'name': 'Aluno Exemplo ${_presentStudents.length + 1}',
        'time': '10:37',
        'status': 'Reconhecimento Facial + GPS OK',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chamada Ativa'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Painel de Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sensors,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SESSÃO ABERTA',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Engenharia de Software',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Raio de validação: 50m (Sala 102)',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Contador de Presentes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alunos Registrados (${_presentStudents.length})',
                    style: AppTextStyles.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: _addSimulatedStudent,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Simular Entrada'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Lista de Alunos Registrados
              Expanded(
                child: ListView.separated(
                  itemCount: _presentStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final student = _presentStudents[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.2),
                            child: const Icon(Icons.person,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student['name']!,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  student['status']!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.success,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            student['time']!,
                            style:
                                AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Botão para Encerrar e Validar Frequência
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/teacher-session-summary',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Encerrar e Validar Chamada',
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
}

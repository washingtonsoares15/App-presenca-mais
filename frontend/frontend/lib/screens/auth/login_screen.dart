import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/custom_feedback.dart';
import '../teacher/teacher_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart'; // <-- Importação do painel do aluno adicionada

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'aluno';

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    if (!value.contains('@')) {
      return 'Insira um email válido';
    }
    if (value.contains(RegExp(r"[';]"))) {
      return 'Caracteres inválidos detectados';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  Future<void> _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        if (_selectedRole == 'professor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TeacherDashboardScreen()),
          );
        } else {
          // Redireciona para o painel do aluno que criamos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentDashboardScreen(studentId: 1)),
          );
        }
      } else if (mounted) {
        CustomFeedback.showError(
          context, 
          'Credenciais inválidas ou erro no servidor'
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PresençaMais',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Faça login para registrar presença',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Aluno')),
                          selected: _selectedRole == 'aluno',
                          onSelected: (selected) {
                            setState(() {
                              _selectedRole = 'aluno';
                            });
                          },
                          selectedColor: Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: _selectedRole == 'aluno' ? Colors.blue.shade900 : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Professor')),
                          selected: _selectedRole == 'professor',
                          onSelected: (selected) {
                            setState(() {
                              _selectedRole = 'professor';
                            });
                          },
                          selectedColor: Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: _selectedRole == 'professor' ? Colors.blue.shade900 : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Universitário',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    isPassword: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 32),
                  authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Entrar como ${_selectedRole == 'professor' ? 'Professor' : 'Aluno'}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Não tem uma conta? Registre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
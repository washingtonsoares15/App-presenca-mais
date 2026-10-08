import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variável para controlar o perfil escolhido ('aluno' ou 'professor')
  String _selectedRole = 'aluno';

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email é obrigatório';
    if (!value.contains('@')) return 'Insira um email válido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Senha é obrigatória';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  Future<void> _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Envia os dados para a API com o papel selecionado dinamicamente
      bool success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registo concluído! Faça login agora.'),
            backgroundColor: Colors.green,
          ),
        );
        // Volta para o ecrã de login de forma segura
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao registar. Email já existe ou falha no servidor.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
                    Icons.person_add,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),

                  // SELETOR DE PERFIL (ALUNO OU PROFESSOR)
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
                    controller: _nameController,
                    label: 'Nome Completo',
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
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
                          onPressed: _submitRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Registar como ${_selectedRole == 'professor' ? 'Professor' : 'Aluno'}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 16),
                  
                  // BOTÃO ADICIONADO: Para voltar ao login caso já tenha conta
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Já tem uma conta? Faça login'),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
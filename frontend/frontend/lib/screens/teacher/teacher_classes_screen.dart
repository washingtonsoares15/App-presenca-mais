import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'class_details_screen.dart'; // Importação do ecrã de detalhes da turma

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  // Ajuste o IP se estiver a testar num telemóvel físico (ex: 'http://192.168.1.X:3000/api')
  final String _baseUrl = 'http://localhost:3000/api';
  
  List<dynamic> _turmas = [];
  bool _isLoading = true;

  final _materiaController = TextEditingController();
  final _turmaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTurmas();
  }

  // Buscar turmas no backend Node.js
  Future<void> _fetchTurmas() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/classes'));
      
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _turmas = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar turmas: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Criar nova turma enviando para o backend
  Future<void> _criarTurmaNoBackend() async {
    if (_materiaController.text.trim().isEmpty || _turmaController.text.trim().isEmpty) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/classes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'materia': _materiaController.text.trim(),
          'turma': _turmaController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        _materiaController.clear();
        _turmaController.clear();
        Navigator.pop(context);

        _fetchTurmas(); // Atualiza a lista

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turma criada e salva com sucesso!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar turma no servidor.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarDialogCriarTurma() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Criar Nova Turma', style: TextStyle(color: Colors.blue)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _materiaController,
                decoration: InputDecoration(
                  labelText: 'Disciplina (Ex: Base de Dados)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _turmaController,
                decoration: InputDecoration(
                  labelText: 'Turma (Ex: Turma A - Noite)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _materiaController.clear();
                _turmaController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _criarTurmaNoBackend,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Criar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _materiaController.dispose();
    _turmaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Minhas Turmas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _turmas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.class_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma turma criada.',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Clique no botão abaixo para criar a sua primeira turma.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _turmas.length,
                    itemBuilder: (context, index) {
                      final turma = _turmas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Ao tocar na turma, abre os detalhes com os alunos matriculados
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassDetailsScreen(turma: turma),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.book, color: Colors.blue),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        turma['materia'] ?? '',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        turma['turma'] ?? '',
                                        style: const TextStyle(color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogCriarTurma,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Criar Turma'),
      ),
    );
  }
}
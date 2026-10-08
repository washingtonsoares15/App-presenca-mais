import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClassDetailsScreen extends StatefulWidget {
  final dynamic turma;

  const ClassDetailsScreen({super.key, required this.turma});

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  final String _baseUrl = 'http://localhost:3000/api';
  List<dynamic> _alunosMatriculados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAlunosMatriculados();
  }

  Future<void> _carregarAlunosMatriculados() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/classes/${widget.turma['id']}/students'));
      
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _alunosMatriculados = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar alunos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.turma['materia'] ?? 'Detalhes da Turma'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações da Turma
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.turma['materia'] ?? '',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Identificação: ${widget.turma['turma']}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Alunos Matriculados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _alunosMatriculados.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum aluno matriculado nesta turma ainda.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _alunosMatriculados.length,
                          itemBuilder: (context, index) {
                            final aluno = _alunosMatriculados[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    aluno['name'] != null && aluno['name'].isNotEmpty ? aluno['name'][0].toUpperCase() : 'A',
                                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(aluno['name'] ?? 'Nome não disponível', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(aluno['email'] ?? ''),
                                trailing: Chip(
                                  label: const Text('Ativo', style: TextStyle(color: Colors.green, fontSize: 12)),
                                  backgroundColor: Colors.green.shade50,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
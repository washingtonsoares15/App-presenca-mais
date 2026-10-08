import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart'; // Pacote já utilizado no projeto para QR Code

class StudentDashboardScreen extends StatefulWidget {
  final int studentId; // ID do aluno logado
  
  const StudentDashboardScreen({super.key, this.studentId = 1});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final String _baseUrl = 'http://localhost:3000/api';
  
  List<dynamic> _turmasDisponiveis = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosAluno();
  }

  // Carregar turmas e calcular faltas reais
  Future<void> _carregarDadosAluno() async {
    setState(() => _isLoading = true);
    try {
      final responseTurmas = await http.get(Uri.parse('$_baseUrl/classes'));
      
      if (!mounted) return;

      if (responseTurmas.statusCode == 200) {
        final todas = jsonDecode(responseTurmas.body);
        for (var turma in todas) {
          turma['absences'] = turma['absences'] ?? 0; 
        }

        setState(() {
          _turmasDisponiveis = todas;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Matricular o aluno na turma
  Future<void> _matricularTurma(int classId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/student/enroll'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': widget.studentId,
          'class_id': classId,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matrícula efetuada com sucesso!'), backgroundColor: Colors.green),
        );
        _carregarDadosAluno();
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Erro ao matricular.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Enviar pedido de presença via QR Code lido
  Future<void> _enviarPresencaBackend(int classId, String qrData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/student/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': widget.studentId,
          'class_id': classId,
          'qr_data': qrData,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presença validada com sucesso! Falta evitada. 🎉'), backgroundColor: Colors.green),
        );
        _carregarDadosAluno();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao validar presença no servidor.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Abrir Ecrã/Modal de Leitura de QR Code com a Câmara
  void _abrirLeitorQrCode(BuildContext context, int classId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ler QR Code da Aula', style: TextStyle(color: Colors.blue)),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      Navigator.pop(context); // Fecha o leitor
                      _enviarPresencaBackend(classId, barcode.rawValue!);
                      break;
                    }
                  }
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para enviar atestado com anexo de documento
  void _mostrarDialogAtestado(BuildContext context, int classId) {
    final motivoController = TextEditingController();
    String nomeFicheiroAnexado = 'Nenhum ficheiro selecionado';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Enviar Atestado Médico', style: TextStyle(color: Colors.blue)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Descreva o motivo da ausência:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: motivoController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Ex: Consulta médica / Declaração',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Comprovativo / Documento:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Simulação de anexo de ficheiro (PDF/Imagem)
                          setStateModal(() {
                            nomeFicheiroAnexado = 'atestado_medico_2026.pdf';
                          });
                        },
                        icon: const Icon(Icons.attach_file, size: 16),
                        label: const Text('Anexar Ficheiro'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nomeFicheiroAnexado,
                    style: TextStyle(fontSize: 12, color: nomeFicheiroAnexado.contains('PDF') ? Colors.green : Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (motivoController.text.trim().isEmpty) return;

                    try {
                      final response = await http.post(
                        Uri.parse('$_baseUrl/student/certificate'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'student_id': widget.studentId,
                          'class_id': classId,
                          'reason': '${motivoController.text.trim()} [Anexo: $nomeFicheiroAnexado]',
                        }),
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context);

                      if (response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Atestado e documento enviados com sucesso!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao enviar atestado.'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Enviar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Painel do Aluno - Presença+'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alerta de Faltas / Risco de Reprovação
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 36),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Atenção ao Risco de Reprovação',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'As faltas só são contabilizadas se não validar o QR Code da aula.',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Minhas Turmas e Controlo de Presença',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  _turmasDisponiveis.isEmpty
                      ? const Text('Nenhuma turma disponível no momento.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _turmasDisponiveis.length,
                          itemBuilder: (context, index) {
                            final turma = _turmasDisponiveis[index];
                            int faltas = turma['absences'] ?? 0;
                            bool emRisco = faltas >= 5;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          turma['materia'] ?? '',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Chip(
                                          label: Text('$faltas Faltas', style: TextStyle(color: emRisco ? Colors.red : Colors.green)),
                                          backgroundColor: emRisco ? Colors.red.shade50 : Colors.green.shade50,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(turma['turma'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                                    const SizedBox(height: 12),
                                    if (emRisco)
                                      const Text(
                                        '⚠️ Em risco de reprovação por falta!',
                                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        // Botão Ler QR Code (Ativa a câmara)
                                        ElevatedButton.icon(
                                          onPressed: () => _abrirLeitorQrCode(context, turma['id']),
                                          icon: const Icon(Icons.qr_code_scanner, size: 16),
                                          label: const Text('Ler QR Code'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                        ),
                                        // Botão Enviar Atestado com Documento
                                        OutlinedButton.icon(
                                          onPressed: () => _mostrarDialogAtestado(context, turma['id']),
                                          icon: const Icon(Icons.upload_file, size: 16),
                                          label: const Text('Enviar Atestado'),
                                        ),
                                        // Botão Matricular
                                        ElevatedButton(
                                          onPressed: () => _matricularTurma(turma['id']),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                          child: const Text('Matricular'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class GenerateQrcodeScreen extends StatefulWidget {
  final dynamic turma; // Opcional agora para evitar erros caso seja chamado direto

  const GenerateQrcodeScreen({super.key, this.turma});

  @override
  State<GenerateQrcodeScreen> createState() => _GenerateQrcodeScreenState();
}

class _GenerateQrcodeScreenState extends State<GenerateQrcodeScreen> {
  final String _baseUrl = 'http://localhost:3000/api';
  List<dynamic> _turmasDisponiveis = [];
  bool _isLoadingTurmas = true;
  dynamic _turmaSelecionada;

  String? _qrData;
  Timer? _timer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    if (widget.turma != null) {
      _turmaSelecionada = widget.turma;
      _iniciarGeracaoQr();
    } else {
      _carregarTurmas();
    }
  }

  Future<void> _carregarTurmas() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/classes'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _turmasDisponiveis = jsonDecode(response.body);
          _isLoadingTurmas = false;
        });
      } else {
        setState(() => _isLoadingTurmas = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingTurmas = false);
    }
  }

  void _iniciarGeracaoQr() {
    _gerarNovoToken();
    _startTimer();
  }

  void _gerarNovoToken() {
    final classId = _turmaSelecionada != null ? _turmaSelecionada['id'] : 1;
    setState(() {
      _qrData = "PRESENCAMAIS_CLASS_${classId}_TOKEN_${DateTime.now().millisecondsSinceEpoch}";
      _secondsRemaining = 30;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _gerarNovoToken(); 
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se nenhuma turma foi passada por parâmetro e nenhuma foi selecionada ainda, mostra a lista para escolher
    if (widget.turma == null && _turmaSelecionada == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Selecionar Turma para Chamada'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: _isLoadingTurmas
            ? const Center(child: CircularProgressIndicator())
            : _turmasDisponiveis.isEmpty
                ? const Center(child: Text('Nenhuma turma cadastrada.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _turmasDisponiveis.length,
                    itemBuilder: (context, index) {
                      final t = _turmasDisponiveis[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(t['materia'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(t['turma'] ?? ''),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            setState(() {
                              _turmaSelecionada = t;
                            });
                            _iniciarGeracaoQr();
                          },
                        ),
                      );
                    },
                  ),
      );
    }

    final String materia = _turmaSelecionada['materia'] ?? 'Disciplina';
    final String turmaNome = _turmaSelecionada['turma'] ?? 'Turma';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gerar Chamada por QR Code'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          if (widget.turma == null)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Trocar Turma',
              onPressed: () {
                setState(() {
                  _timer?.cancel();
                  _turmaSelecionada = null;
                });
                _carregarTurmas();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  materia,
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  turmaNome,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_qrData != null)
                        QrImageView(
                          data: _qrData!,
                          version: QrVersions.auto,
                          size: 240.0,
                          backgroundColor: Colors.white,
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Peça aos alunos para escanearem este código',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Código expira em: $_secondsRemaining s',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining <= 5 ? Colors.red : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 240,
                  child: LinearProgressIndicator(
                    value: _secondsRemaining / 30,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    color: _secondsRemaining <= 5 ? Colors.red : AppColors.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Atualização automática para evitar fraudes',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
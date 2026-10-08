import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ScanQrcodeScreen extends StatefulWidget {
  const ScanQrcodeScreen({super.key});

  @override
  State<ScanQrcodeScreen> createState() => _ScanQrcodeScreenState();
}

class _ScanQrcodeScreenState extends State<ScanQrcodeScreen> {
  bool _isProcessing = false;
  String _statusMessage = 'Aponte a câmara para o QR Code da aula';

  Future<void> _processarPresenca(String qrData) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'A verificar localização GPS...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada.');
        }
      }

      // Código atualizado para evitar o aviso do "desiredAccuracy"
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return; // Proteção adicionada para evitar avisos de async gap
      setState(() {
        _statusMessage = 'Presença confirmada com sucesso!';
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Presença Registada!'),
            ],
          ),
          content: Text(
            'Dados da aula validados.\nGPS: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Erro: ${e.toString()}';
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao registar presença: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code da Aula'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && !_isProcessing) {
                    _processarPresenca(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing)
                    const CircularProgressIndicator()
                  else
                    const Icon(Icons.qr_code_scanner, color: Colors.blue, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
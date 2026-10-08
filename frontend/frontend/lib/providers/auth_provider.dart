import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  // Lembre-se: 'http://10.0.2.2:3000' para Emulador Android.
  // Use 'http://localhost:3000' para Web ou o seu IP local para telemóvel físico.
  final String baseUrl = 'http://localhost:3000';

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userName => _userName;

  // Função de Login com Debug detalhado
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // DEBUG: Mostra no terminal do VS Code o que o servidor respondeu
      debugPrint('STATUS LOGIN: ${response.statusCode}');
      debugPrint('RESPOSTA LOGIN: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['token']);
        
        _userName = data['name'] ?? (data['user'] != null ? data['user']['name'] : 'Aluno');

        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Erro de ligação com a API (Login): $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Função de Registo com Debug detalhado
  Future<bool> register(
      String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'name': name, 'email': email, 'password': password, 'role': role}),
      );

      // DEBUG: Mostra no terminal do VS Code o que o servidor respondeu no registo
      debugPrint('STATUS REGISTO: ${response.statusCode}');
      debugPrint('RESPOSTA REGISTO: ${response.body}');

      _isLoading = false;
      notifyListeners();

      // O backend pode retornar 201 Created ou 200 OK dependendo de como foi programado
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro de ligação com a API (Registo): $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    _isAuthenticated = false;
    _userName = null;
    notifyListeners();
  }
}
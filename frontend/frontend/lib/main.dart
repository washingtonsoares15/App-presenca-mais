import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/teacher/teacher_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configura o Provider globalmente para gerenciar o estado da autenticação
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'PresençaMais',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // Rota inicial da aplicação
        initialRoute: '/login',
        // Mapeamento de todas as telas do aplicativo
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/student_home': (context) => const StudentHomeScreen(),
          '/teacher_home': (context) => const TeacherHomeScreen(),
        },
      ),
    );
  }
}
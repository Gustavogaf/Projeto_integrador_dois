import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_screen.dart';

// Variável global para acessarmos o cliente do Supabase facilmente em qualquer tela
final supabase = Supabase.instance.client;

void main() async {
  // Garante que os bindings do Flutter estejam inicializados antes de chamar código assíncrono
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a conexão com o Supabase
  // TODO: Substitua pelas credenciais reais do seu projeto no Supabase
  await Supabase.initialize(
    url: 'https://ygccmgrasyamftnzamct.supabase.co',
    anonKey: 'sb_publishable_xGdVmJUI_syVaIwmenkhuw_ZyAxVoDe',
  );

  runApp(const SecurityQuizzApp());
}

class SecurityQuizzApp extends StatelessWidget {
  const SecurityQuizzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security Quizz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      // Temporariamente apontando para um Scaffold vazio até criarmos as rotas
      home: const LoginScreen(),
    );
  }
}
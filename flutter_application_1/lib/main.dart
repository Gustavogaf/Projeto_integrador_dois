import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_screen.dart';
import 'repositories/auth_repository.dart';
import 'repositories/theme_repository.dart';
import 'repositories/student_repository.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/admin_dashboard_viewmodel.dart';
import 'viewmodels/student_home_viewmodel.dart';
import 'repositories/question_repository.dart';
import 'viewmodels/create_question_viewmodel.dart';
import 'viewmodels/create_theme_viewmodel.dart';
import 'viewmodels/quiz_viewmodel.dart';
import 'viewmodels/history_viewmodel.dart';
import 'package:intl/date_symbol_data_local.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
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
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        Provider<ThemeRepository>(
          create: (_) => ThemeRepository(),
        ),
        Provider<QuestionRepository>(
          create: (_) => QuestionRepository(),
        ),
        Provider<StudentRepository>(
          create: (_) => StudentRepository(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<AdminDashboardViewModel>(
          create: (context) => AdminDashboardViewModel(
            themeRepository: context.read<ThemeRepository>(),
          ),
        ),
        ChangeNotifierProvider<CreateQuestionViewModel>(
          create: (context) => CreateQuestionViewModel(
            questionRepository: context.read<QuestionRepository>(),
            themeRepository: context.read<ThemeRepository>(), 
          ),
        ),
        ChangeNotifierProvider<CreateThemeViewModel>(
          create: (context) => CreateThemeViewModel(
            themeRepository: context.read<ThemeRepository>(),
          ),
        ),
        ChangeNotifierProvider<StudentHomeViewModel>(
          create: (context) => StudentHomeViewModel(
            studentRepository: context.read<StudentRepository>(),
            themeRepository: context.read<ThemeRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<QuizViewModel>(
          create: (context) => QuizViewModel(
            questionRepository: context.read<QuestionRepository>(),
            studentRepository: context.read<StudentRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<HistoryViewModel>(
          create: (context) => HistoryViewModel(
            studentRepository: context.read<StudentRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Security Quizz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
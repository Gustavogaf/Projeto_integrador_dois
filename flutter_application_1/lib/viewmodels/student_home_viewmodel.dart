import 'package:flutter/material.dart';
import '../models/tema_model.dart';
import '../repositories/student_repository.dart';
import '../repositories/theme_repository.dart';
import '../repositories/auth_repository.dart';

class StudentHomeViewModel extends ChangeNotifier {
  final StudentRepository studentRepository;
  final ThemeRepository themeRepository;
  final AuthRepository authRepository;

  StudentHomeViewModel({
    required this.studentRepository,
    required this.themeRepository,
    required this.authRepository,
  });

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _nomeAluno = '';
  String get nomeAluno => _nomeAluno;

  int _nivel = 0;
  int get nivel => _nivel;

  List<TemaModel> _temas = [];
  List<TemaModel> get temas => _temas;

  List<int> _temasConcluidosIds = [];
  
  int _perguntasRespondidasAtual = 0;
  int _totalPerguntasAtual = 0;
  int get perguntasRespondidasAtual => _perguntasRespondidasAtual;
  int get totalPerguntasAtual => _totalPerguntasAtual;

  Future<void> carregarDadosHome() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = authRepository.currentUser;
      if (user != null) {
        final perfil = await authRepository.checkProfile(user.id);
        _nomeAluno = perfil['nome'] ?? 'Aluno';
        
        final idPerfil = await studentRepository.getPerfilId(user.id);
        
        final historico = await studentRepository.getHistorico(idPerfil);
        _nivel = historico.length;
        _temasConcluidosIds = historico.map((h) => h.tema?.id ?? -1).toList();
        
        _temas = await themeRepository.fetchTemas();
        
        TemaModel? temaAtual;
        try {
          temaAtual = _temas.firstWhere((t) => !_temasConcluidosIds.contains(t.id));
        } catch (e) {
          temaAtual = null;
        }

        if (temaAtual != null) {
          _totalPerguntasAtual = temaAtual.qtdPerguntas;
          _perguntasRespondidasAtual = 0;
        } else {
          _totalPerguntasAtual = 1;
          _perguntasRespondidasAtual = 1;
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar Home: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getStatusTema(int idTema) {
    if (_temasConcluidosIds.contains(idTema)) return 'Concluído';
    
    final indexTema = _temas.indexWhere((t) => t.id == idTema);
    final indexPrimeiroNaoConcluido = _temas.indexWhere((t) => !_temasConcluidosIds.contains(t.id));
    
    if (indexTema == indexPrimeiroNaoConcluido) return 'Próximo';
    return 'Bloqueado'; 
  }
}
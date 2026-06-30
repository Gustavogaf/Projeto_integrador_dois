import 'package:flutter/material.dart';
import '../models/pergunta_model.dart';
import '../models/alternativa_model.dart';
import '../repositories/question_repository.dart';
import '../repositories/student_repository.dart';
import '../repositories/auth_repository.dart';

class QuizViewModel extends ChangeNotifier {
  final QuestionRepository questionRepository;
  final StudentRepository studentRepository;
  final AuthRepository authRepository;

  QuizViewModel({
    required this.questionRepository,
    required this.studentRepository,
    required this.authRepository,
  });

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<PerguntaModel> _perguntas = [];
  List<PerguntaModel> get perguntas => _perguntas;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  AlternativaModel? _alternativaSelecionada;
  AlternativaModel? get alternativaSelecionada => _alternativaSelecionada;

  bool _respondido = false;
  bool get respondido => _respondido;

  int _acertos = 0;
  int _erros = 0;


  Future<void> iniciarQuiz(int temaId) async {
    _isLoading = true;
    _currentIndex = 0;
    _acertos = 0;
    _erros = 0;
    _respondido = false;
    _alternativaSelecionada = null;
    notifyListeners();

    try {
      _perguntas = await questionRepository.getPerguntasDoTema(temaId);
    } catch (e) {
      debugPrint('Erro ao carregar perguntas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selecionarAlternativa(AlternativaModel alternativa) {
    if (_respondido) return; 
    _alternativaSelecionada = alternativa;
    notifyListeners();
  }

  void confirmarResposta() {
    if (_alternativaSelecionada == null || _respondido) return;

    if (_alternativaSelecionada!.isCorreta) {
      _acertos++;
    } else {
      _erros++;
    }
    
    _respondido = true;
    notifyListeners();
  }

  Future<bool> proximaPergunta(int temaId) async {
    if (_currentIndex < _perguntas.length - 1) {
      _currentIndex++;
      _respondido = false;
      _alternativaSelecionada = null;
      notifyListeners();
      return false; 
    } else {
      _isLoading = true;
      notifyListeners();
      
      try {
        final user = authRepository.currentUser;
        if (user != null) {
          final perfilId = await studentRepository.getPerfilId(user.id);
          await questionRepository.registrarResultado(
            perfilId: perfilId,
            temaId: temaId,
            acertos: _acertos,
            erros: _erros,
          );
        }
      } catch (e) {
        debugPrint('Erro ao salvar resultado: $e');
      }
      
      return true; 
    }
  }
}
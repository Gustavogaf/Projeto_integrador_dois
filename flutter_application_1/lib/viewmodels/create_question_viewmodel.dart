import 'package:flutter/material.dart';
import '../models/tema_model.dart';
import '../repositories/question_repository.dart';
import '../repositories/theme_repository.dart';

class CreateQuestionViewModel extends ChangeNotifier {
  final QuestionRepository questionRepository;
  final ThemeRepository themeRepository;

  CreateQuestionViewModel({
    required this.questionRepository,
    required this.themeRepository,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TemaModel> _temas = [];
  List<TemaModel> get temas => _temas;

  Future<void> carregarTemas() async {
    try {
      _temas = await themeRepository.fetchTemas();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar lista de temas';
      notifyListeners();
    }
  }

  Future<bool> salvarPergunta({
    required int temaId,
    required String enunciado,
    required List<String> alternativas,
    required int corretaIndex,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await questionRepository.createQuestionWithAlternatives(
        temaId: temaId,
        enunciado: enunciado,
        alternativas: alternativas,
        corretaIndex: corretaIndex,
      );
      _isLoading = false;
      notifyListeners();
      return true; 
    } catch (e) {
      _errorMessage = 'Erro ao salvar a pergunta. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false; 
    }
  }
}
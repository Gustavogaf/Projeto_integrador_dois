import 'package:flutter/material.dart';
import '../models/historico_model.dart';
import '../repositories/student_repository.dart';
import '../repositories/auth_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final StudentRepository studentRepository;
  final AuthRepository authRepository;

  HistoryViewModel({
    required this.studentRepository,
    required this.authRepository,
  });

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<HistoricoModel> _historico = [];
  List<HistoricoModel> get historico => _historico;

  int get totalQuizzes => _historico.length;

  String get mediaAcertos {
    if (_historico.isEmpty) return '0%';
    
    int totalAcertos = 0;
    int totalPerguntas = 0;
    
    for (var h in _historico) {
      totalAcertos += h.acertos;
      totalPerguntas += (h.acertos + h.erros);
    }
    
    if (totalPerguntas == 0) return '0%';
    
    final media = (totalAcertos / totalPerguntas) * 100;
    return '${media.toInt()}%';
  }

  Future<void> carregarHistorico() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = authRepository.currentUser;
      if (user != null) {
        final perfilId = await studentRepository.getPerfilId(user.id);
        _historico = await studentRepository.getHistorico(perfilId);
      }
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
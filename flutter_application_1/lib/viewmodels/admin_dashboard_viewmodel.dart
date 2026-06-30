import 'package:flutter/material.dart';
import '../models/tema_model.dart';
import '../repositories/theme_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final ThemeRepository themeRepository;

  AdminDashboardViewModel({required this.themeRepository});

  List<TemaModel> _temas = [];
  List<TemaModel> get temas => _temas;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadTemas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _temas = await themeRepository.fetchTemas();
    } catch (e) {
      _errorMessage = 'Erro ao carregar os temas.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTema(int idTema) async {
    try {
      await themeRepository.deleteTema(idTema);
      _temas.removeWhere((tema) => tema.id == idTema);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir o tema.';
      notifyListeners();
      return false;
    }
  }
}
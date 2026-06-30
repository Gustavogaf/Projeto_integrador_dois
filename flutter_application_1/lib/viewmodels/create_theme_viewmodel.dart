import 'package:flutter/material.dart';
import '../repositories/theme_repository.dart';

class CreateThemeViewModel extends ChangeNotifier {
  final ThemeRepository themeRepository;

  CreateThemeViewModel({required this.themeRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> salvarTema({
    int? idTema, 
    required String titulo,
    required String descricao,
    required String corHexadecimal,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (idTema == null) {
        await themeRepository.createTema(titulo, descricao, corHexadecimal);
      } else {
        await themeRepository.updateTema(idTema, titulo, descricao, corHexadecimal);
      }
      
      _isLoading = false;
      notifyListeners();
      return true; 
      
    } catch (e) {
      _errorMessage = 'Erro ao salvar o tema. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
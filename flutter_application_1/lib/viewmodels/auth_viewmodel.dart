import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {

final AuthRepository authRepository;

  AuthViewModel({required this.authRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    clearError();
    _setLoading(true);

    try {
      final response = await authRepository.signIn(email, password);
      final user = response.user;

      if (user != null) {
        final perfilData = await authRepository.checkProfile(user.id);
        _isAdmin = perfilData['is_admin'] == true;
        _setLoading(false);
        return true; 
      }
    } on AuthException catch (_) {
      _errorMessage = 'E-mail ou senha incorretos';
    } catch (error) {
      _errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';
    }

    _setLoading(false);
    return false;
  }

  Future<bool> signUp(String email, String password, String nome) async {
    clearError();
    _setLoading(true);

    try {
      final res = await authRepository.signUp(email, password);
      final user = res.user;

      if (user != null) {
        await authRepository.createProfile(user.id, nome);
        _setLoading(false);
        return true; 
      }
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Ocorreu um erro inesperado.';
    }

    _setLoading(false);
    return false;
  }
}
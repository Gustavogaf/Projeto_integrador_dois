import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseClient _db = Supabase.instance.client;

  User? get currentUser => _auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) {
    return _auth.signUp(email: email, password: password);
  }

  Future<Map<String, dynamic>> checkProfile(String userId) {
    return _db.from('perfil').select('is_admin, nome').eq('id_user', userId).single();
  }

  Future<void> createProfile(String userId, String nome) {
    return _db.from('perfil').insert({
      'id_user': userId,
      'nome': nome,
      'is_admin': false,
    });
  }
}
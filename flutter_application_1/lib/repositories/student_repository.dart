import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/historico_model.dart';

class StudentRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<int> getPerfilId(String userId) async {
    final response = await _db.from('perfil').select('id_perfil').eq('id_user', userId).single();
    return response['id_perfil'];
  }

  Future<int> getStudentLevel(int perfilId) async {
    final response = await _db
        .from('historico')
        .select('id_historico')
        .eq('id_perfil', perfilId);
    
    return (response as List).length;
  }

  Future<List<HistoricoModel>> getHistorico(int perfilId) async {
    final response = await _db.from('historico').select('''
      id_historico,
      acertos,
      erros,
      data_conclusao,
      temas (
        id_temas,
        titulo,
        descricao,
        cor_hexadecimal
      )
    ''').eq('id_perfil', perfilId).order('data_conclusao', ascending: false);

    return (response as List).map((json) => HistoricoModel.fromJson(json)).toList();
  }
}
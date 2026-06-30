import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tema_model.dart';

class ThemeRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<TemaModel>> fetchTemas() async {
    final response = await _db.from('temas').select('''
      id_temas,
      titulo,
      descricao,
      cor_hexadecimal,
      perguntas(count)
    ''').order('data_criacao', ascending: false);

    return (response as List).map((json) => TemaModel.fromJson(json)).toList();
  }

  Future<void> deleteTema(int idTema) async {
    await _db.from('temas').delete().eq('id_temas', idTema);
  }

  Future<void> createTema(String titulo, String descricao, String corHexadecimal) async {
    await _db.from('temas').insert({
      'titulo': titulo,
      'descricao': descricao,
      'cor_hexadecimal': corHexadecimal,
      'data_criacao': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateTema(int idTema, String titulo, String descricao, String corHexadecimal) async {
    await _db.from('temas').update({
      'titulo': titulo,
      'descricao': descricao,
      'cor_hexadecimal': corHexadecimal,
    }).eq('id_temas', idTema);
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pergunta_model.dart';

class QuestionRepository {
  final SupabaseClient _db = Supabase.instance.client;

  Future<void> createQuestionWithAlternatives({
    required int temaId,
    required String enunciado,
    required List<String> alternativas,
    required int corretaIndex,
  }) async {
    final perguntaResponse = await _db.from('perguntas').insert({
      'id_tema': temaId,
      'enunciado': enunciado,
      'data_criacao': DateTime.now().toIso8601String(),
    }).select('id_pergunta').single();

    final int idPerguntaGerado = perguntaResponse['id_pergunta'];

    final List<Map<String, dynamic>> alternativasData = [];
    for (int i = 0; i < alternativas.length; i++) {
      alternativasData.add({
        'id_pergunta': idPerguntaGerado,
        'enunciado_alternativa': alternativas[i],
        'is_correta': i == corretaIndex,
      });
    }

    await _db.from('alternativas').insert(alternativasData);
  }

  Future<List<PerguntaModel>> getPerguntasDoTema(int temaId) async {
    final response = await _db.from('perguntas').select('''
      id_pergunta,
      enunciado,
      alternativas (
        id_alternativa,
        enunciado_alternativa,
        is_correta
      )
    ''').eq('id_tema', temaId);

    return (response as List).map((json) {
      final pergunta = PerguntaModel.fromJson(json);
      pergunta.alternativas.shuffle(); 
      return pergunta;
    }).toList();
  }

  Future<void> registrarResultado({
    required int perfilId,
    required int temaId,
    required int acertos,
    required int erros,
  }) async {
    await _db.from('historico').insert({
      'id_perfil': perfilId,
      'id_tema': temaId,
      'acertos': acertos,
      'erros': erros,
      'data_conclusao': DateTime.now().toIso8601String(),
    });
  }
}
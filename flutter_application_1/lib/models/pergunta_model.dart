import 'alternativa_model.dart';

class PerguntaModel {
  final int id;
  final String enunciado;
  final List<AlternativaModel> alternativas;

  PerguntaModel({
    required this.id,
    required this.enunciado,
    required this.alternativas,
  });

  factory PerguntaModel.fromJson(Map<String, dynamic> json) {
    var listaAlternativas = json['alternativas'] as List? ?? [];
    return PerguntaModel(
      id: json['id_pergunta'],
      enunciado: json['enunciado'],
      alternativas: listaAlternativas.map((alt) => AlternativaModel.fromJson(alt)).toList(),
    );
  }
}
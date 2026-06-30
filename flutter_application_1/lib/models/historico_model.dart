import 'tema_model.dart';

class HistoricoModel {
  final int id;
  final int acertos;
  final int erros;
  final DateTime dataConclusao;
  final TemaModel? tema; 

  HistoricoModel({
    required this.id,
    required this.acertos,
    required this.erros,
    required this.dataConclusao,
    this.tema,
  });

  factory HistoricoModel.fromJson(Map<String, dynamic> json) {
    return HistoricoModel(
      id: json['id_historico'],
      acertos: json['acertos'],
      erros: json['erros'],
      dataConclusao: DateTime.parse(json['data_conclusao']),
      tema: json['temas'] != null ? TemaModel.fromJson(json['temas']) : null,
    );
  }
}
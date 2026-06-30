class AlternativaModel {
  final int id;
  final String enunciado;
  final bool isCorreta;

  AlternativaModel({
    required this.id,
    required this.enunciado,
    required this.isCorreta,
  });

  factory AlternativaModel.fromJson(Map<String, dynamic> json) {
    return AlternativaModel(
      id: json['id_alternativa'],
      enunciado: json['enunciado_alternativa'],
      isCorreta: json['is_correta'] ?? false,
    );
  }
}
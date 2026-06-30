class TemaModel {
  final int id;
  final String titulo;
  final String descricao;
  final String corHexadecimal;
  final int qtdPerguntas;

  TemaModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.corHexadecimal,
    required this.qtdPerguntas,
  });

  factory TemaModel.fromJson(Map<String, dynamic> json) {
    int qtd = 0;
    if (json['perguntas'] != null && (json['perguntas'] as List).isNotEmpty) {
      qtd = json['perguntas'][0]['count'] ?? 0;
    }

    return TemaModel(
      id: json['id_temas'],
      titulo: json['titulo'] ?? 'Sem Título',
      descricao: json['descricao'] ?? 'Sem descrição',
      corHexadecimal: json['cor_hexadecimal'] ?? '',
      qtdPerguntas: qtd,
    );
  }
}
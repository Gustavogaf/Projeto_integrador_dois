import 'package:flutter/material.dart';
import 'app_text.dart';
import 'custom_delete_button.dart';

class ThemeCard extends StatelessWidget {
  final Map<String, dynamic> tema;
  final int qtdPerguntas;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ThemeCard({
    super.key,
    required this.tema,
    required this.qtdPerguntas,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shield_outlined, color: accentColor),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.indigo),
                      onPressed: onEdit,
                    ),
                    CustomDeleteButton(onPressed: onDelete),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppText(
              tema['titulo'] ?? 'Sem Título',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            AppText(
              tema['descricao'] ?? 'Sem descrição',
              color: Colors.black87,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                  child: const AppText('Ativo', color: Colors.blue, fontSize: 12),
                ),
                AppText('$qtdPerguntas Perguntas', color: Colors.grey, fontSize: 14),
              ],
            )
          ],
        ),
      ),
    );
  }
}
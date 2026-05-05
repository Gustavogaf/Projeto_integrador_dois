import 'package:flutter/material.dart';
import 'app_text.dart';
import 'custom_delete_button.dart';

class AlternativaItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final TextEditingController controller;
  final VoidCallback onTapRadio;
  final VoidCallback? onRemove; 

  const AlternativaItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.controller,
    required this.onTapRadio,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final letraOpcao = String.fromCharCode(65 + index);
    const primaryBlue = Color(0xFF1E3A8A);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primaryBlue : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTapRadio,
            child: Container(
              margin: const EdgeInsets.only(top: 4, right: 16),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? primaryBlue : Colors.grey, width: 2),
              ),
              child: isSelected
                  ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle)))
                  : null,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      isSelected ? 'Opção $letraOpcao (Correta)' : 'Opção $letraOpcao',
                      color: isSelected ? primaryBlue : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    if (onRemove != null)
                      CustomDeleteButton(
                        onPressed: onRemove!,
                        iconData: Icons.close, 
                        iconColor: Colors.grey,
                        iconSize: 18.0,
                      ),
                  ],
                ),
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Insira o texto da alternativa...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
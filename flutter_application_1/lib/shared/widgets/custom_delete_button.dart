import 'package:flutter/material.dart';

class CustomDeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final double iconSize;
  final IconData iconData; 
  final Color iconColor; 

  const CustomDeleteButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Remover',
    this.iconSize = 24.0,
    this.iconData = Icons.delete_outline, 
    this.iconColor = Colors.red, 
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData, color: iconColor, size: iconSize),
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero, 
      constraints: const BoxConstraints(), 
    );
  }
}
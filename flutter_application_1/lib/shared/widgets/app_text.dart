import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.color,
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  factory AppText.title(String text, {Color? color, TextAlign? textAlign}) {
    return AppText(
      text,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color ?? const Color(0xFF1E3A8A),
      textAlign: textAlign,
    );
  }

  factory AppText.subtitle(String text, {Color? color, TextAlign? textAlign}) {
    return AppText(
      text,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color ?? Colors.black87,
      textAlign: textAlign,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? Colors.black87,
        fontWeight: fontWeight,
      ),
    );
  }
}
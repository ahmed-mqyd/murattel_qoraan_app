import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextApp extends StatelessWidget {
  const TextApp({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.shadowColor,
    this.blurRadius,
    this.textAlign,
    this.height,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.offset = const Offset(0, 2),
  });

  final String text;
  final double? fontSize;
  final double? blurRadius;
  final FontWeight? fontWeight;
  final Color? color;
  final Color? shadowColor;
  final double? height;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.getFont(
        'Noto Naskh Arabic',

        textStyle: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          decoration: decoration,
          height: height,
          shadows: shadowColor != null
              ? [
                  Shadow(
                    color: shadowColor!,
                    blurRadius: blurRadius ?? 0.0,
                    offset: offset,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

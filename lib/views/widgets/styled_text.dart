import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  final String? text;
  final TextStyle style;
  final double textHeight;

  const StyledText({super.key, this.text, required this.style, this.textHeight = 0});

  @override
  Widget build(BuildContext context) {
    TextStyle effectiveStyle = style;
    final fontSize = style.fontSize;
    
    if (textHeight > 0 && fontSize != null && fontSize > 0) {
      // Flutter height multiplier = desired line height / font size
      effectiveStyle = style.copyWith(height: textHeight / fontSize);
    }

    return Text(text ?? '', style: effectiveStyle);
  }
}
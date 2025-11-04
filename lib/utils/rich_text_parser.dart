import 'package:flutter/material.dart';

class RichParserText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;

  const RichParserText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, color: textColor),
        children: _parseText(text),
      ),
    );
  }

  List<TextSpan> _parseText(String input) {
    final spans = <TextSpan>[];

    // regexy pro různé značky
    final regex = RegExp(
      r'(\*\*(.*?)\*\*|_(.*?)_|~~(.*?)~~|\[([a-zA-Z#0-9]+)\](.*?)\[/\5\])',
      dotAll: true,
    );

    int lastIndex = 0;

    for (final match in regex.allMatches(input)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: input.substring(lastIndex, match.start)));
      }

      String? bold = match.group(2);
      String? italic = match.group(3);
      String? strike = match.group(4);
      String? colorName = match.group(5);
      String? coloredText = match.group(6);

      if (bold != null) {
        spans.add(
          TextSpan(
            text: bold,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (italic != null) {
        spans.add(
          TextSpan(
            text: italic,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (strike != null) {
        spans.add(
          TextSpan(
            text: strike,
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
        );
      } else if (colorName != null && coloredText != null) {
        spans.add(
          TextSpan(
            text: coloredText,
            style: TextStyle(color: _parseColor(colorName)),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      spans.add(TextSpan(text: input.substring(lastIndex)));
    }

    return spans;
  }

  Color _parseColor(String name) {
    // předdefinované názvy barev
    switch (name.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'grey':
      case 'gray':
        return Colors.grey;
    }

    // pokud je hex (#rrggbb)
    if (name.startsWith('#')) {
      try {
        final hex = name.substring(1);
        final color = int.parse(hex, radix: 16);
        if (hex.length == 6) return Color(0xFF000000 | color);
        if (hex.length == 8) return Color(color);
      } catch (_) {}
    }

    // fallback
    return Colors.black;
  }
}

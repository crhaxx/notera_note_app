import 'package:flutter/material.dart';

class RichInputField extends StatefulWidget {
  final TextEditingController controller;
  const RichInputField({super.key, required this.controller});

  @override
  State<RichInputField> createState() => _RichInputFieldState();
}

class _RichInputFieldState extends State<RichInputField> {
  final scrollController = ScrollController();

  late final baseStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    height: 1.25,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    String _displayText = widget.controller.text.replaceAll(
      RegExp(r'\[/?[a-zA-Z0-9#]+\]'),
      '\u200B',
    );

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            // View layer
            SingleChildScrollView(
              controller: widget.controller.text.length > 0
                  ? scrollController
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Text.rich(
                TextSpan(
                  style: baseStyle.copyWith(color: Colors.white),
                  children: _parseText(_displayText),
                ),
              ),
            ),

            // Input layer
            TextField(
              controller: widget.controller,
              scrollController: scrollController,
              maxLines: null,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              style: baseStyle.copyWith(
                color: Colors.transparent, // transparent text
                backgroundColor: Colors.transparent,
              ),
              onChanged: (value) {
                setState(() {
                  _displayText = value.replaceAll(
                    RegExp(r'\[/?[a-zA-Z0-9#]+\]'),
                    '\u200B',
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _parseText(String input) {
    final spans = <TextSpan>[];
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

    if (name.startsWith('#')) {
      try {
        final hex = name.substring(1);
        final color = int.parse(hex, radix: 16);
        if (hex.length == 6) return Color(0xFF000000 | color);
        if (hex.length == 8) return Color(color);
      } catch (_) {}
    }
    return Colors.black;
  }
}

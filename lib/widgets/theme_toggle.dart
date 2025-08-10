import 'package:flutter/material.dart';
import 'package:notera_note/main.dart';

class ThemeToggle extends StatelessWidget {
  final bool isDark;
  final Function(bool) changeTheme;

  const ThemeToggle({
    super.key,
    required this.isDark,
    required this.changeTheme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        changeTheme(!isDark);
      },
    );
  }
}

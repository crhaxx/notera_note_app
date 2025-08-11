import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeToggle extends StatelessWidget {
  final bool isDark;
  final Function(bool) changeTheme;

  const ThemeToggle({
    super.key,
    required this.isDark,
    required this.changeTheme,
  });

  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        changeTheme(!isDark);
        saveTheme(!isDark);
      },
    );
  }
}

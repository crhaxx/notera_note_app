import 'package:flutter/material.dart';

class AppThemes {
  static final darkTheme = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark(
      primary: Colors.tealAccent,
      background: Color(0xFF121212),
    ),

    //PINNED - NOTPINNED
    highlightColor: Color.fromARGB(255, 54, 54, 54),
    cardColor: Color.fromARGB(255, 34, 34, 34),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),
  );

  static final lightTheme = ThemeData.light().copyWith(
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      background: Colors.white,
    ),

    //PINNED - NOTPINNED
    highlightColor: Colors.white,
    cardColor: Colors.white.withAlpha(240),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  );
}

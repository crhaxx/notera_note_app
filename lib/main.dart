import 'package:flutter/material.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/views/home_page.dart';
import 'package:notera_note/utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(NoteraApp());
}

class NoteraApp extends StatefulWidget {
  const NoteraApp({super.key});

  @override
  State<NoteraApp> createState() => _NoteraAppState();
}

class _NoteraAppState extends State<NoteraApp> {
  bool isDark = true;
  IsarService isarService = IsarService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notera',
      theme: isDark ? AppThemes.darkTheme : AppThemes.lightTheme,
      home: HomePage(
        toggleTheme: () => setState(() => isDark = !isDark),
        isDark: isDark,
        isarService: isarService,
      ),
    );
  }
}

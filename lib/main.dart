import 'package:flutter/material.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/utils/navbar_logic.dart';
import 'package:notera_note/utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late bool isDark;
  bool isLoading = true;
  IsarService isarService = IsarService();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool('isDark') ?? true; // Default to dark theme
      isLoading = false;
    });
  }

  void changeTheme(bool darkTheme) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = darkTheme;
    });
    await prefs.setBool('isDark', darkTheme);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Notera',
      theme: isDark ? AppThemes.darkTheme : AppThemes.lightTheme,
      home: BottomNavScreen(
        key: ValueKey(isDark), // This forces rebuild when theme changes
        isDark: isDark,
        changeTheme: changeTheme,
      ),
    );
  }
}

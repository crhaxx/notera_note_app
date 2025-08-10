import 'package:flutter/material.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/views/archive_page.dart';
import 'package:notera_note/views/home_page.dart';
import 'package:notera_note/views/settings_page.dart';

class BottomNavScreen extends StatefulWidget {
  final bool isDark;
  final Function(bool) changeTheme;

  const BottomNavScreen({
    super.key,
    required this.isDark,
    required this.changeTheme,
  });

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  late IsarService isarService;
  late List<Widget> _pages;
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();

  @override
  void initState() {
    super.initState();
    isarService = IsarService();
    _createPages();
  }

  void _createPages() {
    _pages = [
      HomePage(
        key: _homePageKey,
        isDark: widget.isDark,
        isarService: isarService,
        changeTheme: widget.changeTheme,
      ),
      ArchivePage(),
      SettingsPage(isDark: widget.isDark, changeTheme: widget.changeTheme),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _homePageKey.currentState?.refreshNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Archiv'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Nastavení',
          ),
        ],
      ),
    );
  }
}

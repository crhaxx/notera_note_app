import 'package:flutter/material.dart';
import 'package:notera_note/services/isar_service.dart';
import 'package:notera_note/views/archive_page.dart';
import 'package:notera_note/views/home_page.dart';
import 'package:notera_note/views/settings_page.dart';

class BottomNavScreen extends StatefulWidget {
  final bool isDark;
  final Function(bool) changeTheme;
  final int? initialIndex;

  const BottomNavScreen({
    super.key,
    required this.isDark,
    required this.changeTheme,
    this.initialIndex,
  });

  @override
  State<BottomNavScreen> createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  late IsarService isarService;
  late List<Widget> _pages;
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();

  @override
  void initState() {
    super.initState();
    isarService = IsarService();
    _selectedIndex = widget.initialIndex ?? 0;
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
      ArchivePage(changeTheme: widget.changeTheme,),
      SettingsPage(isDark: widget.isDark, changeTheme: widget.changeTheme),
    ];
  }

  void changeTab(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _homePageKey.currentState?.refreshNotes();
    }
  }

  void _onItemTapped(int index) {
    changeTab(index);
  }

  @override
  void didUpdateWidget(BottomNavScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      _createPages(); // Znovu vytvoří stránky s novým tématem
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
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Archive'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

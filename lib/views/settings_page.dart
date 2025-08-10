import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isDark;
  final Function(bool) changeTheme;

  const SettingsPage({
    super.key,
    required this.isDark,
    required this.changeTheme,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _currentDarkMode;

  @override
  void initState() {
    super.initState();
    _currentDarkMode = widget.isDark;
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      setState(() {
        _currentDarkMode = widget.isDark;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Current Theme: ${_currentDarkMode ? 'Dark' : 'Light'}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Toggle Dark Mode"),
              value: _currentDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _currentDarkMode = value;
                  widget.changeTheme(value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

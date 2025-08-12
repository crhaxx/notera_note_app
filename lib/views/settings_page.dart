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
  bool remindersEnabled = true;

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
            Text("Main Settings", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Toggle Dark Mode"),
              subtitle: const Text("Enable or disable dark mode"),
              value: _currentDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _currentDarkMode = value;
                  widget.changeTheme(value);
                });
              },
            ),

            SwitchListTile(
              title: const Text('Notifications'),
              value: remindersEnabled,
              subtitle: const Text(
                'Enable or disable notifications for reminders (currently not implemented)',
              ),
              onChanged: (value) {
                setState(() => remindersEnabled = value);
              },
            ),

            ListTile(
              title: const Text('Default Note Color'),
              subtitle: const Text(
                'Set the default color for new notes (currently not implemented)',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Otevřít color picker
              },
            ),

            const Divider(),

            ListTile(
              title: const Text('About Notera'),
              subtitle: const Text(
                'Information about the app (currently not implemented)',
              ),
              onTap: () {
                // TODO: Navigace na info stránku
              },
            ),
          ],
        ),
      ),
    );
  }
}

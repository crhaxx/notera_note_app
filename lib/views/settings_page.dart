import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:notera_note/views/about_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Color defaultNoteColor = Colors.white;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _currentDarkMode = widget.isDark;
    _loadSettings();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    _notificationsEnabled = await getNotificationsEnabled();
    setState(() {});
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
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

  final List<Color> availableColors = [
    Colors.white,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.orange,
    Colors.purple,
  ];

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // remindersEnabled = prefs.getBool('remindersEnabled') ?? true;
      int? colorValue = prefs.getInt('defaultNoteColor');
      if (colorValue != null) {
        defaultNoteColor = Color(colorValue);
      }
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                value: _notificationsEnabled,
                subtitle: const Text(
                  'Enable or disable notifications for reminders',
                ),
                onChanged: (bool value) async {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  await setNotificationsEnabled(value);

                  if (value) {
                    // Zapnout notifikace
                    await AwesomeNotifications().setGlobalBadgeCounter(0);
                    await AwesomeNotifications()
                        .requestPermissionToSendNotifications();
                  } else {
                    // Vypnout notifikace
                    await AwesomeNotifications().cancelAll();
                    await AwesomeNotifications().setGlobalBadgeCounter(0);
                  }
                },
              ),

              ListTile(
                title: const Text('Default Note Color'),
                subtitle: const Text('Set the default color for new notes'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Change Color"),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
                                for (var color in Colors.allcolors)
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        defaultNoteColor = color;
                                      });
                                      _saveSetting(
                                        'defaultNoteColor',
                                        color.value,
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: color,
                                      radius: 20,
                                      child:
                                          color.value == defaultNoteColor.value
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.black,
                                            )
                                          : null,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(),

              ListTile(
                title: const Text('About Notera'),
                subtitle: const Text('Information about the app'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

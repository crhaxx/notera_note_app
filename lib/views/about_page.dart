import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  final String appVersion;
  final String appName;
  final String packageName;
  final String developerName;
  final String description;
  final String licenseUrl;
  final String lastUpdated;

  const AboutPage({
    super.key,
    required this.appVersion,
    required this.appName,
    required this.packageName,
    required this.developerName,
    required this.description,
    required this.licenseUrl,
    required this.lastUpdated,
  });

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Notera')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.appName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text(
              widget.packageName,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            Text(widget.description, style: TextStyle(fontSize: 18)),

            const SizedBox(height: 16),

            Text(
              "Developer: " + widget.developerName,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            Text(
              "Version: " + widget.appVersion,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            Text(
              "Last Updated: " + widget.lastUpdated,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('View Licenses'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

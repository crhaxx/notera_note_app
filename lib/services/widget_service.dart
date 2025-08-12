import 'package:flutter/services.dart';

class WidgetService {
  static const _channel = MethodChannel(
    'com.darkgravestudios.notera_note/widget',
  );

  static Future<void> updateLastNote(String title, String content) async {
    try {
      await _channel.invokeMethod('updateLastNote', {
        'title': title,
        'content': content,
      });
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
}

import 'package:flutter/services.dart';

class WidgetService {
  static const _widgetChannel = MethodChannel(
    'com.darkgravestudios.notera_note/widget',
  );
  static const _noteChannel = MethodChannel(
    'com.darkgravestudios.notera_note/note',
  );

  /// Uloží poslední poznámku pro widget
  static Future<void> updateLastNoteForWidget({
    required String title,
    required String content,
    required String noteId,
  }) async {
    try {
      await _widgetChannel.invokeMethod('updateLastNote', {
        'title': title,
        'content': content,
        'noteId': noteId,
      });
    } catch (e) {
      print('Chyba při aktualizaci widgetu: $e');
    }
  }

  /// Zkontroluje, zda byla aplikace spuštěna kliknutím na widget
  Future<void> checkIfOpenedFromWidget(
    Function(String) onNoteIdReceived,
  ) async {
    try {
      final noteId = await _noteChannel.invokeMethod<String>(
        'getInitialNoteId',
      );
      if (noteId != null && noteId.isNotEmpty) {
        onNoteIdReceived(noteId);
      }
    } catch (e) {
      print('Chyba při načítání noteId z widgetu: $e');
    }
  }

  /// Poslouchá kliknutí na widget při spuštěné aplikaci
  void listenForWidgetClicks(Function(String) onNoteIdReceived) {
    _noteChannel.setMethodCallHandler((call) async {
      if (call.method == 'openNoteFromWidget') {
        final noteId = call.arguments as String?;
        if (noteId != null && noteId.isNotEmpty) {
          onNoteIdReceived(noteId);
        }
      }
    });
  }
}

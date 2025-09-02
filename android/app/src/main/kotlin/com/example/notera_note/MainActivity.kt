package com.darkgravestudios.notera_note

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.darkgravestudios.notera_note/widget"
    private val NOTE_CHANNEL = "com.darkgravestudios.notera_note/note"

    private var initialNoteId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Přečteme noteId při startu
        initialNoteId = intent?.getStringExtra("noteId")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Kanál pro ukládání poslední poznámky pro widget
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "updateLastNote") {
                    val title = call.argument<String>("title")
                    val content = call.argument<String>("content")
                    val noteId = call.argument<String>("noteId")
                    SharedPrefsHelper.saveLastNote(this, title ?: "", content ?: "", noteId ?: "")
                    LastNoteWidgetProvider.updateAllWidgets(this)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }

        // Kanál pro načtení noteId při startu
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getInitialNoteId") {
                    result.success(initialNoteId)
                    initialNoteId = null
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        // Otevření poznámky za běhu aplikace
        val noteId = intent.getStringExtra("noteId")
        if (noteId != null && flutterEngine != null) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, NOTE_CHANNEL)
                .invokeMethod("openNoteFromWidget", noteId)
        }
    }
}

package com.darkgravestudios.notera_note

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.darkgravestudios.notera_note/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateLastNote") {
                val title = call.argument<String>("title")
                val content = call.argument<String>("content")
                SharedPrefsHelper.saveLastNote(this, title ?: "", content ?: "")
                LastNoteWidgetProvider.updateAllWidgets(this)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}

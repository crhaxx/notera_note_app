package com.darkgravestudios.notera_note;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

public class SharedPrefsHelper {
    private static final String PREFS_NAME = "notera_prefs";
    private static final String KEY_TITLE = "last_note_title";
    private static final String KEY_CONTENT = "last_note_content";
    private static final String KEY_ID = "last_note_id";

    // Původní metoda - kompatibilita
    public static void saveLastNote(Context context, String title, String content) {
        saveLastNote(context, title, content, null);
    }

    // Nová metoda s noteId
    public static void saveLastNote(Context context, String title, String content, String noteId) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        prefs.edit()
            .putString(KEY_TITLE, title)
            .putString(KEY_CONTENT, content)
            .putString(KEY_ID, noteId)
            .apply();
    }

    public static String getLastNoteTitle(Context context) {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getString(KEY_TITLE, null);
    }

    public static String getLastNoteContent(Context context) {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getString(KEY_CONTENT, null);
    }

    public static String getLastNoteId(Context context) {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getString(KEY_ID, null);
    }
}

package com.darkgravestudios.notera_note;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

public class SharedPrefsHelper {
    private static final String PREFS_NAME = "notera_prefs";
    private static final String KEY_TITLE = "last_note_title";
    private static final String KEY_CONTENT = "last_note_content";

    public static void saveLastNote(Context context, String title, String content) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        prefs.edit()
            .putString(KEY_TITLE, title)
            .putString(KEY_CONTENT, content)
            .apply();
    }

    public static String getLastNoteTitle(Context context) {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getString(KEY_TITLE, null);
    }

    public static String getLastNoteContent(Context context) {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getString(KEY_CONTENT, null);
    }

    public static String getLastNoteId(Context context) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        return prefs.getString("last_note_id", null);
    }
}

package com.darkgravestudios.notera_note;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Color;
import android.widget.RemoteViews;

public class LastNoteWidgetProvider extends AppWidgetProvider {

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    public static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        // Načtení poslední poznámky ze SharedPreferences
        String title = SharedPrefsHelper.getLastNoteTitle(context);
        String content = SharedPrefsHelper.getLastNoteContent(context);
        String noteId = SharedPrefsHelper.getLastNoteId(context); // musíš mít uložené i ID

        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.last_note_widget);

        // Nastavení textu
        views.setTextViewText(R.id.widget_note_title, title != null ? title : "Žádná poznámka");
        views.setTextViewText(R.id.widget_note_content, content != null ? content : "");

        // Detekce světlého/tmavého režimu
        int nightModeFlags = context.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK;
        if (nightModeFlags == Configuration.UI_MODE_NIGHT_YES) {
            // Tmavé barvy
            views.setInt(R.id.widget_container, "setBackgroundColor", Color.parseColor("#222222"));
            views.setTextColor(R.id.widget_note_title, Color.WHITE);
            views.setTextColor(R.id.widget_note_content, Color.LTGRAY);
        } else {
            // Světlé barvy
            views.setInt(R.id.widget_container, "setBackgroundColor", Color.WHITE);
            views.setTextColor(R.id.widget_note_title, Color.BLACK);
            views.setTextColor(R.id.widget_note_content, Color.DKGRAY);
        }

        // Kliknutí otevře konkrétní poznámku
        Intent intent = new Intent(context, MainActivity.class);
        intent.putExtra("noteId", noteId); // předáme ID poznámky do Flutteru
        PendingIntent pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent);

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    public static void updateAllWidgets(Context context) {
        AppWidgetManager manager = AppWidgetManager.getInstance(context);
        ComponentName thisWidget = new ComponentName(context, LastNoteWidgetProvider.class);
        int[] ids = manager.getAppWidgetIds(thisWidget);
        for (int id : ids) {
            updateAppWidget(context, manager, id);
        }
    }
}

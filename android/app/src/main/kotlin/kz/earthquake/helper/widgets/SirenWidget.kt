package kz.earthquake.helper.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import kz.earthquake.helper.R

class SirenWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        try {
            for (appWidgetId in appWidgetIds) {
                try {
                    updateAppWidget(context, appWidgetManager, appWidgetId)
                } catch (e: Exception) {
                    android.util.Log.e("SirenWidget", "Error updating widget $appWidgetId", e)
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("SirenWidget", "Error in onUpdate", e)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        try {
            // Обновляем виджет при получении broadcast
            if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE || 
                intent.action == ACTION_TOGGLE_SIREN) {
                try {
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(
                        android.content.ComponentName(context, SirenWidget::class.java)
                    )
                    for (appWidgetId in appWidgetIds) {
                        try {
                            updateAppWidget(context, appWidgetManager, appWidgetId)
                        } catch (e: Exception) {
                            android.util.Log.e("SirenWidget", "Error updating widget $appWidgetId in onReceive", e)
                        }
                    }
                } catch (e: Exception) {
                    android.util.Log.e("SirenWidget", "Error in onReceive", e)
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("SirenWidget", "Critical error in onReceive", e)
        }
    }

    override fun onEnabled(context: Context) {
        // Виджет включен
    }

    override fun onDisabled(context: Context) {
        // Виджет отключен
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            val views = RemoteViews(context.packageName, R.layout.widget_siren)
            
            try {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val isPlaying = prefs.getBoolean("flutter.siren_state", false) || 
                               prefs.getString("flutter.siren_state", "stopped") == "playing"

                // Обновление внешнего вида кнопки
                if (isPlaying) {
                    views.setTextViewText(R.id.btn_siren, "⏹ Остановить\nсирену")
                    views.setTextViewText(R.id.widget_title, "🔴 Сирена активна")
                    // Устанавливаем цвет фона через setInt (для Button в RemoteViews)
                    try {
                        views.setInt(R.id.btn_siren, "setBackgroundColor", 0xFFD32F2F.toInt())
                    } catch (e: Exception) {
                        android.util.Log.w("SirenWidget", "Could not set background color for playing state", e)
                    }
                } else {
                    views.setTextViewText(R.id.btn_siren, "▶ Включить\nсирену")
                    views.setTextViewText(R.id.widget_title, "Сирена тревоги")
                    try {
                        views.setInt(R.id.btn_siren, "setBackgroundColor", 0xFF4CAF50.toInt())
                    } catch (e: Exception) {
                        android.util.Log.w("SirenWidget", "Could not set background color for stopped state", e)
                    }
                }
            } catch (e: Exception) {
                android.util.Log.e("SirenWidget", "Error reading siren state", e)
                // Устанавливаем значения по умолчанию
                views.setTextViewText(R.id.btn_siren, "▶ Включить\nсирену")
                views.setTextViewText(R.id.widget_title, "Сирена тревоги")
            }

            // Настройка действия при нажатии - используем BroadcastReceiver вместо Activity
            try {
                val toggleIntent = Intent(context, SirenToggleReceiver::class.java).apply {
                    action = SirenToggleReceiver.ACTION_TOGGLE_SIREN
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    0,
                    toggleIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.btn_siren, pendingIntent)
            } catch (e: Exception) {
                android.util.Log.e("SirenWidget", "Error setting click pending intent", e)
            }

            // Обновление виджета
            try {
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                android.util.Log.e("SirenWidget", "Error updating widget", e)
            }
        } catch (e: Exception) {
            android.util.Log.e("SirenWidget", "Critical error in updateAppWidget", e)
        }
    }

    companion object {
        const val ACTION_TOGGLE_SIREN = "kz.earthquake.helper.widgets.TOGGLE_SIREN"
    }
}


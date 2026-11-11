package kz.earthquake.helper.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import kz.earthquake.helper.R

class EmergencyContactsWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
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
        val views = RemoteViews(context.packageName, R.layout.widget_emergency_contacts)

        // Настройка кнопок для звонков
        setupCallButton(context, views, R.id.btn_mchs, "101")
        setupCallButton(context, views, R.id.btn_police, "102")
        setupCallButton(context, views, R.id.btn_ambulance, "103")
        setupCallButton(context, views, R.id.btn_gas, "104")
        setupCallButton(context, views, R.id.btn_emergency, "112")

        // Обновление виджета
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun setupCallButton(
        context: Context,
        views: RemoteViews,
        buttonId: Int,
        phoneNumber: String
    ) {
        // Используем ACTION_DIAL вместо ACTION_CALL - не требует разрешений
        val intent = Intent(Intent.ACTION_DIAL).apply {
            data = Uri.parse("tel:$phoneNumber")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            phoneNumber.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(buttonId, pendingIntent)
    }
}


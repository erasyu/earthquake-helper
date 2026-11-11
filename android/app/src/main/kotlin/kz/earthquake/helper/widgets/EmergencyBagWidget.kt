package kz.earthquake.helper.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import kz.earthquake.helper.R
import kz.earthquake.helper.MainActivity

class EmergencyBagWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        try {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, EmergencyBagWidget::class.java)
            )

            if (appWidgetIds.isEmpty()) {
                return
            }

            if (intent.hasExtra("item_id")) {
                val itemId = intent.getStringExtra("item_id")
                if (itemId.isNullOrEmpty()) {
                    return
                }

                try {
                    val prefs = context.getSharedPreferences(
                        "FlutterSharedPreferences",
                        Context.MODE_PRIVATE
                    )
                    val key = EmergencyBagRemoteViewsFactory.prefsKey(itemId)
                    val currentState = prefs.getBoolean(key, false)
                    prefs.edit().putBoolean(key, !currentState).apply()

                    updateCounters(context, prefs)

                    for (appWidgetId in appWidgetIds) {
                        updateAppWidget(context, appWidgetManager, appWidgetId)
                    }

                    appWidgetManager.notifyAppWidgetViewDataChanged(
                        appWidgetIds,
                        R.id.bag_list
                    )
                } catch (e: Exception) {
                    android.util.Log.e("EmergencyBagWidget", "Error handling item click", e)
                }
            } else if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
                for (appWidgetId in appWidgetIds) {
                    updateAppWidget(context, appWidgetManager, appWidgetId)
                }
                appWidgetManager.notifyAppWidgetViewDataChanged(
                    appWidgetIds,
                    R.id.bag_list
                )
            }
        } catch (e: Exception) {
            android.util.Log.e("EmergencyBagWidget", "Error in onReceive", e)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            val views = RemoteViews(context.packageName, R.layout.widget_emergency_bag)
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            )

            val itemsCount = EmergencyBagRemoteViewsFactory.itemIds.size
            val checkedCount = getCheckedCount(prefs)

            views.setTextViewText(
                R.id.widget_title,
                "Тревожный чемодан ($checkedCount/$itemsCount)"
            )

            val serviceIntent = Intent(context, EmergencyBagRemoteViewsService::class.java)
            views.setRemoteAdapter(R.id.bag_list, serviceIntent)

            val clickIntent = Intent(context, EmergencyBagWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val clickPendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                clickIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setPendingIntentTemplate(R.id.bag_list, clickPendingIntent)

            val appIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val appPendingIntent = PendingIntent.getActivity(
                context,
                0,
                appIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, appPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            android.util.Log.e("EmergencyBagWidget", "Error updating widget: ${e.message}")
        }
    }

    private fun getCheckedCount(prefs: SharedPreferences): Int {
        var count = 0
        for (itemId in EmergencyBagRemoteViewsFactory.itemIds) {
            if (prefs.getBoolean(EmergencyBagRemoteViewsFactory.prefsKey(itemId), false)) {
                count++
            }
        }
        return count
    }

    private fun updateCounters(context: Context, prefs: SharedPreferences) {
        val checkedCount = getCheckedCount(prefs)
        prefs.edit()
            .putInt("flutter.emergency_bag_items_count", EmergencyBagRemoteViewsFactory.itemIds.size)
            .putInt("flutter.emergency_bag_checked_count", checkedCount)
            .apply()
    }
}

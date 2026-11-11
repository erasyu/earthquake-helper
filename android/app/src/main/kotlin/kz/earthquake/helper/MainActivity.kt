package kz.earthquake.helper

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kz.earthquake.helper.R

class MainActivity: FlutterActivity() {
    private val SIREN_CHANNEL = "kz.earthquake.helper/siren"
    private val WIDGET_CHANNEL = "kz.earthquake.helper/widgets"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Канал для управления сиреной
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SIREN_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "toggleSiren" -> {
                    val state = call.argument<String>("state") ?: "stopped"
                    // Состояние уже сохранено в SharedPreferences виджетом
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        
        // Канал для обновления виджетов
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateEmergencyBagWidget" -> {
                    updateEmergencyBagWidget()
                    result.success(null)
                }
                "updateSirenWidget" -> {
                    updateSirenWidget()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun updateEmergencyBagWidget() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val componentName = android.content.ComponentName(this, kz.earthquake.helper.widgets.EmergencyBagWidget::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
        
        if (appWidgetIds.isNotEmpty()) {
            // Обновляем виджет
            val intent = Intent(this, kz.earthquake.helper.widgets.EmergencyBagWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
            }
            sendBroadcast(intent)
            
            // Уведомляем RemoteViewsService об изменении данных
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.bag_list)
        }
    }
    
    private fun updateSirenWidget() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val componentName = android.content.ComponentName(this, kz.earthquake.helper.widgets.SirenWidget::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
        
        if (appWidgetIds.isNotEmpty()) {
            // Обновляем виджет
            val intent = Intent(this, kz.earthquake.helper.widgets.SirenWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
            }
            sendBroadcast(intent)
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        try {
            when (intent?.action) {
                "kz.earthquake.helper.TOGGLE_SIREN" -> {
                    // Этот intent теперь обрабатывается через SirenToggleReceiver
                    // Оставляем для совместимости, но не выполняем действий
                    android.util.Log.d("MainActivity", "Received TOGGLE_SIREN intent, but handling via BroadcastReceiver")
                }
                "kz.earthquake.helper.START_SIREN_FROM_WIDGET" -> {
                    // Запуск сирены из виджета на Android 12+ (обход ограничений)
                    android.util.Log.d("MainActivity", "Starting siren from widget via Activity")
                    startSirenFromWidget()
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error handling intent", e)
        }
    }
    
    private fun startSirenFromWidget() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            val shouldStart = prefs.getBoolean("start_siren_from_widget", false)
            
            if (shouldStart) {
                // Очищаем флаг
                prefs.edit().putBoolean("start_siren_from_widget", false).apply()
                
                // Запускаем сервис из Activity (это разрешено на Android 12+)
                val startIntent = Intent(this, kz.earthquake.helper.services.SirenService::class.java)
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    startForegroundService(startIntent)
                } else {
                    startService(startIntent)
                }
                
                android.util.Log.d("MainActivity", "Siren service started from Activity")
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error starting siren from widget", e)
        }
    }
}


package kz.earthquake.helper.widgets

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import kz.earthquake.helper.services.SirenService

class SirenToggleReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SirenToggleReceiver"
        const val ACTION_TOGGLE_SIREN = "kz.earthquake.helper.TOGGLE_SIREN"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_TOGGLE_SIREN) {
            return
        }
        
        // Используем goAsync() для продления жизни BroadcastReceiver
        // Это критически важно для Android 12+ и предотвращает краши
        val pendingResult = goAsync()
        
        try {
            Log.d(TAG, "Received TOGGLE_SIREN action")
            
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val currentState = prefs.getString("flutter.siren_state", "stopped") ?: "stopped"
            val isPlaying = currentState == "playing"
            
            Log.d(TAG, "Current siren state: $currentState, isPlaying: $isPlaying")
            
            if (isPlaying) {
                // Останавливаем сирену
                stopSiren(context, prefs, pendingResult)
            } else {
                // Запускаем сирену
                startSiren(context, prefs, pendingResult)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Critical error in onReceive", e)
            pendingResult.finish()
        }
    }
    
    private fun stopSiren(context: Context, prefs: android.content.SharedPreferences, pendingResult: PendingResult) {
        try {
            Log.d(TAG, "Stopping siren service")
            
            val stopIntent = Intent(context, SirenService::class.java).apply {
                action = SirenService.ACTION_STOP_SIREN
            }
            
            try {
                // Для остановки можно использовать обычный startService
                context.startService(stopIntent)
                Log.d(TAG, "Stop service intent sent successfully")
            } catch (e: IllegalStateException) {
                Log.e(TAG, "IllegalStateException when stopping service (Android 12+ restriction)", e)
                // На Android 12+ может быть ограничение, но для остановки это обычно работает
            } catch (e: Exception) {
                Log.e(TAG, "Error stopping siren service", e)
            }
            
            // Обновляем состояние в SharedPreferences
            prefs.edit()
                .putString("flutter.siren_state", "stopped")
                .putBoolean("siren_playing", false)
                .apply()
            
            // Обновляем виджет
            updateSirenWidget(context)
            
            Log.d(TAG, "Siren stop completed")
        } catch (e: Exception) {
            Log.e(TAG, "Error in stopSiren", e)
        } finally {
            pendingResult.finish()
        }
    }
    
    private fun startSiren(context: Context, prefs: android.content.SharedPreferences, pendingResult: PendingResult) {
        try {
            Log.d(TAG, "Starting siren service")
            
            val startIntent = Intent(context, SirenService::class.java)
            
            try {
                // Для Android 12+ (API 31+) используем ContextCompat.startForegroundService
                // который лучше обрабатывает ограничения
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        // Android 12+ - используем ContextCompat для лучшей совместимости
                        try {
                            ContextCompat.startForegroundService(context, startIntent)
                            Log.d(TAG, "ForegroundService started via ContextCompat (Android 12+)")
                        } catch (e: IllegalStateException) {
                            Log.e(TAG, "Cannot start ForegroundService from background (Android 12+)", e)
                            // На Android 12+ BroadcastReceiver не может запускать ForegroundService
                            // Используем альтернативный подход - запуск через Activity
                            startSirenViaActivity(context, prefs)
                            pendingResult.finish()
                            return
                        }
                    } else {
                        // Android 8-11
                        context.startForegroundService(startIntent)
                        Log.d(TAG, "ForegroundService started via startForegroundService")
                    }
                } else {
                    // Android 7 и ниже
                    context.startService(startIntent)
                    Log.d(TAG, "Service started via startService")
                }
                
                // Обновляем состояние в SharedPreferences после успешного запуска
                prefs.edit()
                    .putString("flutter.siren_state", "playing")
                    .putBoolean("siren_playing", true)
                    .apply()
                
                Log.d(TAG, "Siren start completed")
            } catch (e: IllegalStateException) {
                Log.e(TAG, "IllegalStateException when starting service (Android 12+ restriction)", e)
                // На Android 12+ BroadcastReceiver не может запускать ForegroundService
                // Используем альтернативный подход
                startSirenViaActivity(context, prefs)
            } catch (e: Exception) {
                Log.e(TAG, "Error starting siren service", e)
                // В случае ошибки сбрасываем состояние
                prefs.edit()
                    .putString("flutter.siren_state", "stopped")
                    .putBoolean("siren_playing", false)
                    .apply()
            }
            
            // Обновляем виджет
            updateSirenWidget(context)
        } catch (e: Exception) {
            Log.e(TAG, "Error in startSiren", e)
        } finally {
            pendingResult.finish()
        }
    }
    
    private fun startSirenViaActivity(context: Context, prefs: android.content.SharedPreferences) {
        try {
            Log.d(TAG, "Attempting to start siren via Activity (Android 12+ workaround)")
            
            // Запускаем MainActivity с флагом для запуска сервиса
            val activityIntent = Intent(context, kz.earthquake.helper.MainActivity::class.java).apply {
                action = "kz.earthquake.helper.START_SIREN_FROM_WIDGET"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            
            try {
                context.startActivity(activityIntent)
                
                // Сохраняем флаг для MainActivity
                prefs.edit()
                    .putBoolean("start_siren_from_widget", true)
                    .putString("flutter.siren_state", "playing")
                    .putBoolean("siren_playing", true)
                    .apply()
                
                Log.d(TAG, "Activity started for siren launch")
            } catch (e: Exception) {
                Log.e(TAG, "Error starting Activity for siren", e)
                // В случае ошибки сбрасываем состояние
                prefs.edit()
                    .putString("flutter.siren_state", "stopped")
                    .putBoolean("siren_playing", false)
                    .putBoolean("start_siren_from_widget", false)
                    .apply()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in startSirenViaActivity", e)
        }
    }
    
    private fun updateSirenWidget(context: Context) {
        try {
            val appWidgetManager = android.appwidget.AppWidgetManager.getInstance(context)
            val componentName = android.content.ComponentName(context, SirenWidget::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            if (appWidgetIds.isNotEmpty()) {
                try {
                    val intent = Intent(context, SirenWidget::class.java).apply {
                        action = android.appwidget.AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        putExtra(android.appwidget.AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                    }
                    context.sendBroadcast(intent)
                    Log.d(TAG, "Siren widget update broadcast sent for ${appWidgetIds.size} widgets")
                } catch (e: Exception) {
                    Log.e(TAG, "Error sending widget update broadcast", e)
                }
            } else {
                Log.d(TAG, "No siren widgets to update")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error updating siren widget", e)
        }
    }
}


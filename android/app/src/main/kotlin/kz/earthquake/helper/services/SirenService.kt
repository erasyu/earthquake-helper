package kz.earthquake.helper.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import kz.earthquake.helper.MainActivity
import kz.earthquake.helper.R
import java.io.IOException

class SirenService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private val binder = LocalBinder()
    private var isPlaying: Boolean = false
    
    companion object {
        private const val TAG = "SirenService"
        private const val CHANNEL_ID = "siren_service_channel"
        private const val NOTIFICATION_ID = 1
        const val ACTION_STOP_SIREN = "kz.earthquake.helper.STOP_SIREN"
    }
    
    inner class LocalBinder : Binder() {
        fun getService(): SirenService = this@SirenService
    }
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try {
            when (intent?.action) {
                ACTION_STOP_SIREN -> {
                    Log.d(TAG, "Received STOP_SIREN action")
                    stopSiren()
                    stopForeground(true)
                    stopSelf()
                    return START_NOT_STICKY
                }
                else -> {
                    if (!isPlaying) {
                        Log.d(TAG, "Starting siren service")
                        startSiren()
                    } else {
                        Log.d(TAG, "Siren already playing, skipping start")
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in onStartCommand", e)
            stopSelf()
            return START_NOT_STICKY
        }
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder {
        return binder
    }
    
    private fun createNotificationChannel() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    getString(R.string.siren_notification_channel_name),
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = getString(R.string.siren_notification_channel_description)
                    setSound(null, null)
                    enableVibration(false)
                }
                val notificationManager = getSystemService(NotificationManager::class.java)
                notificationManager?.createNotificationChannel(channel)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error creating notification channel", e)
        }
    }
    
    private fun startSiren() {
        try {
            // Сначала создаем уведомление ДО запуска MediaPlayer
            // Это критически важно для ForegroundService
            startForeground(NOTIFICATION_ID, createNotification())
            
            if (mediaPlayer != null) {
                try {
                    if (mediaPlayer!!.isPlaying) {
                        mediaPlayer!!.stop()
                    }
                    mediaPlayer!!.release()
                } catch (e: Exception) {
                    Log.e(TAG, "Error releasing old MediaPlayer", e)
                }
                mediaPlayer = null
            }
            
            // Используем raw ресурсы Android вместо Flutter assets
            val createdPlayer = MediaPlayer.create(this, R.raw.siren)
            
            if (createdPlayer == null) {
                Log.e(TAG, "Failed to create MediaPlayer from raw resource - MediaPlayer.create() returned null")
                stopForeground(true)
                stopSelf()
                return
            }
            
            mediaPlayer = createdPlayer.apply {
                try {
                    isLooping = true
                    
                    setOnErrorListener { _, what, extra ->
                        Log.e(TAG, "MediaPlayer error: what=$what, extra=$extra")
                        try {
                            this@SirenService.stopSiren()
                        } catch (e: Exception) {
                            Log.e(TAG, "Error in MediaPlayer error listener", e)
                        }
                        true
                    }
                    
                    setOnCompletionListener {
                        if (this@SirenService.isPlaying) {
                            // Если по какой-то причине зацикливание не сработало, перезапускаем
                            try {
                                if (!isPlaying) {
                                    start()
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error restarting siren in completion listener", e)
                                try {
                                    this@SirenService.stopSiren()
                                } catch (e2: Exception) {
                                    Log.e(TAG, "Error stopping siren in completion listener", e2)
                                }
                            }
                        }
                    }
                    
                    // Запускаем воспроизведение
                    start()
                    this@SirenService.isPlaying = true
                    
                    // Обновляем состояние в SharedPreferences
                    val prefs = this@SirenService.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    prefs.edit()
                        .putString("flutter.siren_state", "playing")
                        .putBoolean("siren_playing", true)
                        .apply()
                    
                    // Обновляем виджет
                    this@SirenService.updateSirenWidget()
                    
                    Log.d(TAG, "Siren started successfully")
                } catch (e: Exception) {
                    Log.e(TAG, "Error configuring MediaPlayer", e)
                    try {
                        release()
                    } catch (e2: Exception) {
                        Log.e(TAG, "Error releasing MediaPlayer after error", e2)
                    }
                    this@SirenService.mediaPlayer = null
                    this@SirenService.stopForeground(true)
                    this@SirenService.stopSelf()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting siren", e)
            stopSelf()
        }
    }
    
    private fun stopSiren() {
        try {
            Log.d(TAG, "Stopping siren")
            
            mediaPlayer?.let { player ->
                try {
                    if (player.isPlaying) {
                        player.stop()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error stopping MediaPlayer", e)
                }
                try {
                    player.release()
                } catch (e: Exception) {
                    Log.e(TAG, "Error releasing MediaPlayer", e)
                }
            }
            mediaPlayer = null
            isPlaying = false
            
            // Обновляем состояние в SharedPreferences
            try {
                val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                prefs.edit()
                    .putString("flutter.siren_state", "stopped")
                    .putBoolean("siren_playing", false)
                    .apply()
            } catch (e: Exception) {
                Log.e(TAG, "Error updating SharedPreferences", e)
            }
            
            // Обновляем виджет
            updateSirenWidget()
            
            Log.d(TAG, "Siren stopped successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping siren", e)
        }
    }
    
    private fun createNotification(): Notification {
        try {
            val stopIntent = Intent(this, SirenService::class.java).apply {
                action = ACTION_STOP_SIREN
            }
            val stopPendingIntent = PendingIntent.getService(
                this,
                0,
                stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            val openAppIntent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openAppPendingIntent = PendingIntent.getActivity(
                this,
                0,
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            return NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle(getString(R.string.siren_notification_title))
                .setContentText(getString(R.string.siren_notification_text))
                .setSmallIcon(R.drawable.ic_siren_notification)
                .setOngoing(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .addAction(
                    R.drawable.ic_siren_notification,
                    getString(R.string.siren_notification_stop),
                    stopPendingIntent
                )
                .setContentIntent(openAppPendingIntent)
                .build()
        } catch (e: Exception) {
            Log.e(TAG, "Error creating notification", e)
            // Возвращаем базовое уведомление в случае ошибки
            return NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Сирена активна")
                .setContentText("Нажмите, чтобы остановить")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setOngoing(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build()
        }
    }
    
    private fun updateSirenWidget() {
        try {
            val intent = Intent(this, kz.earthquake.helper.widgets.SirenWidget::class.java).apply {
                action = android.appwidget.AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            sendBroadcast(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error updating siren widget", e)
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "SirenService destroyed")
        try {
            stopSiren()
        } catch (e: Exception) {
            Log.e(TAG, "Error in onDestroy", e)
        }
    }
}


import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, debugPrint;
import 'package:flutter/material.dart' show TargetPlatform;
import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'earthquake_service.dart';
import 'notification_service.dart';

const int earthquakeCheckTaskId = 0;
const int realtimeUpdateTaskId = 1;
const double notificationRadiusKm = 1000.0;

double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double p = 0.017453292519943295;
  final double a = 0.5 -
      math.cos((lat2 - lat1) * p) / 2 +
      math.cos(lat1 * p) *
          math.cos(lat2 * p) *
          (1 - math.cos((lon2 - lon1) * p)) /
          2;
  return 12742 * math.asin(math.sqrt(a));
}

bool _isWithinRadius(Earthquake eq, double? userLat, double? userLon) {
  if (userLat == null || userLon == null) {
    return false;
  }
  final distance = _calculateDistance(
    userLat,
    userLon,
    eq.latitude,
    eq.longitude,
  );
  return distance <= notificationRadiusKm;
}

@pragma('vm:entry-point')
Future<void> realtimeEarthquakeCheck() async {
  await _checkRealtimeEarthquakes();
}

@pragma('vm:entry-point')
Future<void> regularEarthquakeCheck() async {
  await _checkForEarthquakes();
}

Future<void> _checkRealtimeEarthquakes() async {
  try {
    DartPluginRegistrant.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final earthquakeService = EarthquakeService(prefs);
    final notificationService = NotificationService();
    final earthquakes = await earthquakeService.getRealtimeEarthquakes();

    if (earthquakes.isNotEmpty) {
      debugPrint(
          'Найдены землетрясения в режиме реального времени: ${earthquakes.length}');
      
      final minMagnitude = prefs.getDouble('min_notify_magnitude') ?? 4.0;
      final lastKnownIds = prefs.getStringList('last_known_earthquake_ids') ?? [];
      final userLat = prefs.getDouble('user_latitude');
      final userLon = prefs.getDouble('user_longitude');
      final newEarthquakes = <Earthquake>[];
      final currentIds = <String>[];

      for (final eq in earthquakes) {
        final eqId = '${eq.time.millisecondsSinceEpoch}_${eq.latitude}_${eq.longitude}';
        currentIds.add(eqId);
        
        final isNew = !lastKnownIds.contains(eqId);
        final hasMinMagnitude = eq.magnitude >= minMagnitude;
        final isWithinRadius = _isWithinRadius(eq, userLat, userLon);
        
        if (isNew && hasMinMagnitude && isWithinRadius) {
          newEarthquakes.add(eq);
        }
      }

      if (newEarthquakes.isNotEmpty) {
        newEarthquakes.sort((a, b) => b.magnitude.compareTo(a.magnitude));
        
        for (final eq in newEarthquakes) {
          await notificationService.showEarthquakeNotification(
            magnitude: eq.magnitude,
            place: eq.place,
            time: eq.time,
          );
        }
        
        await prefs.setStringList('last_known_earthquake_ids', currentIds);
        debugPrint('Отправлено уведомлений о новых землетрясениях: ${newEarthquakes.length}');
      } else {
        await prefs.setStringList('last_known_earthquake_ids', currentIds);
      }
    }
  } catch (e) {
    debugPrint('Ошибка при проверке землетрясений в реальном времени: $e');
  }
}

Future<void> _checkForEarthquakes() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final earthquakeService = EarthquakeService(prefs);
    final notificationService = NotificationService();
    final earthquakes = await earthquakeService.getRecentEarthquakes();

    if (earthquakes.isNotEmpty) {
      debugPrint('Найдены землетрясения: ${earthquakes.length}');
      earthquakes.sort((a, b) => b.magnitude.compareTo(a.magnitude));
      final strongestEarthquake = earthquakes.first;

      await notificationService.showEarthquakeNotification(
        magnitude: strongestEarthquake.magnitude,
        place: strongestEarthquake.place,
        time: strongestEarthquake.time,
      );
    } else {
      debugPrint('Землетрясений не обнаружено');
    }
  } catch (e) {
    debugPrint('Ошибка при проверке землетрясений: $e');
  }
}

class BackgroundService {
  bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize() async {
    try {
      if (!isSupported) {
        debugPrint('Фоновые задачи не поддерживаются на этой платформе');
        return;
      }

      await AndroidAlarmManager.initialize();

      final prefs = await SharedPreferences.getInstance();
      await _registerRealtimeTask(prefs);

      debugPrint('Сервис фоновых задач инициализирован (автоматический режим)');
    } catch (e) {
      debugPrint('Ошибка при инициализации фоновых задач: $e');
    }
  }

  Future<void> _registerRealtimeTask(SharedPreferences prefs) async {
    try {
      final updateFrequency = prefs.getInt('update_frequency_minutes') ?? 5;
      await AndroidAlarmManager.cancel(realtimeUpdateTaskId);
      await AndroidAlarmManager.periodic(
        Duration(minutes: updateFrequency),
        realtimeUpdateTaskId,
        realtimeEarthquakeCheck,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      debugPrint(
          'Автоматическая проверка землетрясений активирована. Интервал: $updateFrequency минут');
    } catch (e) {
      debugPrint('Ошибка при регистрации задачи в реальном времени: $e');
    }
  }

  Future<void> updateSettings(SharedPreferences prefs) async {
    try {
      if (!isSupported) return;
      await _registerRealtimeTask(prefs);
    } catch (e) {
      debugPrint('Ошибка при обновлении настроек фоновых задач: $e');
    }
  }

  Future<void> cancelAllTasks() async {
    try {
      if (!isSupported) {
        debugPrint('Фоновые задачи не поддерживаются на этой платформе');
        return;
      }

      await AndroidAlarmManager.cancel(realtimeUpdateTaskId);
      await AndroidAlarmManager.cancel(earthquakeCheckTaskId);
      debugPrint('Отмена задач выполнена');
    } catch (e) {
      debugPrint('Ошибка при отмене подписок: $e');
    }
  }
}

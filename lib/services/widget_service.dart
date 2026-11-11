import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart';
import '../data/emergency_kit_items.dart';

class WidgetService {
  static const String _sirenStateKey = 'flutter.siren_state';
  static const String _emergencyBagItemsCountKey = 'flutter.emergency_bag_items_count';
  static const String _emergencyBagCheckedCountKey = 'flutter.emergency_bag_checked_count';

  /// Инициализация виджетов
  static Future<void> initialize() async {
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
        return;
      }
      // Для Android виджеты используют SharedPreferences напрямую
      // Инициализация не требуется
    } catch (e) {
      // Игнорируем ошибки инициализации на платформах без поддержки виджетов
    }
  }

  /// Обновление состояния сирены в виджете
  static Future<void> updateSirenState(bool isPlaying) async {
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sirenStateKey, isPlaying ? 'playing' : 'stopped');
      await prefs.setBool('siren_playing', isPlaying);
      
      // Отправляем broadcast для обновления виджета через platform channel
      // Виджет также обновляется автоматически через SirenService и SirenToggleReceiver
      try {
        const platform = MethodChannel('kz.earthquake.helper/widgets');
        await platform.invokeMethod('updateSirenWidget');
      } catch (e) {
        // Игнорируем ошибки, если platform channel не настроен
        // Виджет все равно обновится через broadcast от сервиса
      }
    } catch (e) {
      // Игнорируем ошибки обновления виджетов
    }
  }

  /// Обновление данных тревожного чемодана в виджете
  static Future<void> updateEmergencyBagItems() async {
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      
      int checkedCount = 0;

      for (final id in emergencyKitItemIds) {
        if (prefs.getBool(emergencyKitPrefsKey(id)) ?? false) {
          checkedCount++;
        }
      }

      await prefs.setInt(_emergencyBagItemsCountKey, emergencyKitItemIds.length);
      await prefs.setInt(_emergencyBagCheckedCountKey, checkedCount);
      
      // Обновляем виджет через platform channel
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          const platform = MethodChannel('kz.earthquake.helper/widgets');
          await platform.invokeMethod('updateEmergencyBagWidget');
        } catch (e) {
          // Игнорируем ошибки, если platform channel не настроен
        }
      }
    } catch (e) {
      // Игнорируем ошибки обновления виджетов
    }
  }

  /// Обновление всех виджетов
  static Future<void> updateAllWidgets() async {
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
        return;
      }
      // Обновляем состояние сирены
      final prefs = await SharedPreferences.getInstance();
      final sirenState = prefs.getBool('siren_playing') ?? false;
      await updateSirenState(sirenState);

      // Обновляем данные тревожного чемодана
      await updateEmergencyBagItems();
    } catch (e) {
      // Игнорируем ошибки
    }
  }
}


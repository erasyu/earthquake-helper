import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();

  factory OfflineManager() {
    return _instance;
  }

  OfflineManager._internal();

  bool _offlineMode = false;
  final StreamController<bool> _offlineModeController =
      StreamController<bool>.broadcast();

  bool get isOfflineMode => _offlineMode;
  Stream<bool> get offlineModeStream => _offlineModeController.stream;

  Future<void> initialize() async {
    await _loadSavedMode();
    await checkConnectivity();
  }

  Future<bool> checkConnectivity() async {
    try {
      if (kIsWeb) {
        return true;
      }
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      bool hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (!_offlineMode) {
        setOfflineMode(!hasConnection);
      }
      return hasConnection;
    } catch (e) {
      if (!_offlineMode) {
        setOfflineMode(true);
      }
      return false;
    }
  }

  Future<void> setOfflineMode(bool value) async {
    if (_offlineMode != value) {
      _offlineMode = value;
      _offlineModeController.add(_offlineMode);
      await _saveMode();
    }
  }

  Future<void> toggleOfflineMode() async {
    await setOfflineMode(!_offlineMode);
  }

  Future<void> _loadSavedMode() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _offlineMode = prefs.getBool('offlineMode') ?? false;
      _offlineModeController.add(_offlineMode);
    } catch (e) {
      _offlineMode = false;
      _offlineModeController.add(_offlineMode);
    }
  }

  Future<void> _saveMode() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('offlineMode', _offlineMode);
    } catch (e) {
      debugPrint('Ошибка при сохранении режима офлайн: $e');
    }
  }

  void dispose() {
    _offlineModeController.close();
  }
}

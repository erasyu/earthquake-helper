import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/earthquake_service.dart';
import '../services/background_service.dart';

class SettingsScreen extends StatefulWidget {
  final EarthquakeService earthquakeService;
  final SharedPreferences prefs;
  final Future<void> Function(Locale locale)? onLocaleChanged;

  const SettingsScreen({
    super.key,
    required this.earthquakeService,
    required this.prefs,
    this.onLocaleChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _updateFrequency = 5;
  bool _notificationsEnabled = true;
  double _minNotifyMagnitude = 4.0;
  String _localeCode = 'ru';
  final BackgroundService _backgroundService = BackgroundService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _updateFrequency = widget.prefs.getInt('update_frequency_minutes') ?? 5;
      _notificationsEnabled =
          widget.prefs.getBool('notifications_enabled') ?? true;
      _minNotifyMagnitude =
          widget.prefs.getDouble('min_notify_magnitude') ?? 4.0;
      _localeCode = widget.prefs.getString('app_locale') ?? 'ru';
    });
  }

  Future<void> _saveSettings() async {
    await widget.prefs.setInt('update_frequency_minutes', _updateFrequency);
    await widget.prefs.setBool('notifications_enabled', _notificationsEnabled);
    await widget.prefs.setDouble('min_notify_magnitude', _minNotifyMagnitude);
    await _backgroundService.updateSettings(widget.prefs);
  }

  Future<void> _changeLocale(String code) async {
    setState(() => _localeCode = code);
    await widget.prefs.setString('app_locale', code);
    await widget.onLocaleChanged?.call(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language, color: Colors.orange[700], size: 24),
                        const SizedBox(width: 12),
                        Text(
                          l10n.language,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _LanguageTile(
                      title: l10n.languageKk,
                      value: 'kk',
                      groupValue: _localeCode,
                      onChanged: _changeLocale,
                    ),
                    _LanguageTile(
                      title: l10n.languageRu,
                      value: 'ru',
                      groupValue: _localeCode,
                      onChanged: _changeLocale,
                    ),
                    _LanguageTile(
                      title: l10n.languageEn,
                      value: 'en',
                      groupValue: _localeCode,
                      onChanged: _changeLocale,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sync, color: Colors.orange[700], size: 24),
                        const SizedBox(width: 12),
                        Text(
                          l10n.dataUpdate,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.autoUpdates,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.updateFrequency(_updateFrequency),
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Slider(
                            value: _updateFrequency.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: l10n.updateFrequencyLabel(_updateFrequency),
                            onChanged: (value) {
                              setState(() {
                                _updateFrequency = value.toInt();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications,
                            color: Colors.orange[700], size: 24),
                        const SizedBox(width: 12),
                        Text(
                          l10n.notifications,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        l10n.earthquakeNotifications,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(l10n.earthquakeNotificationsDesc),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    if (_notificationsEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.minMagnitude(_minNotifyMagnitude),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Slider(
                              value: _minNotifyMagnitude,
                              min: 2.0,
                              max: 7.0,
                              divisions: 10,
                              label: _minNotifyMagnitude.toStringAsFixed(1),
                              onChanged: (value) {
                                setState(() {
                                  _minNotifyMagnitude = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await _saveSettings();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.settingsSaved),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.saveSettings,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.blue, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          l10n.aboutDataService,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.aboutDataServiceDesc,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _LanguageTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      activeColor: Colors.orange[700],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}

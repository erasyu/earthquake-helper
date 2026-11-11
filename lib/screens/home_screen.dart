import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../services/earthquake_service.dart';
import '../services/location_service.dart';
import 'earthquake_history_screen.dart';
import 'emergency_contacts_screen.dart';
import 'emergency_kit_screen.dart';
import 'evacuation_map_screen.dart';
import 'first_aid_screen.dart';
import 'earthquake_safety_screen.dart';
import 'settings_screen.dart';
import '../siren.dart';

class HomeScreen extends StatefulWidget {
  final EarthquakeService earthquakeService;
  final Future<void> Function(Locale locale)? onLocaleChanged;

  const HomeScreen({
    super.key,
    required this.earthquakeService,
    this.onLocaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences _prefs;
  bool _initialized = false;
  Timer? _updateTimer;
  List<Earthquake> _lastKnownEarthquakes = [];

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _checkSirenIntent();
  }

  Future<void> _checkSirenIntent() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final startSirenFromWidget =
          prefs.getBool('start_siren_from_widget') ?? false;
      if (startSirenFromWidget) {
        await prefs.setBool('start_siren_from_widget', false);
        debugPrint('Siren started from widget');
        return;
      }

      final sirenAction = prefs.getString('siren_widget_action');
      if (sirenAction == 'toggle' && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EmergencySiren()),
        );
        await prefs.remove('siren_widget_action');
      }
    } catch (e) {
      debugPrint('Error checking siren intent: $e');
    }
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    final locationService = LocationService();
    try {
      await locationService.initialize();
      final position = await locationService.getCurrentPosition();
      await _prefs.setDouble('user_latitude', position.latitude);
      await _prefs.setDouble('user_longitude', position.longitude);
    } catch (e) {
      debugPrint('Location error: $e');
    }

    widget.earthquakeService.startBackgroundUpdates((earthquakes) {
      _checkForNewEarthquakesInApp(earthquakes);
    });

    _startPeriodicUpdates();

    setState(() {
      _initialized = true;
    });
  }

  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    final updateFrequency = _prefs.getInt('update_frequency_minutes') ?? 5;

    _updateTimer = Timer.periodic(Duration(minutes: updateFrequency), (timer) async {
      if (!mounted) return;
      try {
        final earthquakes =
            await widget.earthquakeService.getRealtimeEarthquakes();
        _checkForNewEarthquakesInApp(earthquakes);
      } catch (e) {
        debugPrint('Periodic check error: $e');
      }
    });

    Future.delayed(const Duration(seconds: 10), () async {
      if (!mounted) return;
      try {
        final earthquakes =
            await widget.earthquakeService.getRealtimeEarthquakes();
        _checkForNewEarthquakesInApp(earthquakes);
      } catch (e) {
        debugPrint('Initial check error: $e');
      }
    });
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
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
    if (userLat == null || userLon == null) return false;
    const double notificationRadiusKm = 1000.0;
    final distance = _calculateDistance(
      userLat,
      userLon,
      eq.latitude,
      eq.longitude,
    );
    return distance <= notificationRadiusKm;
  }

  void _checkForNewEarthquakesInApp(List<Earthquake> earthquakes) {
    if (!mounted) return;

    final minMagnitude = _prefs.getDouble('min_notify_magnitude') ?? 4.0;
    final userLat = _prefs.getDouble('user_latitude');
    final userLon = _prefs.getDouble('user_longitude');
    final l10n = context.l10n;

    final newEarthquakes = earthquakes.where((eq) {
      final eqId =
          '${eq.time.millisecondsSinceEpoch}_${eq.latitude}_${eq.longitude}';
      final isNew = !_lastKnownEarthquakes.any((known) =>
          '${known.time.millisecondsSinceEpoch}_${known.latitude}_${known.longitude}' ==
          eqId);
      final hasMinMagnitude = eq.magnitude >= minMagnitude;
      final isWithinRadius = _isWithinRadius(eq, userLat, userLon);
      return isNew && hasMinMagnitude && isWithinRadius;
    }).toList();

    if (newEarthquakes.isNotEmpty) {
      newEarthquakes.sort((a, b) => b.magnitude.compareTo(a.magnitude));
      final strongest = newEarthquakes.first;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.newEarthquake(strongest.magnitude),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        strongest.place,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor:
                strongest.magnitude >= 5.0 ? Colors.red : Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: l10n.moreDetails,
              textColor: Colors.white,
              onPressed: () => _showEarthquakeDetails(strongest),
            ),
          ),
        );
      }
    }

    _lastKnownEarthquakes = earthquakes;
  }

  void _showEarthquakeDetails(Earthquake earthquake) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.earthquakeTitle(earthquake.magnitude)),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.place}: ${l10n.earthquakePlace(earthquake.place)}'),
            Text(
                '${l10n.time}: ${DateFormat('dd.MM.yyyy HH:mm').format(earthquake.time)}'),
            Text('${l10n.depth}: ${earthquake.depth.toStringAsFixed(1)} ${l10n.km}'),
            Text(
                '${l10n.coordinates}: ${earthquake.latitude.toStringAsFixed(2)}, ${earthquake.longitude.toStringAsFixed(2)}'),
          ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          if (earthquake.url.isNotEmpty)
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(earthquake.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(l10n.moreDetails),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    widget.earthquakeService.stopBackgroundUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              if (!_initialized) await _initPrefs();
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      earthquakeService: widget.earthquakeService,
                      prefs: _prefs,
                      onLocaleChanged: widget.onLocaleChanged,
                    ),
                  ),
                );
              }
            },
          ),
        ],
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
            _buildMenuCard(
              l10n.menuEvacuationMap,
              l10n.menuEvacuationMapDesc,
              Icons.map,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EvacuationMapScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              l10n.menuEarthquakeHistory,
              l10n.menuEarthquakeHistoryDesc,
              Icons.history,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EarthquakeHistoryScreen(
                    earthquakeService: widget.earthquakeService,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              l10n.menuEmergencyKit,
              l10n.menuEmergencyKitDesc,
              Icons.emergency,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyKitScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              l10n.menuEmergencyContacts,
              l10n.menuEmergencyContactsDesc,
              Icons.phone,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyContactsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              l10n.menuFirstAid,
              l10n.menuFirstAidDesc,
              Icons.healing,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FirstAidScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              l10n.menuEarthquakeSafety,
              l10n.menuEarthquakeSafetyDesc,
              Icons.warning,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EarthquakeSafetyScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              l10n.menuSiren,
              l10n.menuSirenDesc,
              Icons.notifications_active,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencySiren(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: Colors.orange[700]),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

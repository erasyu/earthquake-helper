import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/earthquake_service.dart';
import '../services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EarthquakeHistoryScreen extends StatefulWidget {
  final EarthquakeService earthquakeService;

  const EarthquakeHistoryScreen({
    super.key,
    required this.earthquakeService,
  });

  @override
  State<EarthquakeHistoryScreen> createState() =>
      _EarthquakeHistoryScreenState();
}

class _EarthquakeHistoryScreenState extends State<EarthquakeHistoryScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Earthquake> _earthquakes = [];
  String _errorMessage = '';
  final LocationService _locationService = LocationService();
  LatLng? _userLocation;
  double _minMagnitude = 0.0;
  int _timeRange = 7;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final MapController _mapController = MapController();
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.repeat(reverse: true);
    _initializeServices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      await _locationService.initialize();
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      await _loadEarthquakes();
    } catch (e) {
      if (!mounted) return;
      final l10n = context.l10n;
      setState(() {
        _errorMessage = e is LocationPermissionException
            ? l10n.locationPermissionRequired
            : l10n.locationFailed;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEarthquakes({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final earthquakes = await widget.earthquakeService.getRecentEarthquakes(
        days: _timeRange,
        minMagnitude: _minMagnitude,
        globalMode: false,
        forceRefresh: forceRefresh,
      );
      setState(() {
        _earthquakes = earthquakes;
        _isLoading = false;
      });
      _animationController.reset();
      _animationController.forward();
      if (_earthquakes.isNotEmpty && _mapReady) {
        final latest = _earthquakes.first;
        _mapController.move(LatLng(latest.latitude, latest.longitude), 8.0);
      }
    } catch (e) {
      setState(() {
        _errorMessage = context.l10n.loadEarthquakesError;
        _isLoading = false;
      });
    }
  }

  Color _getColorForMagnitude(double magnitude) {
    if (magnitude >= 6.0) return Colors.red;
    if (magnitude >= 5.0) return Colors.orange;
    if (magnitude >= 4.0) return Colors.yellow;
    return Colors.green;
  }

  bool _isNearAlmaty(double latitude, double longitude) {
    const double almatyLat = 43.25;
    const double almatyLon = 76.95;
    const double almatyRadius = 2.0;
    double distanceSquared = (latitude - almatyLat) * (latitude - almatyLat) +
        (longitude - almatyLon) * (longitude - almatyLon);

    return distanceSquared <= almatyRadius * almatyRadius;
  }

  String _getPlaceDescription(Earthquake earthquake) {
    final place = context.l10n.earthquakePlace(earthquake.place);
    if (_isNearAlmaty(earthquake.latitude, earthquake.longitude)) {
      return context.l10n.nearAlmaty(place);
    }
    return place;
  }

  void _showFilterDialog() {
    double tempMinMagnitude = _minMagnitude;
    int tempTimeRange = _timeRange;

    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.filters),
          content: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.periodDays),
              Slider(
                value: tempTimeRange.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: tempTimeRange.toString(),
                onChanged: (value) {
                  setDialogState(() {
                    tempTimeRange = value.toInt();
                  });
                },
              ),
              Text(l10n.periodDaysValue(tempTimeRange)),
              const SizedBox(height: 16),
              Text(l10n.minMagnitudeFilter),
              Slider(
                value: tempMinMagnitude,
                min: 0,
                max: 7,
                divisions: 14,
                label: tempMinMagnitude.toStringAsFixed(1),
                onChanged: (value) {
                  setDialogState(() {
                    tempMinMagnitude = value;
                  });
                },
              ),
              Text(tempMinMagnitude.toStringAsFixed(1)),
            ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _minMagnitude = tempMinMagnitude;
                  _timeRange = tempTimeRange;
                });
                _loadEarthquakes(forceRefresh: true);
              },
              child: Text(l10n.apply),
            ),
          ],
        ),
      ),
    );
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
            Text('${l10n.place}: ${_getPlaceDescription(earthquake)}'),
            Text(
                '${l10n.time}: ${DateFormat('dd.MM.yyyy HH:mm').format(earthquake.time)}'),
            Text(
                '${l10n.depth}: ${earthquake.depth.toStringAsFixed(1)} ${l10n.km}'),
            Text(
                '${l10n.coordinates}: ${earthquake.latitude.toStringAsFixed(3)}°, ${earthquake.longitude.toStringAsFixed(3)}°'),
            Text('${l10n.source}: ${earthquake.source}'),
            if (earthquake.magnitude >= 5.0) ...[
              const SizedBox(height: 16),
              Text(
                l10n.dangerousEarthquake,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(l10n.dangerousEarthquakeTips),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.evacuationMapHint,
              style: const TextStyle(color: Colors.blue, fontSize: 12),
              textAlign: TextAlign.center,
            ),
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
              onPressed: () => _openEarthquakeUrl(earthquake),
              child: Text(l10n.moreDetails),
            ),
        ],
      ),
    );
  }

  Future<void> _openEarthquakeUrl(Earthquake earthquake) async {
    Navigator.pop(context);

    try {
      Uri? uriToLaunch;
      
      if (earthquake.url.isNotEmpty && 
          (earthquake.url.startsWith('http://') || earthquake.url.startsWith('https://'))) {
        try {
          uriToLaunch = Uri.parse(earthquake.url);
          if (!uriToLaunch.hasScheme || !uriToLaunch.hasAuthority) {
            uriToLaunch = null;
          }
        } catch (e) {
          debugPrint('Error parsing URL: $e');
          uriToLaunch = null;
        }
      }
      
      if (uriToLaunch == null && earthquake.source == 'USGS') {
        final dateStr = DateFormat('yyyy-MM-dd').format(earthquake.time);
        final timeStr = DateFormat('HH:mm:ss').format(earthquake.time);
        uriToLaunch = Uri.parse(
          'https://earthquake.usgs.gov/earthquakes/eventpage/'
          '?latitude=${earthquake.latitude}'
          '&longitude=${earthquake.longitude}'
          '&magnitude=${earthquake.magnitude}'
          '&date=$dateStr'
          '&time=$timeStr'
        );
      }
      
      if (uriToLaunch == null && earthquake.source == 'EMSC' && earthquake.url.isNotEmpty) {
        try {
          uriToLaunch = Uri.parse(earthquake.url);
        } catch (e) {
          debugPrint('Error parsing EMSC URL: $e');
        }
      }

      if (uriToLaunch != null) {
        try {
          if (await canLaunchUrl(uriToLaunch)) {
            await launchUrl(uriToLaunch, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.openEarthquakeInfoError),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('Error launching URL: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.openEarthquakeInfoError),
                  duration: const Duration(seconds: 3),
                ),
              );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.earthquakeInfoUnavailable),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.openInfoError}: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildAnimatedMarker(Earthquake earthquake, double animationValue) {
    final color = _getColorForMagnitude(earthquake.magnitude);
    final size =
        20.0 + (earthquake.magnitude * 3.0); // Размер зависит от магнитуды

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _showEarthquakeDetails(earthquake),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Основной маркер
              Icon(
                Icons.location_on,
                color: color,
                size: size,
              ),
              // Пульсирующий эффект для недавних или сильных землетрясений
              if (earthquake.magnitude >= 4.5 ||
                  DateTime.now().difference(earthquake.time).inHours < 24)
                Opacity(
                  opacity: (0.6 * (1 - _animation.value)).clamp(0.0, 1.0),
                  child: Container(
                    width: size * (1 + _animation.value * 0.5),
                    height: size * (1 + _animation.value * 0.5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.earthquakeHistory,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadEarthquakes(forceRefresh: true),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[700]),
                        const SizedBox(height: 16),
                        Text(
                          '${l10n.error}: $_errorMessage',
                          style: TextStyle(color: Colors.red[700], fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
              : _earthquakes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                            Icons.check_circle_outline,
                            size: 64,
                                color: Colors.green[700],
                              ),
                          ),
                            const SizedBox(height: 24),
                          Text(
                            l10n.noEarthquakesDesc(_timeRange, _minMagnitude),
                            textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          ),
                            const SizedBox(height: 12),
                            Text(
                            l10n.goodSign,
                            style: TextStyle(
                                color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                                fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _userLocation != null
                              ? Stack(
                                  children: [
                                    FlutterMap(
                                      mapController: _mapController,
                                      options: MapOptions(
                                        initialCenter: _userLocation!,
                                        initialZoom: 8.0,
                                        interactionOptions: const InteractionOptions(
                                          enableMultiFingerGestureRace: true,
                                          flags: InteractiveFlag.all,
                                        ),
                                        onMapReady: () {
                                          setState(() {
                                            _mapReady = true;
                                            // Если есть землетрясения, центрируем карту
                                            if (_earthquakes.isNotEmpty) {
                                              final latest = _earthquakes.first;
                                              _mapController.move(
                                                  LatLng(latest.latitude,
                                                      latest.longitude),
                                                  8.0);
                                            }
                                          });
                                        },
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName:
                                              'kz.earthquake.helper',
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: _userLocation!,
                                              width: 30,
                                              height: 30,
                                              child: const Icon(
                                                Icons.my_location,
                                                color: Colors.blue,
                                                size: 30,
                                              ),
                                            ),
                                            ..._earthquakes.map((earthquake) {
                                              return Marker(
                                                point: LatLng(
                                                    earthquake.latitude,
                                                    earthquake.longitude),
                                                width:
                                                    50, // Увеличиваем размер, чтобы вместить анимацию
                                                height: 50,
                                                child: _buildAnimatedMarker(
                                                    earthquake,
                                                    _animation.value),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                        // Добавляем слой круга вокруг Алматы
                                        CircleLayer(
                                          circles: [
                                            CircleMarker(
                                              point: const LatLng(43.25,
                                                  76.95), // Координаты Алматы
                                              radius: 200000, // 200 км в метрах
                                              color:
                                                  Colors.blue.withValues(alpha: 0.1),
                                              borderColor:
                                                  Colors.blue.withValues(alpha: 0.3),
                                              borderStrokeWidth: 2.0,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // Информация о зонах эвакуации
                                    Positioned(
                                      right: 16,
                                      bottom: 16,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          l10n.evacuationRoutesHint,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Text(l10n.locationFailed),
                                ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, -2), // тень сверху
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              itemCount: _earthquakes.length,
                              itemBuilder: (context, index) {
                                final earthquake = _earthquakes[index];
                                bool isRecent = DateTime.now()
                                        .difference(earthquake.time)
                                        .inHours <
                                    24;
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  elevation: isRecent ? 4.0 : 2.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _showEarthquakeDetails(earthquake);
                                      if (_mapReady) {
                                        _mapController.move(
                                            LatLng(earthquake.latitude,
                                                earthquake.longitude),
                                            9.0);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getColorForMagnitude(
                                          earthquake.magnitude),
                                      child: Text(
                                        earthquake.magnitude.toStringAsFixed(1),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                            child: Text(_getPlaceDescription(
                                                earthquake))),
                                        if (isRecent)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              l10n.newLabel,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat('dd.MM.yyyy HH:mm').format(earthquake.time),
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                      '${l10n.depth}: ${earthquake.depth.toStringAsFixed(1)} ${l10n.km}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: Icon(
                                        Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
    );
  }
}

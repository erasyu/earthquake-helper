import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../data/cities_and_zones.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';

class EvacuationMapScreen extends StatefulWidget {
  const EvacuationMapScreen({super.key});

  @override
  State<EvacuationMapScreen> createState() => _EvacuationMapScreenState();
}

class _EvacuationMapScreenState extends State<EvacuationMapScreen> {
  City? selectedCity;
  final MapController _mapController = MapController();
  bool _isLoading = true;
  late LocationService _locationService;
  LatLng? _currentLocation;
  bool _useGoogleMaps = false;

  String _cityName(BuildContext context, City city) =>
      context.l10n.cityName(city.id);

  String _zoneName(BuildContext context, SafeZone zone) =>
      context.l10n.zoneName(zone.id);

  String _zoneDescription(BuildContext context, SafeZone zone) =>
      context.l10n.zoneDescription(zone.id);

  String _zoneTypeLabel(BuildContext context, SafeZone zone) =>
      context.l10n.zoneType(zone.typeKey);

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _initializeServices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is City && selectedCity == null) {
      setState(() {
        selectedCity = args;
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);

    try {
      await _locationService.initialize();
      final position = await _locationService.getCurrentPosition();

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (_currentLocation != null) {
        _selectNearestCity();
        if (selectedCity != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _currentLocation != null) {
              _mapController.move(_currentLocation!, 13.0);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (selectedCity == null) _showCitySelectionDialog();
      }
    }
  }

  void _selectNearestCity() {
    if (_currentLocation == null || cities.isEmpty) return;

    double minDistance = double.infinity;
    City? nearestCity;

    for (final city in cities) {
      final distance = _calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        city.coordinates.latitude,
        city.coordinates.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    }

    if (nearestCity != null) {
      setState(() => selectedCity = nearestCity);
    }
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

  void _showCitySelectionDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectCity),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return ListTile(
                title: Text(_cityName(context, city)),
                subtitle: Text(l10n.zonesCount(city.safeZones.length)),
                onTap: () {
                  setState(() => selectedCity = city);
                  Navigator.pop(dialogContext);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _toggleMapType() {
    final l10n = context.l10n;
    setState(() => _useGoogleMaps = !_useGoogleMaps);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _useGoogleMaps ? l10n.switchedToGoogleMaps : l10n.switchedToOpenStreetMap,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.evacuationZones)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loadingMap),
            ],
          ),
        ),
      );
    }

    if (selectedCity == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.evacuationZones)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.locationFailed,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.chooseCity,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showCitySelectionDialog,
                icon: const Icon(Icons.location_city),
                label: Text(l10n.chooseCity),
              ),
            ],
          ),
        ),
      );
    }

    final cityName = _cityName(context, selectedCity!);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.evacuationZonesCity(cityName),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city),
            onPressed: _showCitySelectionDialog,
          ),
          IconButton(
            icon: Icon(_useGoogleMaps ? Icons.map : Icons.map_outlined),
            onPressed: _toggleMapType,
            tooltip: l10n.toggleMapType,
          ),
        ],
      ),
      body: Stack(
        children: [
          _useGoogleMaps ? _buildGoogleMapsView(cityName) : _buildOpenStreetMapView(),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'zonesList',
              onPressed: _showSafeZonesList,
              backgroundColor: Colors.orange[700],
              icon: const Icon(Icons.list, color: Colors.white),
              label: Text(
                l10n.showEvacuationZonesList,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'toggleMapType',
                  onPressed: _toggleMapType,
                  backgroundColor: Colors.white,
                  child: Icon(
                    _useGoogleMaps ? Icons.map_outlined : Icons.map,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'myLocation',
                  onPressed: () async {
                    try {
                      final position =
                          await _locationService.getCurrentPosition();
                      setState(() {
                        _currentLocation =
                            LatLng(position.latitude, position.longitude);
                      });
                      _mapController.move(_currentLocation!, 15.0);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.locationError)),
                        );
                      }
                    }
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.evacuationZonesLegend,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    l10n.tapMarkerHint,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMapsView(String cityName) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            l10n.googleMaps,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(l10n.cityLabel(cityName)),
          const SizedBox(height: 8),
          Text(l10n.zonesCount(selectedCity!.safeZones.length)),
          const SizedBox(height: 24),
          Text(
            l10n.googleMapsIntegrationHint,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showSafeZonesList,
            child: Text(l10n.showEvacuationZonesList),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenStreetMapView() {
    final centerLocation = _currentLocation ?? selectedCity!.coordinates;
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: centerLocation,
        initialZoom: 13.0,
        backgroundColor: const Color(0xFFf2f2f2),
        onMapReady: () {
          if (_currentLocation != null && mounted) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _mapController.move(_currentLocation!, 13.0);
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'kz.earthquake.helper',
          keepBuffer: 5,
          fallbackUrl: 'https://tile.openstreetmap.org/0/0/0.png',
          maxZoom: 19,
          minZoom: 2,
          retinaMode: false,
        ),
        MarkerLayer(
          markers: [
            if (_currentLocation != null)
              Marker(
                point: _currentLocation!,
                width: 30,
                height: 30,
                child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
              ),
            ...selectedCity!.safeZones.map((zone) {
              return Marker(
                point: zone.coordinates,
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _navigateToSafeZone(zone),
                  child: Icon(
                    Icons.location_on,
                    color: _getColorForZoneType(zone.typeKey),
                    size: 40,
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  void _showSafeZonesList() {
    final l10n = context.l10n;
    final cityName = _cityName(context, selectedCity!);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                l10n.evacuationZonesInCity(cityName),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedCity!.safeZones.length,
                itemBuilder: (context, index) {
                  final safeZone = selectedCity!.safeZones[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        if (safeZone.imageUrl != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.asset(
                              safeZone.imageUrl!,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 140,
                                  color: _getColorForZoneType(safeZone.typeKey),
                                  child: Center(
                                    child: Icon(
                                      _getIconForZoneType(safeZone.typeKey),
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _zoneName(context, safeZone),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getColorForZoneType(safeZone.typeKey)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _zoneTypeLabel(context, safeZone),
                                      style: TextStyle(
                                        color: _getColorForZoneType(
                                            safeZone.typeKey),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _zoneDescription(context, safeZone),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(sheetContext);
                                      if (!_useGoogleMaps) {
                                        _mapController.move(
                                            safeZone.coordinates, 15.0);
                                      }
                                    },
                                    icon: const Icon(Icons.map, size: 18),
                                    label: Text(l10n.onMap),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(sheetContext);
                                      _navigateToSafeZone(safeZone);
                                    },
                                    icon: const Icon(Icons.navigation, size: 18),
                                    label: Text(l10n.route),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  IconData _getIconForZoneType(String typeKey) {
    switch (typeKey) {
      case 'park':
        return Icons.park;
      case 'stadium':
        return Icons.sports_soccer;
      case 'school':
        return Icons.school;
      case 'hospital':
        return Icons.local_hospital;
      case 'square':
        return Icons.location_city;
      default:
        return Icons.place;
    }
  }

  Color _getColorForZoneType(String typeKey) {
    switch (typeKey) {
      case 'park':
        return Colors.green;
      case 'stadium':
        return Colors.blue;
      case 'square':
        return Colors.orange;
      case 'school':
        return Colors.amber;
      case 'hospital':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _navigateToSafeZone(SafeZone safeZone) async {
    final l10n = context.l10n;

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.navigationLocationError),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1'
          '&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}'
          '&destination=${safeZone.coordinates.latitude},${safeZone.coordinates.longitude}'
          '&travelmode=driving';

      final googleMapsUri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        return;
      }

      final yandexMapsUrl = 'yandexnavi://build_route_on_map'
          '?lat_to=${safeZone.coordinates.latitude}'
          '&lon_to=${safeZone.coordinates.longitude}';

      final yandexMapsUri = Uri.parse(yandexMapsUrl);
      if (await canLaunchUrl(yandexMapsUri)) {
        await launchUrl(yandexMapsUri, mode: LaunchMode.externalApplication);
        return;
      }

      final fallbackUrl = 'https://www.openstreetmap.org/directions'
          '?from=${_currentLocation!.latitude},${_currentLocation!.longitude}'
          '&to=${safeZone.coordinates.latitude},${safeZone.coordinates.longitude}';

      await launchUrl(
        Uri.parse(fallbackUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error launching navigation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.navigationLaunchError),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

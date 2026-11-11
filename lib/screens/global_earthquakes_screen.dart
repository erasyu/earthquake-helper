import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/earthquake_service.dart';
import '../data/cities_and_zones.dart';
import 'package:url_launcher/url_launcher.dart';
import 'evacuation_map_screen.dart';

class GlobalEarthquakesScreen extends StatefulWidget {
  final EarthquakeService earthquakeService;

  const GlobalEarthquakesScreen({
    super.key,
    required this.earthquakeService,
  });

  @override
  State<GlobalEarthquakesScreen> createState() =>
      _GlobalEarthquakesScreenState();
}

class _GlobalEarthquakesScreenState extends State<GlobalEarthquakesScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Earthquake> _earthquakes = [];
  String _errorMessage = '';
  double _minMagnitude = 4.0;
  int _timeRange = 7; // дней
  late AnimationController _animationController;
  late Animation<double> _animation;
  final MapController _mapController = MapController();
  bool _mapReady = false;
  // Всегда используем Android Earthquake Alerts

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
    _loadEarthquakes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadEarthquakes({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Загружаем реальные данные из API через сервис
      final earthquakes = await widget.earthquakeService.getRecentEarthquakes(
        days: _timeRange,
        minMagnitude: _minMagnitude,
        globalMode: true, // Глобальный режим - все землетрясения
        forceRefresh: forceRefresh,
      );

      setState(() {
        _earthquakes = earthquakes;
        _isLoading = false;
      });

      // Анимируем появление маркеров
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
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
            Text('${l10n.place}: ${l10n.earthquakePlace(earthquake.place)}'),
            Text(
                '${l10n.time}: ${DateFormat('dd.MM.yyyy HH:mm').format(earthquake.time)}'),
            Text(
                '${l10n.depth}: ${earthquake.depth.toStringAsFixed(1)} ${l10n.km}'),
            Text(
                '${l10n.coordinates}: ${earthquake.latitude.toStringAsFixed(2)}°, ${earthquake.longitude.toStringAsFixed(2)}°'),
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
            Card(
              color: Colors.blue.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n.evacuationZones,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.evacuationMapHint,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
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
              onPressed: () => _openEarthquakeUrl(earthquake.url),
              child: Text(l10n.moreDetails),
            ),
          TextButton.icon(
            icon: const Icon(Icons.map, size: 16),
            label: Text(l10n.evacuationZones),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EvacuationMapScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMarker(Earthquake earthquake, double animationValue) {
    final color = _getColorForMagnitude(earthquake.magnitude);
    final size =
        15.0 + (earthquake.magnitude * 2.5); // Размер зависит от магнитуды
    final bool isAndroidSource =
        earthquake.source == 'Android Earthquake Alerts';

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
              if (earthquake.magnitude >= 5.5 ||
                  DateTime.now().difference(earthquake.time).inHours < 24)
                Opacity(
                  opacity: 0.6 * (1 - _animation.value),
                  child: Container(
                    width: size * (1 + _animation.value * 0.5),
                    height: size * (1 + _animation.value * 0.5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              // Индикатор для маркеров из Android Earthquake Alerts
              if (isAndroidSource)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                l10n.globalEarthquakeMap,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.androidAlertsBadge,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('${l10n.error}: $_errorMessage'))
              : _earthquakes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noEarthquakesGlobalDesc(
                                _timeRange, _minMagnitude),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: const LatLng(0, 0),
                                  initialZoom: 2.0,
                                  interactionOptions: const InteractionOptions(
                                    enableMultiFingerGestureRace: true,
                                    flags: InteractiveFlag.all,
                                  ),
                                  onMapReady: () {
                                    setState(() {
                                      _mapReady = true;
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
                                    markers: _earthquakes.map((earthquake) {
                                      return Marker(
                                        point: LatLng(earthquake.latitude,
                                            earthquake.longitude),
                                        width:
                                            40, // Увеличиваем размер, чтобы вместить анимацию
                                        height: 40,
                                        child: _buildAnimatedMarker(
                                            earthquake, _animation.value),
                                      );
                                    }).toList(),
                                  ),
                                  // Добавляем круги вокруг крупных землетрясений для визуализации
                                  CircleLayer(
                                    circles: _earthquakes
                                        .where((eq) => eq.magnitude >= 6.0)
                                        .map((earthquake) {
                                      final radius = earthquake.magnitude *
                                          50000; // Примерный радиус воздействия
                                      return CircleMarker(
                                        point: LatLng(earthquake.latitude,
                                            earthquake.longitude),
                                        radius: radius,
                                        color: Colors.red.withValues(alpha: 0.1),
                                        borderColor:
                                            Colors.red.withValues(alpha: 0.3),
                                        borderStrokeWidth: 1.0,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              // Информационная панель
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    l10n.totalEarthquakes(_earthquakes.length),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              // Легенда
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.magnitudeLegend,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildLegendItem('M ≥ 6.0', Colors.red),
                                        _buildLegendItem(
                                            'M ≥ 5.0', Colors.orange),
                                        _buildLegendItem(
                                            'M ≥ 4.0', Colors.yellow),
                                        _buildLegendItem(
                                            'M < 4.0', Colors.green),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Кнопка просмотра списком
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FloatingActionButton(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      heroTag: 'list',
                                      onPressed: () {
                                        _showEarthquakeListView();
                                      },
                                      child: const Icon(Icons.list),
                                    ),
                                    const SizedBox(height: 8),
                                    FloatingActionButton(
                                      backgroundColor: Colors.green,
                                      heroTag: 'safe_zones',
                                      onPressed: () {
                                        _showSafeZonesMenu();
                                      },
                                      tooltip: l10n.evacuationZones,
                                      child: const Icon(Icons.local_hospital),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  void _showEarthquakeListView() {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    l10n.earthquakesCount(_earthquakes.length),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _earthquakes.length,
                itemBuilder: (context, index) {
                  final earthquake = _earthquakes[index];
                  bool isRecent =
                      DateTime.now().difference(earthquake.time).inHours < 24;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: isRecent ? 3.0 : 1.0,
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                _getColorForMagnitude(earthquake.magnitude),
                            child: Text(
                              earthquake.magnitude.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                              child: Text(l10n.earthquakePlace(earthquake.place))),
                          if (isRecent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l10n.newLabel,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '${DateFormat('dd.MM.yyyy HH:mm').format(earthquake.time)}\n'
                        '${l10n.depth}: ${earthquake.depth.toStringAsFixed(1)} ${l10n.km}',
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showEarthquakeDetails(earthquake);
                        if (_mapReady) {
                          _mapController.move(
                              LatLng(earthquake.latitude, earthquake.longitude),
                              5.0);
                        }
                      },
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: color, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  // Добавляем метод для отображения меню зон эвакуации
  void _showSafeZonesMenu() {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.citiesWithEvacuationZones,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                l10n.evacuationMapHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return ListTile(
                    title: Text(context.l10n.cityName(city.id)),
                    subtitle: Text(context.l10n.zonesCount(city.safeZones.length)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.map, color: Colors.blue),
                          onPressed: () {
                            _showCityOnMap(city);
                          },
                          tooltip: l10n.showOnMap,
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: Colors.grey),
                          onPressed: () {
                            _showCitySafeZones(city);
                          },
                          tooltip: l10n.zoneInfo,
                        ),
                      ],
                    ),
                    onTap: () {
                      _showCitySafeZones(city);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для отображения зон эвакуации выбранного города
  void _showCitySafeZones(City city) {
    Navigator.pop(context); // Закрываем предыдущее меню

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
              child: Column(
                children: [
                  Text(
                    context.l10n.evacuationZonesInCity(
                        context.l10n.cityName(city.id)),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.buildRoutesHint,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: city.safeZones.length,
                itemBuilder: (context, index) {
                  final safeZone = city.safeZones[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        if (safeZone.imageUrl != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                            child: Image.asset(
                              safeZone.imageUrl!,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ListTile(
                          title: Text(context.l10n.zoneName(safeZone.id)),
                          subtitle:
                              Text(context.l10n.zoneDescription(safeZone.id)),
                          trailing: IconButton(
                            icon: const Icon(Icons.map, color: Colors.blue),
                            onPressed: () => _showSafeZoneOnMap(city, safeZone),
                            tooltip: context.l10n.showOnMap,
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
    );
  }

  // Отображает город на карте
  void _showCityOnMap(City city) {
    Navigator.pop(context); // Закрываем меню

    if (_mapReady) {
      // Перемещаем камеру к городу
      _mapController.move(city.coordinates, 11.0);

      // Показываем информацию о городе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${context.l10n.cityLabel(context.l10n.cityName(city.id))} (${context.l10n.zonesCount(city.safeZones.length)})'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: context.l10n.zonesShort,
            onPressed: () => _showCitySafeZones(city),
          ),
        ),
      );
    }
  }

  // Отображает конкретную зону эвакуации на карте
  void _showSafeZoneOnMap(City city, SafeZone safeZone) {
    Navigator.pop(context); // Закрываем модальный лист

    if (_mapReady) {
      // Перемещаем камеру к зоне эвакуации
      _mapController.move(safeZone.coordinates, 15.0);

      // Показываем информацию о зоне
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${context.l10n.evacuationZones}: ${context.l10n.zoneName(safeZone.id)}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Метод для открытия URL землетрясения
  Future<void> _openEarthquakeUrl(String url) async {
    // Закрываем диалог, если он открыт
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    try {
      // Убедимся, что URL правильно сформирован
      final Uri uri = Uri.parse(url);

      // Пытаемся открыть URL во внешнем браузере
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode
              .externalApplication, // Всегда открываем во внешнем приложении
        );
      } else {
        // Если не удалось открыть, показываем сообщение об ошибке
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.openEarthquakeInfoError),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Ошибка при открытии URL: $e');
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
}

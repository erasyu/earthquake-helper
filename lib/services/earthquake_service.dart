import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:earthquake_helper/services/notification_service.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/foundation.dart';

class Earthquake {
  static const unknownPlaceKey = '__unknown__';
  static const dataErrorKey = '__data_error__';

  final double magnitude;
  final String place;
  final DateTime time;
  final double latitude;
  final double longitude;
  final double depth;
  final String url;
  final String source;

  Earthquake({
    required this.magnitude,
    required this.place,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.url,
    this.source = 'USGS',
  });

  factory Earthquake.fromJson(Map<String, dynamic> json,
      {String source = 'USGS'}) {
    if (source == 'EMSC') {
      return _fromEmscJson(json);
    } else {
      return _fromUsgsJson(json);
    }
  }

  static Earthquake _fromUsgsJson(Map<String, dynamic> json) {
    final properties = json['properties'] ?? {};
    final geometry = json['geometry'] ?? {};
    final coordinates = geometry['coordinates'] ?? [0, 0, 0];
    
    double magnitude = 0.0;
    if (properties['mag'] != null) {
      try {
        final magValue = properties['mag'];
        if (magValue is num) {
          magnitude = magValue.toDouble();
          if (magnitude < 0 || magnitude > 10) {
            magnitude = 0.0;
          }
        } else {
          magnitude = double.parse(magValue.toString());
          if (magnitude < 0 || magnitude > 10) {
            magnitude = 0.0;
          }
        }
      } catch (e) {
        debugPrint('Error parsing magnitude: $e');
        magnitude = 0.0;
      }
    }

    DateTime time = DateTime.now();
    if (properties['time'] != null) {
      try {
        if (properties['time'] is int) {
          final timestamp = properties['time'] as int;
          if (timestamp > 0 && timestamp < 9999999999999) {
            time = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true).toLocal();
            if (time.isAfter(DateTime.now().add(const Duration(days: 1))) || 
                time.isBefore(DateTime(1900, 1, 1))) {
              time = DateTime.now();
            }
          }
        } else if (properties['time'] is String) {
          time = DateTime.parse(properties['time'] as String).toLocal();
          if (time.isAfter(DateTime.now().add(const Duration(days: 1))) || 
              time.isBefore(DateTime(1900, 1, 1))) {
            time = DateTime.now();
          }
        }
      } catch (e) {
        debugPrint('Error parsing time: $e');
        time = DateTime.now();
      }
    }

    String url = '';
    if (properties['url'] != null) {
      final urlStr = properties['url'].toString();
      if (urlStr.startsWith('http://') || urlStr.startsWith('https://')) {
        url = urlStr;
      }
    }
    if (url.isEmpty && properties['detail'] != null) {
      final detailStr = properties['detail'].toString();
      if (detailStr.startsWith('http://') || detailStr.startsWith('https://')) {
        url = detailStr;
      }
    }
    if (url.isEmpty && json['id'] != null) {
      final id = json['id'].toString();
      if (id.isNotEmpty && RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id)) {
        url = 'https://earthquake.usgs.gov/earthquakes/eventpage/$id';
      }
    }

    double latitude = 0.0;
    double longitude = 0.0;
    double depth = 0.0;
    
    if (coordinates is List && coordinates.length >= 2) {
      try {
        longitude = coordinates[0] is double
            ? coordinates[0] as double
            : double.parse(coordinates[0].toString());
        latitude = coordinates[1] is double
            ? coordinates[1] as double
            : double.parse(coordinates[1].toString());
        
        if (latitude < -90 || latitude > 90) latitude = 0.0;
        if (longitude < -180 || longitude > 180) longitude = 0.0;
        
        if (coordinates.length > 2 && coordinates[2] != null) {
          depth = coordinates[2] is double
              ? coordinates[2] as double
              : double.parse(coordinates[2].toString());
          if (depth < 0 || depth > 1000) depth = 0.0;
        }
      } catch (e) {
        debugPrint('Error parsing coordinates: $e');
      }
    }

    String place = Earthquake.unknownPlaceKey;
    if (properties['place'] != null) {
      final placeStr = properties['place'].toString();
      if (placeStr.isNotEmpty && placeStr.length < 200) {
        place = placeStr;
      }
    }

    return Earthquake(
      magnitude: magnitude,
      place: place,
      time: time,
      latitude: latitude,
      longitude: longitude,
      depth: depth,
      url: url,
      source: 'USGS',
    );
  }

  static Earthquake _fromEmscJson(Map<String, dynamic> json) {
    try {
      double magnitude = 0.0;
      if (json['magnitude'] != null) {
        try {
          final magValue = json['magnitude'];
          if (magValue is num) {
            magnitude = magValue.toDouble();
            if (magnitude < 0 || magnitude > 10) {
              magnitude = 0.0;
            }
          } else {
            magnitude = double.parse(magValue.toString());
            if (magnitude < 0 || magnitude > 10) {
              magnitude = 0.0;
            }
          }
        } catch (e) {
          debugPrint('Error parsing EMSC magnitude: $e');
          magnitude = 0.0;
        }
      }

      DateTime time = DateTime.now();
      if (json['time'] != null) {
        try {
          if (json['time'] is int) {
            final timestamp = json['time'] as int;
            if (timestamp > 0 && timestamp < 9999999999) {
              time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true).toLocal();
              if (time.isAfter(DateTime.now().add(const Duration(days: 1))) || 
                  time.isBefore(DateTime(1900, 1, 1))) {
                time = DateTime.now();
              }
            }
          } else if (json['time'] is String) {
            time = DateTime.parse(json['time'] as String).toLocal();
            if (time.isAfter(DateTime.now().add(const Duration(days: 1))) || 
                time.isBefore(DateTime(1900, 1, 1))) {
              time = DateTime.now();
            }
          }
        } catch (e) {
          debugPrint('Error parsing EMSC time: $e');
          time = DateTime.now();
        }
      }

      double latitude = 0.0;
      double longitude = 0.0;
      double depth = 0.0;
      
      if (json['lat'] != null) {
        try {
          final latValue = json['lat'];
          latitude = latValue is double
              ? latValue
              : double.parse(latValue.toString());
          if (latitude < -90 || latitude > 90) latitude = 0.0;
        } catch (e) {
          debugPrint('Error parsing EMSC latitude: $e');
        }
      }
      
      if (json['lon'] != null) {
        try {
          final lonValue = json['lon'];
          longitude = lonValue is double
              ? lonValue
              : double.parse(lonValue.toString());
          if (longitude < -180 || longitude > 180) longitude = 0.0;
        } catch (e) {
          debugPrint('Error parsing EMSC longitude: $e');
        }
      }
      
      if (json['depth'] != null) {
        try {
          final depthValue = json['depth'];
          depth = depthValue is double
              ? depthValue
              : double.parse(depthValue.toString());
          if (depth < 0 || depth > 1000) depth = 0.0;
        } catch (e) {
          debugPrint('Error parsing EMSC depth: $e');
        }
      }

      String place = Earthquake.unknownPlaceKey;
      if (json['flynn_region'] != null) {
        final placeStr = json['flynn_region'].toString();
        if (placeStr.isNotEmpty && placeStr.length < 200) {
          place = placeStr;
        }
      } else if (json['region'] != null) {
        final placeStr = json['region'].toString();
        if (placeStr.isNotEmpty && placeStr.length < 200) {
          place = placeStr;
        }
      }

      String url = '';
      if (json['id'] != null) {
        final id = json['id'].toString();
        if (id.isNotEmpty && RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id)) {
          url = 'https://www.emsc-csem.org/Earthquake/earthquake.php?id=$id';
        }
      }

      return Earthquake(
        magnitude: magnitude,
        place: place,
        time: time,
        latitude: latitude,
        longitude: longitude,
        depth: depth,
        url: url,
        source: 'EMSC',
      );
    } catch (e) {
      debugPrint('Error parsing EMSC earthquake: $e');
      return Earthquake(
        magnitude: 0.0,
        place: Earthquake.dataErrorKey,
        time: DateTime.now(),
        latitude: 0,
        longitude: 0,
        depth: 0,
        url: '',
        source: 'EMSC',
      );
    }
  }
}

class EarthquakeService {
  static const String _baseUrlTemplate =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_{period}.geojson';
  static const String _realTimeUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_hour.geojson';
  static const String _emscBaseUrl =
      'https://www.seismicportal.eu/fdsnws/event/1/query';
  static const String _cacheKey = 'earthquake_cache';
  static const String _cacheTimeKey = 'earthquake_cache_time';
  static const double _minNotifyMagnitude = 4.0;
  static const int _maxCacheAgeRealTime = 5 * 60 * 1000;
  static const int _maxCacheAgeNormal = 30 * 60 * 1000;

  final NotificationService _notificationService = NotificationService();
  final SharedPreferences _prefs;
  bool _backgroundUpdateActive = false;
  bool _useEmscApi = true;

  EarthquakeService(this._prefs);

  void startBackgroundUpdates(Function onNewEarthquakes) {
    if (_backgroundUpdateActive) return;

    _backgroundUpdateActive = true;
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 5));
      if (!_backgroundUpdateActive) return false;

      try {
        final earthquakes = await getRealtimeEarthquakes();
        onNewEarthquakes(earthquakes);
        return true;
      } catch (e) {
        debugPrint('Ошибка фонового обновления: $e');
        return true;
      }
    });
  }

  void stopBackgroundUpdates() {
    _backgroundUpdateActive = false;
  }

  Future<List<Earthquake>> getRealtimeEarthquakes() async {
    const String cacheKey = '${_cacheKey}_realtime';
    final String? cachedData = _prefs.getString(cacheKey);
    final int? lastCheck = _prefs.getInt('${_cacheTimeKey}_realtime');

    final now = DateTime.now().millisecondsSinceEpoch;
    if (cachedData != null &&
        lastCheck != null &&
        (now - lastCheck) < _maxCacheAgeRealTime) {
      try {
        final earthquakes = _parseEarthquakes(json.decode(cachedData));
        return earthquakes;
      } catch (e) {
        debugPrint('Error parsing cached data: $e');
      }
    }

    try {
      List<Earthquake> earthquakes = [];
      if (_useEmscApi) {
        try {
          earthquakes = await _getEmscEarthquakes(
            startTime: DateTime.now().subtract(const Duration(hours: 1)),
            minMagnitude: 4.0,
          );
        } catch (e) {
          debugPrint('Error loading EMSC data: $e');
          _useEmscApi = false;
        }
      }

      if (earthquakes.isEmpty) {
        final response = await _getWithRetry(Uri.parse(_realTimeUrl), maxRetries: 3);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await _prefs.setString(cacheKey, response.body);
          await _prefs.setInt('${_cacheTimeKey}_realtime', now);

          earthquakes = _parseEarthquakes(data);
        } else {
          throw Exception('Failed to load realtime earthquakes from USGS: ${response.statusCode}');
        }
      } else {
        final emscCacheData = {
          'earthquakes': earthquakes
              .map((e) => {
                    'magnitude': e.magnitude,
                    'flynn_region': e.place,
                    'time': e.time.millisecondsSinceEpoch ~/ 1000,
                    'lat': e.latitude,
                    'lon': e.longitude,
                    'depth': e.depth,
                    'id': e.url.split('=').last,
                  })
              .toList()
        };
        await _prefs.setString(cacheKey, json.encode(emscCacheData));
        await _prefs.setInt('${_cacheTimeKey}_realtime', now);
      }

      _checkForNewEarthquakes(earthquakes);

      return earthquakes;
    } catch (e) {
      debugPrint('Error loading realtime earthquakes: $e');
      if (cachedData != null) {
        try {
          return _parseEarthquakes(json.decode(cachedData));
        } catch (e) {
          debugPrint('Error parsing cached data: $e');
        }
      }
      return [];
    }
  }

  Future<List<Earthquake>> getRecentEarthquakes({
    int days = 7,
    double minMagnitude = 0.0,
    bool globalMode = false,
    bool forceRefresh = false,
  }) async {
    String period;
    if (days <= 1) {
      period = 'day';
    } else if (days <= 7) {
      period = 'week';
    } else if (days <= 30) {
      period = 'month';
    } else {
      period = 'month';
    }

    final String cacheKey = '${_cacheKey}_${period}_$globalMode';
    final cachedData = _prefs.getString(cacheKey);
    final lastCheck = _prefs.getInt('${_cacheTimeKey}_$period');

    if (!forceRefresh && cachedData != null && lastCheck != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastCheck < _maxCacheAgeNormal) {
        try {
          final earthquakes = _parseEarthquakes(json.decode(cachedData));
          return _filterEarthquakes(
              earthquakes, minMagnitude, days, globalMode);
        } catch (e) {
          debugPrint('Error parsing cached data: $e');
        }
      }
    }

    try {
      List<Earthquake> earthquakes = [];
      if (!globalMode) {
        try {
          final String apiUrl = _baseUrlTemplate.replaceAll('{period}', period);
          final response = await _getWithRetry(Uri.parse(apiUrl), maxRetries: 3);
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            earthquakes = _parseEarthquakes(data);
            earthquakes = _filterEarthquakes(earthquakes, minMagnitude, days, globalMode);
            await _prefs.setString(cacheKey, response.body);
            await _prefs.setInt('${_cacheTimeKey}_$period',
                DateTime.now().millisecondsSinceEpoch);
            
            return earthquakes;
          }
        } catch (e) {
          debugPrint('Error loading earthquakes for Kazakhstan: $e');
        }
      }

      if (_useEmscApi) {
        try {
          final startTime = DateTime.now().subtract(Duration(days: days));
          earthquakes = await _getEmscEarthquakes(
            startTime: startTime,
            minMagnitude: minMagnitude,
          );

          final emscCacheData = {
            'earthquakes': earthquakes
                .map((e) => {
                      'magnitude': e.magnitude,
                      'flynn_region': e.place,
                      'time': e.time.millisecondsSinceEpoch ~/ 1000,
                      'lat': e.latitude,
                      'lon': e.longitude,
                      'depth': e.depth,
                      'id': e.url.split('=').last,
                    })
                .toList()
          };

          await _prefs.setString(cacheKey, json.encode(emscCacheData));
          await _prefs.setInt('${_cacheTimeKey}_$period',
              DateTime.now().millisecondsSinceEpoch);
          return _filterEarthquakes(
              earthquakes, minMagnitude, days, globalMode);
        } catch (e) {
          debugPrint('Error loading EMSC data: $e');
          _useEmscApi = false;
        }
      }

      final String apiUrl = _baseUrlTemplate.replaceAll('{period}', period);
      final response = await _getWithRetry(Uri.parse(apiUrl), maxRetries: 3);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _prefs.setString(cacheKey, response.body);
        await _prefs.setInt('${_cacheTimeKey}_$period',
            DateTime.now().millisecondsSinceEpoch);

        earthquakes = _parseEarthquakes(data);
        _checkForNewEarthquakes(earthquakes);

        return _filterEarthquakes(earthquakes, minMagnitude, days, globalMode);
      } else {
        throw Exception('Failed to load earthquakes from USGS');
      }
    } catch (e) {
      debugPrint('Error loading earthquakes: $e');
      if (cachedData != null) {
        try {
          final earthquakes = _parseEarthquakes(json.decode(cachedData));
          return _filterEarthquakes(
              earthquakes, minMagnitude, days, globalMode);
        } catch (e) {
          debugPrint('Error parsing cached data: $e');
        }
      }
      return [];
    }
  }

  Future<List<Earthquake>> _getEmscEarthquakes({
    required DateTime startTime,
    double minMagnitude = 0.0,
  }) async {
    final String formattedStartTime =
        "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}";

    final String url =
        '$_emscBaseUrl?format=json&minmag=$minMagnitude&start=$formattedStartTime';

    try {
      final response = await _getWithRetry(Uri.parse(url), maxRetries: 3);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('features')) {
          List<dynamic> features = data['features'];
          return features
              .map((feature) {
                try {
                  if (feature is Map && feature.containsKey('properties')) {
                    return Earthquake.fromJson(feature['properties'],
                        source: 'EMSC');
                  }
                } catch (e) {
                  debugPrint('Error parsing EMSC feature: $e');
                }
                return null;
              })
              .whereType<Earthquake>()
              .toList();
        } else {
          throw Exception('Invalid EMSC data format: missing features');
        }
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception('Failed to load EMSC data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in _getEmscEarthquakes: $e');
      rethrow;
    }
  }

  List<Earthquake> _parseEarthquakes(Map<String, dynamic> data) {
    try {
      if (data.containsKey('earthquakes')) {
        final earthquakeList = data['earthquakes'];
        if (earthquakeList is List) {
          return earthquakeList
              .whereType<Map<String, dynamic>>()
              .map((item) {
                try {
                  return Earthquake.fromJson(item, source: 'EMSC');
                } catch (e) {
                  debugPrint('Error parsing earthquake item: $e');
                  return null;
                }
              })
              .whereType<Earthquake>()
              .toList();
        }
        return [];
      } else if (data.containsKey('features')) {
        final features = data['features'];
        if (features is List) {
          List<Earthquake> result = [];

          for (var feature in features) {
            try {
              if (feature is Map<String, dynamic>) {
                final earthquake = Earthquake.fromJson(feature, source: 'USGS');
                if (earthquake.magnitude > 0 && 
                    earthquake.latitude != 0 && 
                    earthquake.longitude != 0) {
                  result.add(earthquake);
                }
              }
            } catch (e) {
              debugPrint('Error parsing earthquake: $e');
            }
          }
          return result;
        }
        return [];
      } else {
        debugPrint('Unknown data format');
        return [];
      }
    } catch (e) {
      debugPrint('Error in _parseEarthquakes: $e');
      return [];
    }
  }

  List<Earthquake> _filterEarthquakes(List<Earthquake> earthquakes,
      double minMagnitude, int days, bool globalMode) {
    final DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
    var filtered = earthquakes
        .where(
            (eq) => eq.magnitude >= minMagnitude && eq.time.isAfter(cutoffDate))
        .toList();
    if (!globalMode) {
      filtered = filtered
          .where((eq) => _isInKazakhstan(eq.latitude, eq.longitude))
          .toList();
    }
    filtered.sort((a, b) => b.time.compareTo(a.time));

    return filtered;
  }

  bool _isInKazakhstan(double latitude, double longitude) {
    const double minLat = 40.9;
    const double maxLat = 55.4;
    const double minLon = 46.5;
    const double maxLon = 87.4;
    bool inMainBounds = latitude >= minLat &&
        latitude <= maxLat &&
        longitude >= minLon &&
        longitude <= maxLon;

    if (inMainBounds) return true;
    const double almatyLat = 43.25;
    const double almatyLon = 76.95;
    const double almatyRadius = 2.0;
    bool isNearAlmaty = math.pow(latitude - almatyLat, 2) +
            math.pow(longitude - almatyLon, 2) <=
        math.pow(almatyRadius, 2);
    const double astanaLat = 51.13;
    const double astanaLon = 71.43;
    const double astanaRadius = 1.5;
    bool isNearAstana = math.pow(latitude - astanaLat, 2) +
            math.pow(longitude - astanaLon, 2) <=
        math.pow(astanaRadius, 2);
    const double shymkentLat = 42.30;
    const double shymkentLon = 69.60;
    const double shymkentRadius = 1.5;

    bool isNearShymkent = math.pow(latitude - shymkentLat, 2) +
            math.pow(longitude - shymkentLon, 2) <=
        math.pow(shymkentRadius, 2);

    return isNearAlmaty || isNearAstana || isNearShymkent;
  }

  bool isDangerous(double magnitude) {
    return magnitude >= 5.0;
  }

  void _checkForNewEarthquakes(List<Earthquake> earthquakes) {
    final lastNotificationTime = _prefs.getInt('last_notification_time');
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lastNotificationTime == null || now - lastNotificationTime > 300000) {
      if (earthquakes.isNotEmpty) {
        earthquakes.sort((a, b) => b.magnitude.compareTo(a.magnitude));
        final strongestEarthquake = earthquakes.first;
        if (_isInKazakhstan(
                strongestEarthquake.latitude, strongestEarthquake.longitude) &&
            strongestEarthquake.magnitude >= _minNotifyMagnitude) {
          _notificationService.showEarthquakeNotification(
            magnitude: strongestEarthquake.magnitude,
            place: strongestEarthquake.place,
            time: strongestEarthquake.time,
          );
          _prefs.setInt('last_notification_time', now);
        }
      }
    }
  }

  Future<http.Response> _getWithRetry(Uri url, {int maxRetries = 3}) async {
    if (!url.hasScheme || (!url.scheme.startsWith('http'))) {
      throw Exception('Invalid URL scheme');
    }
    
    int attempts = 0;
    http.Response? response;
    
    while (attempts < maxRetries) {
      try {
        response = await http.get(url, headers: {
          'User-Agent': 'EarthquakeHelper/1.0',
          'Accept': 'application/json',
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Request timeout');
          },
        );
        
        if (response.statusCode == 200) {
          if (response.body.length > 10 * 1024 * 1024) {
            throw Exception('Response too large');
          }
          return response;
        } else if (response.statusCode == 204) {
          return http.Response('', 204);
        } else if (response.statusCode >= 500 && attempts < maxRetries - 1) {
          attempts++;
          await Future.delayed(Duration(seconds: attempts * 2));
          continue;
        } else {
          return response;
        }
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    return response ?? http.Response('', 500);
  }
}

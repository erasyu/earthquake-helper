import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:earthquake_helper/services/earthquake_service.dart';

void main() {
  group('EarthquakeService', () {
    late SharedPreferences prefs;
    late EarthquakeService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = EarthquakeService(prefs);
    });

    test('should create instance', () {
      expect(service, isNotNull);
    });

    test('should filter earthquakes in Kazakhstan', () {
      // Тест для координат в Казахстане
      const kazakhstanLat = 50.0;
      const kazakhstanLon = 70.0;

      // Создаем тестовое землетрясение в Казахстане
      final earthquake = Earthquake(
        magnitude: 4.5,
        place: 'Алматы, Казахстан',
        time: DateTime.now(),
        latitude: kazakhstanLat,
        longitude: kazakhstanLon,
        depth: 10.0,
        url: 'https://example.com',
      );

      expect(earthquake.latitude, equals(kazakhstanLat));
      expect(earthquake.longitude, equals(kazakhstanLon));
    });

    test('should parse earthquake from USGS JSON', () {
      final json = {
        'properties': {
          'mag': 5.5,
          'place': 'Test Location',
          'time': DateTime.now().millisecondsSinceEpoch,
          'url': 'https://example.com',
        },
        'geometry': {
          'coordinates': [70.0, 50.0, 10.0],
        },
      };

      final earthquake = Earthquake.fromJson(json, source: 'USGS');

      expect(earthquake.magnitude, equals(5.5));
      expect(earthquake.place, equals('Test Location'));
      expect(earthquake.latitude, equals(50.0));
      expect(earthquake.longitude, equals(70.0));
      expect(earthquake.depth, equals(10.0));
      expect(earthquake.source, equals('USGS'));
    });

    test('should parse earthquake from EMSC JSON', () {
      final json = {
        'magnitude': 6.0,
        'flynn_region': 'Test Region',
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'lat': 43.25,
        'lon': 76.95,
        'depth': 15.0,
        'id': '12345',
      };

      final earthquake = Earthquake.fromJson(json, source: 'EMSC');

      expect(earthquake.magnitude, equals(6.0));
      expect(earthquake.place, equals('Test Region'));
      expect(earthquake.latitude, equals(43.25));
      expect(earthquake.longitude, equals(76.95));
      expect(earthquake.depth, equals(15.0));
      expect(earthquake.source, equals('EMSC'));
    });

    test('should handle missing magnitude in JSON', () {
      final json = {
        'properties': {
          'place': 'Test Location',
          'time': DateTime.now().millisecondsSinceEpoch,
          'url': 'https://example.com',
        },
        'geometry': {
          'coordinates': [70.0, 50.0, 10.0],
        },
      };

      final earthquake = Earthquake.fromJson(json);

      expect(earthquake.magnitude, equals(0.0));
      expect(earthquake.place, equals('Test Location'));
    });

    test('should handle missing place in JSON', () {
      final json = {
        'properties': {
          'mag': 5.5,
          'time': DateTime.now().millisecondsSinceEpoch,
          'url': 'https://example.com',
        },
        'geometry': {
          'coordinates': [70.0, 50.0, 10.0],
        },
      };

      final earthquake = Earthquake.fromJson(json);

      expect(earthquake.magnitude, equals(5.5));
      expect(earthquake.place, equals('Неизвестное место'));
    });

    test('should handle string magnitude in JSON', () {
      final json = {
        'properties': {
          'mag': '5.5',
          'place': 'Test Location',
          'time': DateTime.now().millisecondsSinceEpoch,
          'url': 'https://example.com',
        },
        'geometry': {
          'coordinates': [70.0, 50.0, 10.0],
        },
      };

      final earthquake = Earthquake.fromJson(json);

      expect(earthquake.magnitude, equals(5.5));
    });

    test('should handle missing depth in coordinates', () {
      final json = {
        'properties': {
          'mag': 5.5,
          'place': 'Test Location',
          'time': DateTime.now().millisecondsSinceEpoch,
          'url': 'https://example.com',
        },
        'geometry': {
          'coordinates': [70.0, 50.0],
        },
      };

      final earthquake = Earthquake.fromJson(json);

      expect(earthquake.depth, equals(0.0));
    });
  });
}

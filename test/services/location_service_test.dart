import 'package:flutter_test/flutter_test.dart';
import 'package:earthquake_helper/services/location_service.dart';

void main() {
  group('LocationService', () {
    test('should create singleton instance', () {
      final service1 = LocationService();
      final service2 = LocationService();
      
      expect(service1, equals(service2));
    });

    test('should calculate distance correctly', () {
      final service = LocationService();
      
      // Расстояние между Алматы и Астаной (примерно 1000 км)
      const almatyLat = 43.25;
      const almatyLon = 76.95;
      const astanaLat = 51.13;
      const astanaLon = 71.43;
      
      final distance = service.calculateDistance(
        almatyLat,
        almatyLon,
        astanaLat,
        astanaLon,
      );
      
      // Проверяем, что расстояние примерно 1000 км (с допуском 100 км)
      expect(distance, greaterThan(900000)); // больше 900 км
      expect(distance, lessThan(1100000)); // меньше 1100 км
    });
  });
}


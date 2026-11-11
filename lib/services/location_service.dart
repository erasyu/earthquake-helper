import 'package:geolocator/geolocator.dart';

class LocationPermissionException implements Exception {
  const LocationPermissionException();
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Stream<Position>? _positionStream;
  Position? _lastKnownPosition;

  Future<bool> _handlePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> initialize() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      throw const LocationPermissionException();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    _lastKnownPosition = await Geolocator.getLastKnownPosition();
  }

  Stream<Position>? get positionStream => _positionStream;
  Position? get lastKnownPosition => _lastKnownPosition;

  Future<Position> getCurrentPosition() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      throw const LocationPermissionException();
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  double calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}

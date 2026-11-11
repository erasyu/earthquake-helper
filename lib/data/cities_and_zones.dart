import 'package:latlong2/latlong.dart';

class City {
  final String id;
  final LatLng coordinates;
  final List<SafeZone> safeZones;

  City({
    required this.id,
    required this.coordinates,
    required this.safeZones,
  });
}

class SafeZone {
  final String id;
  final LatLng coordinates;
  final String typeKey;
  final String? imageUrl;

  SafeZone({
    required this.id,
    required this.coordinates,
    required this.typeKey,
    this.imageUrl,
  });
}

final List<City> cities = [
  City(
    id: 'almaty',
    coordinates: const LatLng(43.238949, 76.889709),
    safeZones: [
      SafeZone(
        id: 'park_panfilov',
        coordinates: const LatLng(43.257765, 76.945755),
        typeKey: 'park',
        imageUrl: 'assets/images/park_panfilov.jpg',
      ),
      SafeZone(
        id: 'central_stadium',
        coordinates: const LatLng(43.234768, 76.944543),
        typeKey: 'stadium',
        imageUrl: 'assets/images/central_stadium.jpg',
      ),
      SafeZone(
        id: 'first_president_park',
        coordinates: const LatLng(43.209568, 76.899285),
        typeKey: 'park',
        imageUrl: 'assets/images/first_president_park.jpg',
      ),
      SafeZone(
        id: 'republic_square',
        coordinates: const LatLng(43.233791, 76.951581),
        typeKey: 'square',
        imageUrl: 'assets/images/republic_square.jpg',
      ),
      SafeZone(
        id: 'baum_grove',
        coordinates: const LatLng(43.294954, 76.875217),
        typeKey: 'park',
        imageUrl: 'assets/images/baum_grove.jpg',
      ),
      SafeZone(
        id: 'school_15',
        coordinates: const LatLng(43.241248, 76.917450),
        typeKey: 'school',
        imageUrl: 'assets/images/school_15.jpg',
      ),
      SafeZone(
        id: 'hospital_7',
        coordinates: const LatLng(43.257768, 76.933145),
        typeKey: 'hospital',
        imageUrl: 'assets/images/hospital_7.jpg',
      ),
    ],
  ),
  City(
    id: 'astana',
    coordinates: const LatLng(51.128207, 71.430411),
    safeZones: [
      SafeZone(
        id: 'peace_park',
        coordinates: const LatLng(51.132741, 71.421702),
        typeKey: 'park',
        imageUrl: 'assets/images/peace_park.jpg',
      ),
      SafeZone(
        id: 'astana_arena',
        coordinates: const LatLng(51.089536, 71.398490),
        typeKey: 'stadium',
        imageUrl: 'assets/images/astana_arena.jpg',
      ),
      SafeZone(
        id: 'independence_square',
        coordinates: const LatLng(51.129968, 71.424861),
        typeKey: 'square',
        imageUrl: 'assets/images/independence_square.jpg',
      ),
      SafeZone(
        id: 'president_park',
        coordinates: const LatLng(51.124251, 71.467775),
        typeKey: 'park',
        imageUrl: 'assets/images/president_park.jpg',
      ),
      SafeZone(
        id: 'school_73',
        coordinates: const LatLng(51.140125, 71.412350),
        typeKey: 'school',
        imageUrl: 'assets/images/school_73.jpg',
      ),
      SafeZone(
        id: 'hospital_2',
        coordinates: const LatLng(51.137942, 71.456240),
        typeKey: 'hospital',
        imageUrl: 'assets/images/hospital_2.jpg',
      ),
    ],
  ),
  City(
    id: 'shymkent',
    coordinates: const LatLng(42.300000, 69.600000),
    safeZones: [
      SafeZone(
        id: 'abay_park',
        coordinates: const LatLng(42.306764, 69.586553),
        typeKey: 'park',
        imageUrl: 'assets/images/abay_park.jpg',
      ),
      SafeZone(
        id: 'kazhymukan_stadium',
        coordinates: const LatLng(42.295204, 69.605089),
        typeKey: 'stadium',
        imageUrl: 'assets/images/kazhymukan_stadium.jpg',
      ),
      SafeZone(
        id: 'dendropark',
        coordinates: const LatLng(42.312465, 69.587928),
        typeKey: 'park',
        imageUrl: 'assets/images/dendropark.jpg',
      ),
      SafeZone(
        id: 'ordabasy_square',
        coordinates: const LatLng(42.317798, 69.596314),
        typeKey: 'square',
        imageUrl: 'assets/images/ordabasy_square.jpg',
      ),
      SafeZone(
        id: 'school_45',
        coordinates: const LatLng(42.305157, 69.610435),
        typeKey: 'school',
        imageUrl: 'assets/images/school_45.jpg',
      ),
      SafeZone(
        id: 'regional_hospital',
        coordinates: const LatLng(42.321898, 69.584574),
        typeKey: 'hospital',
        imageUrl: 'assets/images/regional_hospital.jpg',
      ),
    ],
  ),
  City(
    id: 'atyrau',
    coordinates: const LatLng(47.1167, 51.8833),
    safeZones: [
      SafeZone(
        id: 'atyrau_central_park',
        coordinates: const LatLng(47.119189, 51.881274),
        typeKey: 'park',
        imageUrl: 'assets/images/atyrau_central_park.jpg',
      ),
      SafeZone(
        id: 'munayshi_stadium',
        coordinates: const LatLng(47.121894, 51.890093),
        typeKey: 'stadium',
        imageUrl: 'assets/images/munayshi_stadium.jpg',
      ),
      SafeZone(
        id: 'atyrau_hospital',
        coordinates: const LatLng(47.125564, 51.877508),
        typeKey: 'hospital',
        imageUrl: 'assets/images/atyrau_hospital.jpg',
      ),
      SafeZone(
        id: 'atyrau_school',
        coordinates: const LatLng(47.114236, 51.895379),
        typeKey: 'school',
        imageUrl: 'assets/images/atyrau_school.jpg',
      ),
    ],
  ),
  City(
    id: 'karaganda',
    coordinates: const LatLng(49.8333, 73.1667),
    safeZones: [
      SafeZone(
        id: 'karaganda_park',
        coordinates: const LatLng(49.835604, 73.161218),
        typeKey: 'park',
        imageUrl: 'assets/images/karaganda_park.jpg',
      ),
      SafeZone(
        id: 'shakhtyor_stadium',
        coordinates: const LatLng(49.828903, 73.173237),
        typeKey: 'stadium',
        imageUrl: 'assets/images/shakhtyor_stadium.jpg',
      ),
      SafeZone(
        id: 'karaganda_square',
        coordinates: const LatLng(49.831689, 73.165762),
        typeKey: 'square',
        imageUrl: 'assets/images/karaganda_square.jpg',
      ),
      SafeZone(
        id: 'karaganda_hospital',
        coordinates: const LatLng(49.840129, 73.158170),
        typeKey: 'hospital',
        imageUrl: 'assets/images/karaganda_hospital.jpg',
      ),
    ],
  ),
];

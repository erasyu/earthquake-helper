import 'package:flutter/material.dart';
import '../data/cities_and_zones.dart';
import '../l10n/app_localizations.dart';
import 'evacuation_map_screen.dart';

class CitySelectionScreen extends StatelessWidget {
  const CitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectCity),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                l10n.cityName(city.id),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l10n.zonesCount(city.safeZones.length)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EvacuationMapScreen(),
                    settings: RouteSettings(arguments: city),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

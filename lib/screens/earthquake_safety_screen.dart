import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EarthquakeSafetyScreen extends StatelessWidget {
  const EarthquakeSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.earthquakeSafety)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              l10n.duringEarthquake,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(l10n.duringEarthquakeSteps,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text(
              l10n.afterEarthquake,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(l10n.afterEarthquakeSteps,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Image.asset('assets/images/earthquake.jpeg'),
          ],
        ),
      ),
    );
  }
}

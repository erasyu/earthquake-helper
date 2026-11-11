import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AnimalBiteCareScreen extends StatelessWidget {
  const AnimalBiteCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.animalBitesTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.animalBitesTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(l10n.animalBitesSteps, style: const TextStyle(fontSize: 16)),
            Image.asset('assets/images/AnimalBite.jpg'),
          ],
        ),
      ),
    );
  }
}

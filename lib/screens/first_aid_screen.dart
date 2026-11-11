import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'cpr_screen.dart';
import 'bleeding_control_screen.dart';
import 'fracture_care_screen.dart';
import 'burns_care_screen.dart';
import 'poisoning_care_screen.dart';
import 'animal_bite_care_screen.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.firstAid)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(l10n.cpr),
            subtitle: Text(l10n.cprDesc),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CPRScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bloodtype, color: Colors.redAccent),
            title: Text(l10n.bleedingControl),
            subtitle: Text(l10n.bleedingControlDesc),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BleedingControlScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: Text(l10n.fractures),
            subtitle: Text(l10n.fracturesDesc),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FractureCareScreen(),
              ),
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.local_fire_department, color: Colors.orange),
            title: Text(l10n.burns),
            subtitle: Text(l10n.burnsDesc),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BurnsCareScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety, color: Colors.green),
            title: Text(l10n.poisoning),
            subtitle: Text(l10n.poisoningDesc),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PoisoningCareScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pets, color: Colors.blueGrey),
            title: Text(l10n.animalBites),
            subtitle: Text(l10n.animalBitesDesc),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnimalBiteCareScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

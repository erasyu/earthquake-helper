import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/emergency_kit_items.dart';
import '../l10n/app_localizations.dart';
import '../services/widget_service.dart';

class EmergencyKitScreen extends StatefulWidget {
  const EmergencyKitScreen({super.key});

  @override
  State<EmergencyKitScreen> createState() => _EmergencyKitScreenState();
}

class _EmergencyKitScreenState extends State<EmergencyKitScreen> {
  final Map<String, bool> _checkedItems = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadCheckedItems();
  }

  Future<void> _loadCheckedItems() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final id in emergencyKitItemIds) {
        _checkedItems[id] =
            prefs.getBool(emergencyKitPrefsKey(id)) ?? false;
      }
      _loaded = true;
    });
  }

  Future<void> _saveCheckedItems() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _checkedItems.entries) {
      await prefs.setBool(emergencyKitPrefsKey(entry.key), entry.value);
    }
    await WidgetService.updateEmergencyBagItems();
  }

  void _toggleItem(String id, bool? value) {
    setState(() {
      _checkedItems[id] = value ?? false;
    });
    _saveCheckedItems();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final checkedCount =
        _checkedItems.values.where((checked) => checked).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.emergencyKit,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade50, Colors.orange.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.red, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.important,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.emergencyKitImportant,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: emergencyKitItemIds.isEmpty
                            ? 0
                            : checkedCount / emergencyKitItemIds.length,
                        backgroundColor: Colors.red.shade100,
                        color: Colors.green,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.kitProgress(
                          checkedCount,
                          emergencyKitItemIds.length,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: emergencyKitItemIds.length,
                    itemBuilder: (context, index) {
                      final id = emergencyKitItemIds[index];
                      final isChecked = _checkedItems[id] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: Checkbox(
                            value: isChecked,
                            onChanged: (value) => _toggleItem(id, value),
                          ),
                          title: Text(
                            l10n.kitItemName(id),
                            style: TextStyle(
                              decoration: isChecked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.storagePeriod,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(l10n.kitItemExpiry(id)),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.replacementTips,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(l10n.kitItemReplacement(id)),
                                ],
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
    );
  }
}

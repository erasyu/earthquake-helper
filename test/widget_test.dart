import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:earthquake_helper/main.dart';
import 'package:earthquake_helper/services/earthquake_service.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final earthquakeService = EarthquakeService(prefs);
    await tester.pumpWidget(MyApp(earthquakeService: earthquakeService));
    await tester.pumpAndSettle();
    // Даём выполниться отложенным таймерам (например, проверка intent для сирены),
    // чтобы в конце теста не оставалось незавершённых таймеров
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

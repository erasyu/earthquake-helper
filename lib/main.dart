import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/background_service.dart';
import 'services/earthquake_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'siren.dart';

Future<void> callEmergency(String number) async {
  try {
    final Uri url = Uri.parse('tel:$number');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Call failed: $number';
    }
  } catch (e) {
    throw 'Call error: ${e.toString()}';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows) {
    try {
      await NotificationService().initialize();
      final backgroundService = BackgroundService();
      await backgroundService.initialize();
      await WidgetService.initialize();
    } catch (e) {
      debugPrint('Service init error: $e');
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final earthquakeService = EarthquakeService(prefs);
  runApp(MyApp(earthquakeService: earthquakeService));
}

class MyApp extends StatefulWidget {
  final EarthquakeService earthquakeService;

  const MyApp({super.key, required this.earthquakeService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const MethodChannel _channel =
      MethodChannel('kz.earthquake.helper/siren');
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _setupMethodChannel();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale');
    if (code != null && mounted) {
      setState(() => _locale = Locale(code));
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale.languageCode);
    if (mounted) {
      setState(() => _locale = locale);
    }
  }

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'toggleSiren') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const EmergencySiren(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: _locale ?? const Locale('ru'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale != null) return _locale;
        if (locale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('ru');
      },
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: Colors.orange[700],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.orange[700],
          foregroundColor: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(
        earthquakeService: widget.earthquakeService,
        onLocaleChanged: setLocale,
      ),
    );
  }
}

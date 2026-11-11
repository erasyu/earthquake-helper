import 'package:shared_preferences/shared_preferences.dart';

import 'strings_en.dart';
import 'strings_kk.dart';
import 'strings_ru.dart';

Map<String, String> stringsForLocale(String? code) {
  switch (code) {
    case 'kk':
      return stringsKk;
    case 'en':
      return stringsEn;
    case 'ru':
    default:
      return stringsRu;
  }
}

Future<Map<String, String>> getStoredLocaleStrings() async {
  final prefs = await SharedPreferences.getInstance();
  return stringsForLocale(prefs.getString('app_locale'));
}

Future<String> localizedString(
  String key, [
  Map<String, String> params = const {},
]) async {
  final strings = await getStoredLocaleStrings();
  var value = strings[key] ?? stringsRu[key] ?? key;
  params.forEach((k, v) {
    value = value.replaceAll('{$k}', v);
  });
  return value;
}

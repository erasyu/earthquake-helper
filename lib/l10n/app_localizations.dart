import 'package:flutter/material.dart';
import 'strings_en.dart';
import 'strings_kk.dart';
import 'strings_ru.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('kk'),
    Locale('ru'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'kk':
        return stringsKk;
      case 'en':
        return stringsEn;
      case 'ru':
      default:
        return stringsRu;
    }
  }

  String tr(String key, [Map<String, String> params = const {}]) {
    var value = _strings[key] ?? stringsRu[key] ?? key;
    params.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }

  // Common
  String get appTitle => tr('appTitle');
  String get settings => tr('settings');
  String get saveSettings => tr('saveSettings');
  String get settingsSaved => tr('settingsSaved');
  String get close => tr('close');
  String get moreDetails => tr('moreDetails');
  String get cancel => tr('cancel');
  String get apply => tr('apply');
  String get error => tr('error');
  String get or => tr('or');
  String get important => tr('important');
  String get call => tr('call');
  String get route => tr('route');
  String get onMap => tr('onMap');
  String get type => tr('type');
  String get place => tr('place');
  String get time => tr('time');
  String get depth => tr('depth');
  String get coordinates => tr('coordinates');
  String get source => tr('source');
  String get days => tr('days');
  String get newLabel => tr('newLabel');
  String get km => tr('km');
  String get minutes => tr('minutes');

  // Language
  String get language => tr('language');
  String get languageKk => tr('languageKk');
  String get languageRu => tr('languageRu');
  String get languageEn => tr('languageEn');

  // Home menu
  String get menuEvacuationMap => tr('menuEvacuationMap');
  String get menuEvacuationMapDesc => tr('menuEvacuationMapDesc');
  String get menuEarthquakeHistory => tr('menuEarthquakeHistory');
  String get menuEarthquakeHistoryDesc => tr('menuEarthquakeHistoryDesc');
  String get menuEmergencyKit => tr('menuEmergencyKit');
  String get menuEmergencyKitDesc => tr('menuEmergencyKitDesc');
  String get menuEmergencyContacts => tr('menuEmergencyContacts');
  String get menuEmergencyContactsDesc => tr('menuEmergencyContactsDesc');
  String get menuFirstAid => tr('menuFirstAid');
  String get menuFirstAidDesc => tr('menuFirstAidDesc');
  String get menuEarthquakeSafety => tr('menuEarthquakeSafety');
  String get menuEarthquakeSafetyDesc => tr('menuEarthquakeSafetyDesc');
  String get menuSiren => tr('menuSiren');
  String get menuSirenDesc => tr('menuSirenDesc');

  // Settings
  String get dataUpdate => tr('dataUpdate');
  String get autoUpdates => tr('autoUpdates');
  String updateFrequency(int value) => tr('updateFrequency', {'value': '$value'});
  String updateFrequencyLabel(int value) => tr('updateFrequencyLabel', {'value': '$value'});
  String get notifications => tr('notifications');
  String get earthquakeNotifications => tr('earthquakeNotifications');
  String get earthquakeNotificationsDesc => tr('earthquakeNotificationsDesc');
  String minMagnitude(double value) => tr('minMagnitude', {'value': value.toStringAsFixed(1)});
  String get aboutDataService => tr('aboutDataService');
  String get aboutDataServiceDesc => tr('aboutDataServiceDesc');

  // Earthquake alerts
  String newEarthquake(double magnitude) =>
      tr('newEarthquake', {'magnitude': magnitude.toStringAsFixed(1)});
  String earthquakeTitle(double magnitude) =>
      tr('earthquakeTitle', {'magnitude': magnitude.toStringAsFixed(1)});

  // History
  String get earthquakeHistory => tr('earthquakeHistory');
  String get filters => tr('filters');
  String get periodDays => tr('periodDays');
  String periodDaysValue(int value) => tr('periodDaysValue', {'value': '$value'});
  String get minMagnitudeFilter => tr('minMagnitudeFilter');
  String get dangerousEarthquake => tr('dangerousEarthquake');
  String get dangerousEarthquakeTips => tr('dangerousEarthquakeTips');
  String get evacuationMapHint => tr('evacuationMapHint');
  String get evacuationRoutesHint => tr('evacuationRoutesHint');
  String get noEarthquakesTitle => tr('noEarthquakesTitle');
  String noEarthquakesDesc(int days, double magnitude) =>
      tr('noEarthquakesDesc', {
        'days': '$days',
        'magnitude': magnitude.toStringAsFixed(1),
      });
  String get goodSign => tr('goodSign');
  String get locationFailed => tr('locationFailed');
  String get initError => tr('initError');
  String get loadEarthquakesError => tr('loadEarthquakesError');
  String get openEarthquakeInfoError => tr('openEarthquakeInfoError');
  String get earthquakeInfoUnavailable => tr('earthquakeInfoUnavailable');
  String get openInfoError => tr('openInfoError');
  String nearAlmaty(String place) => tr('nearAlmaty', {'place': place});

  // Emergency contacts
  String get emergencyServices => tr('emergencyServices');
  String get mchs => tr('mchs');
  String get mchsDesc => tr('mchsDesc');
  String get police => tr('police');
  String get policeDesc => tr('policeDesc');
  String get ambulance => tr('ambulance');
  String get ambulanceDesc => tr('ambulanceDesc');
  String get gasEmergency => tr('gasEmergency');
  String get gasEmergencyDesc => tr('gasEmergencyDesc');
  String get unifiedEmergency => tr('unifiedEmergency');
  String get unifiedEmergencyDesc => tr('unifiedEmergencyDesc');
  String get importantInfo => tr('importantInfo');
  String get emergencyCallTips => tr('emergencyCallTips');

  // Emergency kit
  String get emergencyKit => tr('emergencyKit');
  String get emergencyKitImportant => tr('emergencyKitImportant');
  String get storagePeriod => tr('storagePeriod');
  String get replacementTips => tr('replacementTips');
  String kitItemName(String id) => tr('kit_$id');
  String kitItemExpiry(String id) => tr('kit_${id}_expiry');
  String kitItemReplacement(String id) => tr('kit_${id}_replacement');
  String kitProgress(int checked, int total) =>
      tr('kitProgress', {'checked': '$checked', 'total': '$total'});

  String get locationPermissionRequired => tr('locationPermissionRequired');
  String get globalEarthquakeMap => tr('globalEarthquakeMap');
  String get androidAlertsBadge => tr('androidAlertsBadge');
  String noEarthquakesGlobalDesc(int days, double magnitude) =>
      tr('noEarthquakesGlobalDesc', {
        'days': '$days',
        'magnitude': magnitude.toStringAsFixed(1),
      });
  String totalEarthquakes(int count) =>
      tr('totalEarthquakes', {'count': '$count'});
  String get magnitudeLegend => tr('magnitudeLegend');
  String earthquakesCount(int count) =>
      tr('earthquakesCount', {'count': '$count'});
  String get citiesWithEvacuationZones => tr('citiesWithEvacuationZones');
  String get buildRoutesHint => tr('buildRoutesHint');
  String get showOnMap => tr('showOnMap');
  String get zoneInfo => tr('zoneInfo');
  String get zonesShort => tr('zonesShort');
  String get unknownPlace => tr('unknownPlace');
  String get dataError => tr('dataError');
  String earthquakePlace(String place) {
    if (place == '__unknown__') return unknownPlace;
    if (place == '__data_error__') return dataError;
    return place;
  }

  // First aid
  String get firstAid => tr('firstAid');
  String get cpr => tr('cpr');
  String get cprDesc => tr('cprDesc');
  String get cprTitle => tr('cprTitle');
  String get cprSteps => tr('cprSteps');
  String get cprStepsTitle => tr('cprStepsTitle');
  String get bleedingControl => tr('bleedingControl');
  String get bleedingControlDesc => tr('bleedingControlDesc');
  String get bleedingControlTitle => tr('bleedingControlTitle');
  String get bleedingControlSteps => tr('bleedingControlSteps');
  String get fractures => tr('fractures');
  String get fracturesDesc => tr('fracturesDesc');
  String get fracturesTitle => tr('fracturesTitle');
  String get fracturesSteps => tr('fracturesSteps');
  String get burns => tr('burns');
  String get burnsDesc => tr('burnsDesc');
  String get burnsTitle => tr('burnsTitle');
  String get burnsSteps => tr('burnsSteps');
  String get poisoning => tr('poisoning');
  String get poisoningDesc => tr('poisoningDesc');
  String get poisoningTitle => tr('poisoningTitle');
  String get poisoningSteps => tr('poisoningSteps');
  String get animalBites => tr('animalBites');
  String get animalBitesDesc => tr('animalBitesDesc');
  String get animalBitesTitle => tr('animalBitesTitle');
  String get animalBitesSteps => tr('animalBitesSteps');

  // Earthquake safety
  String get earthquakeSafety => tr('earthquakeSafety');
  String get duringEarthquake => tr('duringEarthquake');
  String get duringEarthquakeSteps => tr('duringEarthquakeSteps');
  String get afterEarthquake => tr('afterEarthquake');
  String get afterEarthquakeSteps => tr('afterEarthquakeSteps');

  // Siren
  String get siren => tr('siren');
  String get startSiren => tr('startSiren');
  String get stopSiren => tr('stopSiren');
  String get playError => tr('playError');
  String get stopError => tr('stopError');

  // Evacuation map
  String get evacuationZones => tr('evacuationZones');
  String evacuationZonesCity(String city) => tr('evacuationZonesCity', {'city': city});
  String get loadingMap => tr('loadingMap');
  String get selectCity => tr('selectCity');
  String get chooseCity => tr('chooseCity');
  String get chooseNearestCity => tr('chooseNearestCity');
  String zonesCount(int count) => tr('zonesCount', {'count': '$count'});
  String get toggleMapType => tr('toggleMapType');
  String get switchedToGoogleMaps => tr('switchedToGoogleMaps');
  String get switchedToOpenStreetMap => tr('switchedToOpenStreetMap');
  String get locationError => tr('locationError');
  String get evacuationZonesLegend => tr('evacuationZonesLegend');
  String get tapMarkerHint => tr('tapMarkerHint');
  String get googleMaps => tr('googleMaps');
  String cityLabel(String city) => tr('cityLabel', {'city': city});
  String evacuationZonesInCity(String city) =>
      tr('evacuationZonesInCity', {'city': city});
  String get googleMapsIntegrationHint => tr('googleMapsIntegrationHint');
  String get showEvacuationZonesList => tr('showEvacuationZonesList');
  String get navigationLocationError => tr('navigationLocationError');
  String get navigationLaunchError => tr('navigationLaunchError');

  // Cities & zones
  String cityName(String id) => tr('city_$id');
  String zoneName(String id) => tr('zone_${id}_name');
  String zoneDescription(String id) => tr('zone_${id}_desc');
  String zoneType(String typeKey) => tr('zoneType_$typeKey');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['kk', 'ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

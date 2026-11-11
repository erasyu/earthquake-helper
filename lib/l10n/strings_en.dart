const Map<String, String> stringsEn = {
  'appTitle': 'Earthquake Helper',
  'settings': 'Settings',
  'saveSettings': 'Save settings',
  'settingsSaved': 'Settings saved',
  'close': 'Close',
  'moreDetails': 'Details',
  'cancel': 'Cancel',
  'apply': 'Apply',
  'error': 'Error',
  'or': 'or',
  'important': 'Important!',
  'call': 'Call',
  'route': 'Route',
  'onMap': 'On map',
  'type': 'Type',
  'place': 'Location',
  'time': 'Time',
  'depth': 'Depth',
  'coordinates': 'Coordinates',
  'source': 'Source',
  'days': 'days',
  'newLabel': 'New',
  'km': 'km',
  'minutes': 'min',

  'language': 'Language',
  'languageKk': 'Kazakh',
  'languageRu': 'Russian',
  'languageEn': 'English',

  'menuEvacuationMap': 'Evacuation zones map',
  'menuEvacuationMapDesc': 'View evacuation zones in your city',
  'menuEarthquakeHistory': 'Earthquake history',
  'menuEarthquakeHistoryDesc': 'Recent earthquakes in the region',
  'menuEmergencyKit': 'Emergency kit',
  'menuEmergencyKitDesc': 'List of essential items',
  'menuEmergencyContacts': 'Emergency services',
  'menuEmergencyContactsDesc': 'Emergency contact numbers',
  'menuFirstAid': 'First aid',
  'menuFirstAidDesc': 'First aid instructions',
  'menuEarthquakeSafety': 'What to do during an earthquake',
  'menuEarthquakeSafetyDesc': 'Safety instructions for you',
  'menuSiren': 'Alert siren',
  'menuSirenDesc': 'Enable sound alert',

  'dataUpdate': 'Data updates',
  'autoUpdates': 'Updates run automatically',
  'updateFrequency': 'Update frequency: {value} minutes',
  'updateFrequencyLabel': '{value} min',
  'notifications': 'Notifications',
  'earthquakeNotifications': 'Earthquake notifications',
  'earthquakeNotificationsDesc': 'Receive notifications about new earthquakes',
  'minMagnitude': 'Minimum magnitude for notifications: {value}',
  'aboutDataService': 'About data service',
  'aboutDataServiceDesc':
      'The app uses Android Earthquake Alerts System data to get earthquake information in Kazakhstan.',

  'newEarthquake': 'New earthquake M{magnitude}',
  'earthquakeTitle': 'Earthquake M{magnitude}',

  'earthquakeHistory': 'Earthquake history',
  'filters': 'Filters',
  'periodDays': 'Period (days):',
  'periodDaysValue': '{value} days',
  'minMagnitudeFilter': 'Minimum magnitude:',
  'dangerousEarthquake': '⚠️ Dangerous earthquake!',
  'dangerousEarthquakeTips':
      '• Take cover in a safe place\n• Stay away from windows\n• Follow emergency service instructions',
  'evacuationMapHint':
      'For evacuation zone information, go to "Evacuation zones map"',
  'evacuationRoutesHint':
      'Routes to evacuation zones\nare available in\n"Evacuation zones map"',
  'noEarthquakesTitle':
      'No earthquakes with magnitude ≥ {magnitude}\nregistered in Kazakhstan\nin the last {days} days',
  'noEarthquakesDesc':
      'No earthquakes with magnitude ≥ {magnitude}\nregistered in Kazakhstan\nin the last {days} days',
  'noEarthquakesGlobalDesc':
      'No earthquakes with magnitude ≥ {magnitude}\nregistered in the last {days} days',
  'goodSign': 'That is a good sign!',
  'locationFailed': 'Could not determine location',
  'locationPermissionRequired': 'Location permission is required',
  'initError': 'Initialization error',
  'loadEarthquakesError': 'Could not load earthquake data',
  'openEarthquakeInfoError': 'Could not open earthquake information',
  'earthquakeInfoUnavailable': 'Earthquake information unavailable',
  'openInfoError': 'Error opening information',
  'nearAlmaty': '{place} 🏙️ (near Almaty)',
  'unknownPlace': 'Unknown location',
  'dataError': 'Data error',

  'globalEarthquakeMap': 'Global earthquake map',
  'androidAlertsBadge': 'Android Alerts',
  'totalEarthquakes': 'Total earthquakes: {count}',
  'magnitudeLegend': 'Magnitude:',
  'earthquakesCount': 'Earthquakes: {count}',
  'citiesWithEvacuationZones': 'Cities with evacuation zones',
  'buildRoutesHint':
      'To build routes, go to the "Evacuation zones map" section',
  'showOnMap': 'Show on map',
  'zoneInfo': 'Zone information',
  'zonesShort': 'Zones',

  'notificationChannelName': 'Earthquakes',
  'notificationChannelDesc': 'Earthquake notifications',
  'notificationMagnitudePlace': 'Magnitude: {magnitude}\nLocation: {place}',

  'emergencyServices': 'Emergency services',
  'mchs': 'Emergency services',
  'mchsDesc': 'Rescue and fire service',
  'police': 'Police',
  'policeDesc': 'Law enforcement',
  'ambulance': 'Ambulance',
  'ambulanceDesc': 'Medical assistance',
  'gasEmergency': 'Gas emergency service',
  'gasEmergencyDesc': 'Gas emergency service',
  'unifiedEmergency': 'Unified emergency number',
  'unifiedEmergencyDesc': 'Single number for all emergency services',
  'importantInfo': 'Important information',
  'emergencyCallTips':
      '• Emergency calls are free\n• Stay calm when calling\n• Clearly describe the problem and your location\n• Do not hang up until the call is finished',

  'emergencyKit': 'Emergency kit',
  'emergencyKitImportant':
      '• Check expiry dates regularly\n• Replace expired items\n• Keep the kit in an easily accessible place\n• Update documents when details change\n• Check that equipment works',
  'storagePeriod': 'Storage period:',
  'replacementTips': 'Replacement recommendations:',
  'kitProgress': '{checked} / {total}',

  'kit_first_aid': 'First aid kit',
  'kit_first_aid_expiry': 'Check every 6 months',
  'kit_first_aid_replacement': 'Replace expired medicines',
  'kit_flashlight': 'Flashlight and spare batteries',
  'kit_flashlight_expiry': 'Batteries last 2-3 years',
  'kit_flashlight_replacement': 'Replace dead batteries',
  'kit_radio': 'Battery-powered radio',
  'kit_radio_expiry': 'Batteries last 2-3 years',
  'kit_radio_replacement': 'Replace dead batteries',
  'kit_whistle': 'Whistle',
  'kit_whistle_expiry': 'Unlimited storage',
  'kit_whistle_replacement': 'Replace if damaged',
  'kit_gas_mask': 'Gas mask',
  'kit_gas_mask_expiry': 'Check every 3 months',
  'kit_gas_mask_replacement': 'Replace if damaged or expired',
  'kit_water': 'Water supply (2 liters per person)',
  'kit_water_expiry': 'Store for 6 months',
  'kit_water_replacement': 'Replace when expired',
  'kit_canned_food': 'Canned food',
  'kit_canned_food_expiry': 'Store for 1-2 years',
  'kit_canned_food_replacement': 'Replace when expired',
  'kit_dry_food': 'Dry food',
  'kit_dry_food_expiry': 'Store for 6-12 months',
  'kit_dry_food_replacement': 'Replace when expired',
  'kit_matches': 'Waterproof matches',
  'kit_matches_expiry': 'Store for 2-3 years',
  'kit_matches_replacement': 'Replace if wet',
  'kit_warm_clothes': 'Warm clothes',
  'kit_warm_clothes_expiry': 'Unlimited storage',
  'kit_warm_clothes_replacement': 'Replace when worn out',
  'kit_raincoat': 'Raincoat',
  'kit_raincoat_expiry': 'Store for 2-3 years',
  'kit_raincoat_replacement': 'Replace if damaged',
  'kit_hygiene': 'Hygiene supplies',
  'kit_hygiene_expiry': 'Store for 1-2 years',
  'kit_hygiene_replacement': 'Replace when expired',
  'kit_documents': 'Documents (copies)',
  'kit_documents_expiry': 'Update when changed',
  'kit_documents_replacement': 'Update when details change',
  'kit_money': 'Cash',
  'kit_money_expiry': 'Check every 3 months',
  'kit_money_replacement': 'Update as needed',
  'kit_charger': 'Phone charger',
  'kit_charger_expiry': 'Check every 3 months',
  'kit_charger_replacement': 'Replace if faulty',

  'firstAid': 'First medical aid',
  'cpr': 'Cardiopulmonary resuscitation (CPR)',
  'cprDesc': 'Instructions for performing CPR.',
  'cprTitle': 'Cardiopulmonary resuscitation',
  'cprStepsTitle': 'How to perform CPR:',
  'cprSteps':
      '1. Make sure the area is safe for you and the victim.\n'
      '2. Check the victim\'s response (tap and ask).\n'
      '3. If no response, call an ambulance (or ask someone to do it).\n'
      '4. Start chest compressions:\n'
      '   - Place your hands one on top of the other in the center of the chest.\n'
      '   - Perform 30 compressions at 100-120 per minute.\n'
      '5. Give 2 breaths mouth-to-mouth while pinching the nose.\n'
      '6. Continue until help arrives or signs of life appear.',
  'bleedingControl': 'Bleeding control',
  'bleedingControlDesc': 'How to stop bleeding.',
  'bleedingControlTitle': 'Bleeding control',
  'bleedingControlSteps':
      '1. Make sure you are safe.\n'
      '2. Press the wound with clean cloth or bandage.\n'
      '3. If bleeding continues, apply a tight bandage above the wound (tourniquet).\n'
      '4. Do not remove the first bandage if soaked — add a new one on top.\n'
      '5. Call an ambulance.',
  'fractures': 'Fractures and injuries',
  'fracturesDesc': 'How to immobilize an injured limb.',
  'fracturesTitle': 'Fractures and injuries',
  'fracturesSteps':
      '1. Make sure you and the victim are safe.\n'
      '2. Do not try to realign the bone.\n'
      '3. Immobilize the fracture area with a splint (stick, board, or folded cloth).\n'
      '4. If there is an open wound, cover it with clean cloth to prevent infection.\n'
      '5. Apply a cold compress to reduce swelling.\n'
      '6. Call an ambulance or take the victim to hospital.',
  'burns': 'Burns',
  'burnsDesc': 'First aid for burns.',
  'burnsTitle': 'First aid for burns',
  'burnsSteps':
      '1. Cool the burn with cold water (10-20 minutes).\n'
      '2. Do not use oils or ointments without medical advice.\n'
      '3. Cover the burn with a sterile moist bandage.\n'
      '4. For severe burns, call an ambulance.',
  'poisoning': 'Poisoning',
  'poisoningDesc': 'What to do in case of poisoning.',
  'poisoningTitle': 'First aid for poisoning',
  'poisoningSteps':
      '1. Make sure the victim is in a safe environment.\n'
      '2. Call an ambulance.\n'
      '3. If poison was swallowed, do not induce vomiting without medical advice.\n'
      '4. If toxic gas was inhaled, move the victim to fresh air.\n'
      '5. Monitor breathing and consciousness.',
  'animalBites': 'Animal bites',
  'animalBitesDesc': 'How to treat bites and wounds.',
  'animalBitesTitle': 'First aid for animal bites',
  'animalBitesSteps':
      '1. Wash the wound with soap and water (at least 10 minutes).\n'
      '2. Treat the wound with antiseptic.\n'
      '3. Apply a sterile bandage.\n'
      '4. See a doctor for rabies vaccination.\n'
      '5. Watch for signs of infection: redness, swelling, pain.',

  'earthquakeSafety': 'What to do during an earthquake',
  'duringEarthquake': 'How to act during an earthquake:',
  'duringEarthquakeSteps':
      '1. Stay calm. Try not to panic.\n'
      '2. If you are indoors:\n'
      '   - Drop to the floor and cover your head with your hands or a pillow.\n'
      '   - Stay under sturdy tables or in room corners.\n'
      '   - Stay away from windows, mirrors, and heavy objects.\n'
      '3. If you are outdoors:\n'
      '   - Move away from buildings, power lines, and trees.\n'
      '   - Find open space and crouch to avoid falling.\n'
      '4. If you are in a car:\n'
      '   - Stop away from buildings, bridges, and tunnels.\n'
      '   - Stay in the car until shaking stops.\n'
      '5. Be ready for aftershocks.',
  'afterEarthquake': 'After an earthquake:',
  'afterEarthquakeSteps':
      '1. Check yourself and others for injuries. Provide first aid if needed.\n'
      '2. Leave the building if damaged, but avoid elevators.\n'
      '3. Use the phone only for emergency calls.\n'
      '4. Watch for gas leaks, broken wires, and other hazards.\n'
      '5. Follow local authorities and stay in a safe area.',

  'siren': 'Alert siren',
  'startSiren': 'Start siren',
  'stopSiren': 'Stop siren',
  'playError': 'Playback error',
  'stopError': 'Stop error',

  'evacuationZones': 'Evacuation zones',
  'evacuationZonesCity': 'Evacuation zones - {city}',
  'loadingMap': 'Loading map...',
  'selectCity': 'Select city',
  'chooseCity': 'Choose city',
  'chooseNearestCity': 'Choose nearest city',
  'zonesCount': 'Number of evacuation zones: {count}',
  'toggleMapType': 'Switch map type',
  'switchedToGoogleMaps': 'Switched to Google Maps',
  'switchedToOpenStreetMap': 'Switched to OpenStreetMap',
  'locationError': 'Could not get location',
  'evacuationZonesLegend': '📌 - Evacuation zones',
  'tapMarkerHint': 'Tap a marker for details and route',
  'googleMaps': 'Google Maps',
  'cityLabel': 'City: {city}',
  'evacuationZonesInCity': 'Evacuation zones in {city}',
  'googleMapsIntegrationHint':
      'Full Google Maps integration\nrequires a Google Maps API key',
  'showEvacuationZonesList': 'Show evacuation zones list',
  'navigationLocationError': 'Could not determine your location for navigation',
  'navigationLaunchError':
      'Could not start navigation. Please install Google or Yandex Maps.',

  'zoneType_park': 'Park',
  'zoneType_stadium': 'Stadium',
  'zoneType_school': 'School',
  'zoneType_hospital': 'Hospital',
  'zoneType_square': 'Square',

  'city_almaty': 'Almaty',
  'city_astana': 'Astana',
  'city_shymkent': 'Shymkent',
  'city_atyrau': 'Atyrau',
  'city_karaganda': 'Karaganda',

  'zone_park_panfilov_name': '28 Panfilov Guardsmen Park',
  'zone_park_panfilov_desc':
      'Large park with open area, safe evacuation zone. Water available.',
  'zone_central_stadium_name': 'Central Stadium',
  'zone_central_stadium_desc':
      'Open area, capacity up to 20,000 people. Medical post and water supplies.',
  'zone_first_president_park_name': 'First President Park',
  'zone_first_president_park_desc': 'Large open area with first aid points.',
  'zone_republic_square_name': 'Republic Square',
  'zone_republic_square_desc':
      'Large open square in the city center with quick access to emergency services.',
  'zone_baum_grove_name': 'Baum Grove',
  'zone_baum_grove_desc': 'Large park with open areas suitable for temporary shelter.',
  'zone_school_15_name': 'School No. 15',
  'zone_school_15_desc':
      'Reinforced building with open stadium. Water and medicine supplies.',
  'zone_hospital_7_name': 'Hospital No. 7',
  'zone_hospital_7_desc': 'Medical center capable of emergency care.',
  'zone_peace_park_name': 'Peace Park',
  'zone_peace_park_desc': 'Large park with open area and first aid points.',
  'zone_astana_arena_name': 'Astana Arena Stadium',
  'zone_astana_arena_desc':
      'Open area, capacity up to 30,000 people. Equipped with shelters.',
  'zone_independence_square_name': 'Independence Square',
  'zone_independence_square_desc':
      'Central square with quick access to emergency services.',
  'zone_president_park_name': 'Presidential Park',
  'zone_president_park_desc': 'Extensive area with open spaces.',
  'zone_school_73_name': 'School No. 73',
  'zone_school_73_desc': 'School with large stadium and sports hall.',
  'zone_hospital_2_name': 'City Hospital No. 2',
  'zone_hospital_2_desc':
      'Hospital with medicine supplies and staff for emergency care.',
  'zone_abay_park_name': 'Abay Park',
  'zone_abay_park_desc': 'Central city park with water supply points.',
  'zone_kazhymukan_stadium_name': 'Kazymukan Stadium',
  'zone_kazhymukan_stadium_desc': 'Open area with first aid points.',
  'zone_dendropark_name': 'Dendropark',
  'zone_dendropark_desc':
      'Large green area with open sections for temporary shelter.',
  'zone_ordabasy_square_name': 'Ordabasy Square',
  'zone_ordabasy_square_desc':
      'Central square with quick access to emergency services.',
  'zone_school_45_name': 'School No. 45',
  'zone_school_45_desc': 'School with large territory and sports complex.',
  'zone_regional_hospital_name': 'Regional Hospital',
  'zone_regional_hospital_desc':
      'Medical facility capable of helping many victims.',
  'zone_atyrau_central_park_name': 'Central Park',
  'zone_atyrau_central_park_desc': 'Main city park with open areas.',
  'zone_munayshi_stadium_name': 'Munayshi Stadium',
  'zone_munayshi_stadium_desc': 'Large stadium with capacity up to 15,000 people.',
  'zone_atyrau_hospital_name': 'City Hospital No. 1',
  'zone_atyrau_hospital_desc': 'Hospital with emergency department and medicine supplies.',
  'zone_atyrau_school_name': 'School No. 23',
  'zone_atyrau_school_desc': 'Educational institution with large yard.',
  'zone_karaganda_park_name': 'Central Park',
  'zone_karaganda_park_desc': 'Large green area in the city center.',
  'zone_shakhtyor_stadium_name': 'Shakhtyor Stadium',
  'zone_shakhtyor_stadium_desc': 'Football stadium with open field.',
  'zone_karaganda_square_name': 'Independence Square',
  'zone_karaganda_square_desc':
      'Central square with quick access to emergency services.',
  'zone_karaganda_hospital_name': 'Regional Hospital',
  'zone_karaganda_hospital_desc': 'Large medical facility with emergency department.',
};

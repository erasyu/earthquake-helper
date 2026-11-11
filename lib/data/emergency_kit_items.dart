/// Идентификаторы предметов тревожного чемодана (единый источник для приложения и виджета).
const emergencyKitItemIds = [
  'first_aid',
  'flashlight',
  'radio',
  'whistle',
  'gas_mask',
  'water',
  'canned_food',
  'dry_food',
  'matches',
  'warm_clothes',
  'raincoat',
  'hygiene',
  'documents',
  'money',
  'charger',
];

String emergencyKitPrefsKey(String id) => 'emergency_kit_$id';

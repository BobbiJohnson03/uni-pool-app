import 'package:hive/hive.dart';
part 'device_model.g.dart';

/*
model zawierający informacje o urządzeniu, z którego ktoś bierze udział w głosowaniu, służy
 do identyfikacji użytkownika bez potrzeby tworzenia kont

pozwala nam zidentyfikować urządzenie, np.:
- z danego urządzenia już oddano głos
- ten użytkownik to ta sama osoba, co poprzednio
- ten głos pochodzi z urządzenia "device_000000"       */
@HiveType(typeId: 5)
class DeviceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String model;

  @HiveField(2)
  String brand;

  @HiveField(3)
  String androidVersion;

  @HiveField(4)
  String fingerprint;

  DeviceModel({
    required this.id,
    required this.model,
    required this.brand,
    required this.androidVersion,
    required this.fingerprint,
  });

  /* zamienia obiekt Dart na słownik/mapę, przydatne do eksportu danych (np. do pliku JSON),
 przesyłania przez sieć (jeśli byłby backend), podglądu/debugowania danych */
  Map<String, dynamic> toJson() => {
    'id': id,
    'model': model,
    'brand': brand,
    'androidVersion': androidVersion,
    'fingerprint': fingerprint,
  };

  /* rekonstrukcja obiektu z JSON — np. po skanowaniu kodu QR, pobraniu danych z pliku, czy po stronie serwera */
  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
    id: json['id'],
    model: json['model'],
    brand: json['brand'],
    androidVersion: json['androidVersion'],
    fingerprint: json['fingerprint'],
  );
}

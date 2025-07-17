import 'package:hive/hive.dart';

part 'device_model.g.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'model': model,
    'brand': brand,
    'androidVersion': androidVersion,
    'fingerprint': fingerprint,
  };

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
    id: json['id'],
    model: json['model'],
    brand: json['brand'],
    androidVersion: json['androidVersion'],
    fingerprint: json['fingerprint'],
  );
}

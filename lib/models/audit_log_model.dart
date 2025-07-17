import 'package:hive/hive.dart';

part 'audit_log_model.g.dart';

@HiveType(typeId: 6)
class AuditLogModel extends HiveObject {
  @HiveField(0)
  String action;

  @HiveField(1)
  String sessionId;

  @HiveField(2)
  String deviceId;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String? details;

  AuditLogModel({
    required this.action,
    required this.sessionId,
    required this.deviceId,
    required this.timestamp,
    this.details,
  });

  Map<String, dynamic> toJson() => {
    'action': action,
    'sessionId': sessionId,
    'deviceId': deviceId,
    'timestamp': timestamp.toIso8601String(),
    'details': details,
  };

  factory AuditLogModel.fromJson(Map<String, dynamic> json) => AuditLogModel(
    action: json['action'],
    sessionId: json['sessionId'],
    deviceId: json['deviceId'],
    timestamp: DateTime.parse(json['timestamp']),
    details: json['details'],
  );
}

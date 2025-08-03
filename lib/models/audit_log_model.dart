import 'package:hive/hive.dart';
part 'audit_log_model.g.dart';

/* model przeznaczony do pojedynczego wpisu =  audyt logu, ślad działania użytkownika lub systemu
np "urządzenie X wykonało akcję Y o godzinie Z w ramach sesji S, a dodatkowe info to D" */

@HiveType(typeId: 6)
class AuditLogModel extends HiveObject {
  @HiveField(0)
  String action; // action = krótka nazwa czynności, np. 'vote_submitted', 'session_closed'.

  @HiveField(1)
  String sessionId; // id dla danej sesji

  @HiveField(2)
  String deviceId; // id urządzenia, które wykonało daną akcję

  @HiveField(3)
  DateTime timestamp; // dokładna data i godzina wykonanej akcji

  @HiveField(4)
  String? details; // opcjonalne dodatkowe informacje, np. "selectedOptions": ["A", "B"]

  AuditLogModel({
    required this.action,
    required this.sessionId,
    required this.deviceId,
    required this.timestamp,
    this.details,
  });

  // serializacja do json żeby zapisać log jako tekst (przydatne np do eksportu do pliku)
  Map<String, dynamic> toJson() => {
    'action': action,
    'sessionId': sessionId,
    'deviceId': deviceId,
    'timestamp': timestamp.toIso8601String(),
    'details': details,
  };

  //factory constructor, pozwala stworzyć nowy obiekt AuditLogModel na podstawie danych JSON
  factory AuditLogModel.fromJson(Map<String, dynamic> json) => AuditLogModel(
    action: json['action'],
    sessionId: json['sessionId'],
    deviceId: json['deviceId'],
    timestamp: DateTime.parse(json['timestamp']),
    details: json['details'],
  );
}

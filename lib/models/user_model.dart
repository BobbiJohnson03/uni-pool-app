import 'package:hive/hive.dart';
part 'user_model.g.dart';

/* model reprezentujący uczestnika sesji - śledzi kto dołączył do sesji, z jakiego urządzenia 
i czy jest administratorem, dzięki temu możemy:

- rozróżniać admina i głosujących,
- sprawdzić, kto był aktywny i kiedy,
-przechowywać dane uczestników bez kont użytkowników  */

@HiveType(typeId: 3)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String deviceId;

  @HiveField(2)
  String? name;

  @HiveField(3)
  bool isAdmin;

  @HiveField(4)
  DateTime joinedAt;

  @HiveField(5)
  String sessionId;

  @HiveField(6)
  DateTime? lastActivity;

  UserModel({
    required this.id,
    required this.deviceId,
    this.name,
    required this.isAdmin,
    required this.joinedAt,
    required this.sessionId,
    this.lastActivity,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    'name': name,
    'isAdmin': isAdmin,
    'joinedAt': joinedAt.toIso8601String(),
    'sessionId': sessionId,
    'lastActivity': lastActivity?.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    deviceId: json['deviceId'],
    name: json['name'],
    isAdmin: json['isAdmin'],
    joinedAt: DateTime.parse(json['joinedAt']),
    sessionId: json['sessionId'],
    lastActivity:
        json['lastActivity'] != null
            ? DateTime.parse(json['lastActivity'])
            : null,
  );
  bool validate() {
    return id.isNotEmpty && deviceId.isNotEmpty && sessionId.isNotEmpty;
  }
}

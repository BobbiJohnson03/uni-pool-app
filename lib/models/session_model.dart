import 'package:hive/hive.dart';
import 'question_model.dart';

part 'session_model.g.dart';

@HiveType(typeId: 0)
class SessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isAnonymous;

  @HiveField(3)
  List<QuestionModel> questions;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? endsAt;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  String adminDeviceId;

  @HiveField(8)
  bool autoClose;

  @HiveField(9)
  int? maxParticipants;

  @HiveField(10)
  bool showResultsAfterVoting;

  @HiveField(11)
  List<String> participantDeviceIds;

  @HiveField(12)
  bool isValid;

  @HiveField(13)
  DateTime? lastModified;

  SessionModel({
    required this.id,
    required this.title,
    required this.isAnonymous,
    required this.questions,
    required this.createdAt,
    this.endsAt,
    this.isActive = true,
    required this.adminDeviceId,
    this.autoClose = false,
    this.maxParticipants,
    this.showResultsAfterVoting = true,
    this.participantDeviceIds = const [],
    this.isValid = true,
    this.lastModified,
  });

  bool get isExpired => endsAt != null && DateTime.now().isAfter(endsAt!);
  bool get isOpenForVoting => isActive && !isExpired;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isAnonymous': isAnonymous,
    'questions': questions.map((q) => q.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'endsAt': endsAt?.toIso8601String(),
    'isActive': isActive,
    'adminDeviceId': adminDeviceId,
    'autoClose': autoClose,
    'maxParticipants': maxParticipants,
    'showResultsAfterVoting': showResultsAfterVoting,
    'participantDeviceIds': participantDeviceIds,
    'isValid': isValid,
    'lastModified': lastModified?.toIso8601String(),
  };

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    id: json['id'],
    title: json['title'],
    isAnonymous: json['isAnonymous'],
    questions:
        (json['questions'] as List)
            .map((q) => QuestionModel.fromJson(q))
            .toList(),
    createdAt: DateTime.parse(json['createdAt']),
    endsAt: json['endsAt'] != null ? DateTime.parse(json['endsAt']) : null,
    isActive: json['isActive'] ?? true,
    adminDeviceId: json['adminDeviceId'],
    autoClose: json['autoClose'] ?? false,
    maxParticipants: json['maxParticipants'],
    showResultsAfterVoting: json['showResultsAfterVoting'] ?? true,
    participantDeviceIds:
        (json['participantDeviceIds'] as List?)?.cast<String>() ?? [],
    isValid: json['isValid'] ?? true,
    lastModified:
        json['lastModified'] != null
            ? DateTime.parse(json['lastModified'])
            : null,
  );

  bool hasVoted(String deviceId) {
    return participantDeviceIds.contains(deviceId);
  }

  void markAsVoted(String deviceId) {
    if (!participantDeviceIds.contains(deviceId)) {
      participantDeviceIds.add(deviceId);
      lastModified = DateTime.now();
      save(); // Hive: save the change
    }
  }

  bool validate() {
    return id.isNotEmpty && title.isNotEmpty && questions.isNotEmpty;
  }
}

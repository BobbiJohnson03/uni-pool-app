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

  SessionModel({
    required this.id,
    required this.title,
    required this.isAnonymous,
    required this.questions,
  });
}

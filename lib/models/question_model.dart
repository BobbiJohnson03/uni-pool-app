import 'package:hive/hive.dart';

part 'question_model.g.dart';

@HiveType(typeId: 1)
class QuestionModel extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  String answerType; // 'yes_no', 'yes_no_abstain', 'multiple_choice'

  @HiveField(2)
  List<String>? options; // tylko dla multiple_choice

  @HiveField(3)
  int? maxSelectable; // tylko dla multiple_choice

  QuestionModel({
    required this.text,
    required this.answerType,
    this.options,
    this.maxSelectable,
  });
}

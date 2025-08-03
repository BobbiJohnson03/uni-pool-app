import 'package:hive/hive.dart';

part 'question_model.g.dart';

/*
model pytania 
*/

@HiveType(typeId: 1)
class QuestionModel extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  String answerType; // enum   e.g. 'singleChoice', 'multipleChoice', 'yesNo', etc.

  @HiveField(2)
  List<String>? options;

  @HiveField(3)
  int? maxSelectable;

  QuestionModel({
    required this.text,
    required this.answerType,
    this.options,
    this.maxSelectable,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'answerType': answerType,
    'options': options,
    'maxSelectable': maxSelectable,
  };

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    text: json['text'],
    answerType: json['answerType'],
    options: (json['options'] as List?)?.cast<String>(),
    maxSelectable: json['maxSelectable'],
  );
}

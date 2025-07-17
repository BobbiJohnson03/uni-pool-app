import 'package:hive/hive.dart';

part 'result_model.g.dart';

@HiveType(typeId: 4)
class ResultModel extends HiveObject {
  @HiveField(0)
  String sessionId;

  @HiveField(1)
  int questionIndex;

  @HiveField(2)
  String option;

  @HiveField(3)
  int count;

  ResultModel({
    required this.sessionId,
    required this.questionIndex,
    required this.option,
    required this.count,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'questionIndex': questionIndex,
    'option': option,
    'count': count,
  };

  factory ResultModel.fromJson(Map<String, dynamic> json) => ResultModel(
    sessionId: json['sessionId'],
    questionIndex: json['questionIndex'],
    option: json['option'],
    count: json['count'],
  );
}

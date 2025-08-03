import 'package:hive/hive.dart';
part 'result_model.g.dart';

/*
model przechowuje informację o liczbie głosów oddanych na konkretną odpowiedź 
w konkretnym pytaniu danej sesji.   */
@HiveType(typeId: 4)
class ResultModel extends HiveObject {
  @HiveField(0)
  String sessionId; // ID sesji do której należy pytanie i wynik

  @HiveField(1)
  int questionIndex; // indeks pytania w liście SessionModel.questions

  @HiveField(2)
  String option; //konkretna odpowiedź, np. "TAK", "NIE", "A"

  @HiveField(3)
  int count; // liczba osób, które wybrały tę opcję

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

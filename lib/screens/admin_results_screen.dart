import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../models/question_model.dart';

class AdminResultsScreen extends StatelessWidget {
  const AdminResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final session = ModalRoute.of(context)!.settings.arguments as SessionModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Wyniki głosowania')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              session.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Tryb: ${session.isAnonymous ? "Tajne" : "Jawne"}'),
            const SizedBox(height: 16),
            const Text(
              'Pytania:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...session.questions.map(
              (question) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.text,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (question.options?.isNotEmpty ?? false)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              question.options!
                                  .map((option) => Text('• $option'))
                                  .toList(),
                        ),
                      // TUTAJ NASTĄPIŁA POPRAWKA
                      if ((question.maxSelectable ?? 1) > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Maksymalna liczba wyborów: ${question.maxSelectable}', // TUTAJ TEŻ POPRAWKA
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

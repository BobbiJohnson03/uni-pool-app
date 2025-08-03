import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/session_model.dart';
import '../models/question_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _questionTextController = TextEditingController();
  final _optionController = TextEditingController();
  List<String> currentOptions = [];
  String answerType = 'yes_no';
  int maxSelectable = 1;
  bool isAnonymous = true;

  List<QuestionModel> questions = [];

  final _random = Random();

  String _generateShortCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  void _addQuestion() {
    if (_questionTextController.text.trim().isEmpty) return;

    final question = QuestionModel(
      text: _questionTextController.text.trim(),
      answerType: answerType,
      options:
          answerType == 'multiple_choice' ? List.from(currentOptions) : null,
      maxSelectable: answerType == 'multiple_choice' ? maxSelectable : null,
    );

    setState(() {
      questions.add(question);
      _questionTextController.clear();
      _optionController.clear();
      currentOptions.clear();
      answerType = 'yes_no';
      maxSelectable = 1;
    });
  }

  void _createSession() async {
    if (_formKey.currentState!.validate() && questions.isNotEmpty) {
      final session = SessionModel(
        id: _generateShortCode(),
        title: _titleController.text.trim(),
        isAnonymous: isAnonymous,
        questions: questions,
        createdAt: DateTime.now(),
        adminDeviceId: 'device123', // Możesz zamienić na realne ID urządzenia
      );

      final box = await Hive.openBox<SessionModel>('sessions');
      await box.put(session.id, session);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sesja została utworzona! Kod: ${session.id}')),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/admin_dashboard',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowa sesja głosowania')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tytuł sesji'),
                validator:
                    (value) => value!.isEmpty ? 'Podaj tytuł sesji' : null,
              ),
              SwitchListTile(
                title: const Text('Czy głosowanie ma być anonimowe?'),
                value: isAnonymous,
                onChanged: (val) => setState(() => isAnonymous = val),
              ),
              const Divider(),
              const Text('Dodaj pytanie:'),
              TextFormField(
                controller: _questionTextController,
                decoration: const InputDecoration(labelText: 'Treść pytania'),
              ),
              DropdownButton<String>(
                value: answerType,
                items: const [
                  DropdownMenuItem(value: 'yes_no', child: Text('TAK / NIE')),
                  DropdownMenuItem(
                    value: 'yes_no_abstain',
                    child: Text('TAK / NIE / WSTRZYMUJĘ SIĘ'),
                  ),
                  DropdownMenuItem(
                    value: 'multiple_choice',
                    child: Text('Lista opcji z limitem'),
                  ),
                ],
                onChanged: (val) => setState(() => answerType = val!),
              ),
              if (answerType == 'multiple_choice') ...[
                TextFormField(
                  controller: _optionController,
                  decoration: const InputDecoration(labelText: 'Dodaj opcję'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_optionController.text.trim().isNotEmpty) {
                      setState(() {
                        currentOptions.add(_optionController.text.trim());
                        _optionController.clear();
                      });
                    }
                  },
                  child: const Text('Dodaj opcję'),
                ),
                Wrap(
                  spacing: 8,
                  children:
                      currentOptions
                          .map((opt) => Chip(label: Text(opt)))
                          .toList(),
                ),
                Row(
                  children: [
                    const Text('Limit wyboru:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value:
                          maxSelectable > currentOptions.length
                              ? currentOptions.length
                              : maxSelectable,
                      items:
                          List.generate(currentOptions.length, (i) => i + 1)
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text('$v'),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => maxSelectable = v!),
                    ),
                  ],
                ),
              ],
              ElevatedButton(
                onPressed: _addQuestion,
                child: const Text('Dodaj pytanie'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text('Dodane pytania:'),
              ...questions.asMap().entries.map(
                (e) => ListTile(
                  leading: Text('Pytanie ${e.key + 1}:'),
                  title: Text(e.value.text),
                  subtitle: Text('Typ: ${e.value.answerType}'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createSession,
                child: const Text('Utwórz sesję'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

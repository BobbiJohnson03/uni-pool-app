import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../models/question_model.dart';
import '../models/vote_model.dart';
import '../network/websocket_client.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final Map<int, dynamic> answers = {};
  bool isSubmitting = false;

  late String deviceId;
  WebSocketVoteClient? wsClient;
  late SessionModel session;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null || args['session'] == null) {
      _showErrorDialog("Brak danych sesji.");
      return;
    }

    session = args['session'] as SessionModel;
    deviceId = args['deviceId'] ?? _generateDeviceId();
    wsClient = args['webSocketClient'];

    wsClient?.onMessage = _handleServerResponse;
    wsClient?.onError = (e) => _showErrorDialog('Błąd połączenia: $e');

    _checkSessionStatus();
  }

  String _generateDeviceId() {
    final random = Random();
    return 'device_${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  void _checkSessionStatus() {
    if (!session.isOpenForVoting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionClosedDialog();
      });
    }
  }

  Future<void> _submitVote() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    try {
      final vote = VoteModel(
        sessionId: session.id,
        userId: null,
        answers: Map.fromEntries(
          answers.entries.map((e) => MapEntry(e.key.toString(), e.value)),
        ),

        timestamp: DateTime.now(),
        deviceId: deviceId,
        encryptionKey: 'tajne-glosowanie',
      );

      if (wsClient != null) {
        wsClient!.sendVote(vote.toJson());
      } else {
        // Tryb offline – zapisz lokalnie?
        _showVoteSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('Błąd: $e');
      setState(() => isSubmitting = false);
    }
  }

  void _handleServerResponse(String data) {
    final json = jsonDecode(data);
    switch (json['type']) {
      case 'confirmation':
        _showVoteSuccessDialog();
        break;
      case 'error':
        _showErrorDialog(json['message']);
        break;
      default:
        print('Nieznany komunikat z serwera.');
    }
    setState(() => isSubmitting = false);
  }

  void _showSessionClosedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Sesja niedostępna'),
            content: Text(
              session.isExpired
                  ? 'Sesja wygasła.'
                  : 'Sesja została zamknięta przez administratora.',
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(
                      context,
                    ).popUntil((route) => route.settings.name == '/'),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showVoteSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Głos zapisany'),
            content: const Text('Dziękujemy za udział w głosowaniu!'),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(
                      context,
                    ).popUntil((route) => route.settings.name == '/'),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Błąd'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildAnswerWidget(int index, QuestionModel question) {
    switch (question.answerType) {
      case 'yes_no':
        return Column(
          children:
              ['TAK', 'NIE'].map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: answers[index],
                  onChanged: (val) => setState(() => answers[index] = val),
                );
              }).toList(),
        );
      case 'yes_no_abstain':
        return Column(
          children:
              ['TAK', 'NIE', 'WSTRZYMUJĘ SIĘ'].map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: answers[index],
                  onChanged: (val) => setState(() => answers[index] = val),
                );
              }).toList(),
        );
      case 'multiple_choice':
        final selected = (answers[index] as List<String>?) ?? [];
        final options = question.options ?? [];
        final max = question.maxSelectable ?? 1;

        return Column(
          children:
              options.map((option) {
                final isSelected = selected.contains(option);
                return CheckboxListTile(
                  title: Text(option),
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        if (selected.length < max) {
                          answers[index] = [...selected, option];
                        }
                      } else {
                        answers[index] =
                            selected.where((item) => item != option).toList();
                      }
                    });
                  },
                );
              }).toList(),
        );
      default:
        return const Text('Nieobsługiwany typ pytania.');
    }
  }

  @override
  void dispose() {
    wsClient?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Głosowanie: ${session.title}')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: session.questions.length + 1,
        itemBuilder: (context, index) {
          if (index == session.questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton(
                onPressed:
                    answers.length == session.questions.length && !isSubmitting
                        ? _submitVote
                        : null,
                child:
                    isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Zatwierdź głos'),
              ),
            );
          }

          final question = session.questions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pytanie ${index + 1}: ${question.text}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildAnswerWidget(index, question),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

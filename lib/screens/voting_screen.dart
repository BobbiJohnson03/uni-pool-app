import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/session_model.dart';
import '../models/question_model.dart';
import '../models/vote_model.dart';

class VotingScreen extends StatefulWidget {
  final SessionModel session;

  const VotingScreen({Key? key, required this.session}) : super(key: key);

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final Map<int, dynamic> answers = {};
  bool isSubmitting = false;
  late String deviceId;

  @override
  void initState() {
    super.initState();
    _generateDeviceId();
    _checkSessionStatus();
  }

  void _generateDeviceId() {
    final random = Random();
    deviceId = 'device_${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  void _checkSessionStatus() {
    if (!widget.session.isOpenForVoting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionClosedDialog();
      });
    }
  }

  void _showSessionClosedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Sesja niedostępna'),
            content: Text(
              widget.session.isExpired
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

  Future<void> _submitVote() async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final voteBox = await Hive.openBox<VoteModel>('votes');
      final alreadyVoted = voteBox.values.any(
        (v) => v.sessionId == widget.session.id && v.deviceId == deviceId,
      );

      if (alreadyVoted) {
        _showAlreadyVotedDialog();
        return;
      }

      final vote = VoteModel(
        sessionId: widget.session.id,
        userId: null,
        answers: answers,
        timestamp: DateTime.now(),
        deviceId: deviceId,
        encryptionKey: 'tajne-glosowanie',
      );

      await voteBox.add(vote);
      _showVoteSuccessDialog();
    } catch (e) {
      _showErrorDialog('Błąd podczas zapisywania głosu: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showAlreadyVotedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Już głosowałeś'),
            content: const Text('Twój głos został już zapisany w tej sesji.'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Głosowanie: ${widget.session.title}')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.session.questions.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.session.questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton(
                onPressed:
                    answers.length == widget.session.questions.length &&
                            !isSubmitting
                        ? _submitVote
                        : null,
                child:
                    isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Zatwierdź głos'),
              ),
            );
          }

          final question = widget.session.questions[index];
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

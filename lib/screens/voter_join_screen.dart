import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/session_model.dart';

class VoterJoinScreen extends StatefulWidget {
  const VoterJoinScreen({Key? key}) : super(key: key);

  @override
  State<VoterJoinScreen> createState() => _VoterJoinScreenState();
}

class _VoterJoinScreenState extends State<VoterJoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  String? error;

  Future<void> _joinSession() async {
    final code = _codeController.text.trim();
    final box = await Hive.openBox<SessionModel>('sessions');

    if (box.containsKey(code)) {
      final session = box.get(code);
      // Przejście do ekranu głosowania
      Navigator.pushReplacementNamed(context, '/vote', arguments: session);
    } else {
      setState(() {
        error = 'Nie znaleziono sesji o podanym kodzie';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dołącz do sesji')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Kod sesji'),
                validator: (value) => value!.isEmpty ? 'Wpisz kod sesji' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _joinSession();
                  }
                },
                child: const Text('Dołącz'),
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

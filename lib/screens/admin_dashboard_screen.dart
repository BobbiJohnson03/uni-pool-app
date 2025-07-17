import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

import '../models/session_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Box<SessionModel> sessionBox;
  late Box<SessionModel> archiveBox;

  @override
  void initState() {
    super.initState();
    Hive.openBox<SessionModel>('sessions').then((box) {
      setState(() {
        sessionBox = box;
      });
    });
    Hive.openBox<SessionModel>('archived_sessions').then((box) {
      setState(() {
        archiveBox = box;
      });
    });
  }

  void _closeSession(String id) async {
    final session = sessionBox.get(id);
    if (session != null) {
      final archiveBox = await Hive.openBox<SessionModel>('archived_sessions');
      await archiveBox.put(session.id, session);
      await sessionBox.delete(id);
      setState(() {});
    }
  }

  void _openResults(SessionModel session) {
    Navigator.pushNamed(context, '/admin_results', arguments: session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel administratora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wróć na ekran startowy',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin');
              },
              child: const Text('+ NOWA SESJA GŁOSOWANIA'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'AKTYWNE SESJE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (Hive.isBoxOpen('sessions') && sessionBox.isNotEmpty)
              ...sessionBox.values.map(
                (session) => Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(session.title),
                        subtitle: Text(
                          'Kod sesji: ${session.id}\nPytania: ${session.questions.length}, Tryb: ${session.isAnonymous ? "Tajne" : "Jawne"}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _closeSession(session.id),
                          child: const Text('ZAMKNIJ SESJĘ'),
                        ),
                      ),
                      QrImageView(
                        data: jsonEncode(session.toJson()),
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              )
            else
              const Text('Brak aktywnych sesji.'),
            const Divider(height: 48),
            const Text(
              'ARCHIWUM',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (Hive.isBoxOpen('archived_sessions') && archiveBox.isNotEmpty)
              ...archiveBox.values.map(
                (session) => Card(
                  child: ListTile(
                    title: Text(session.title),
                    subtitle: Text(
                      'Kod sesji: ${session.id}\nPytania: ${session.questions.length}, Tryb: ${session.isAnonymous ? "Tajne" : "Jawne"}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _openResults(session),
                      child: const Text('Zobacz wyniki'),
                    ),
                  ),
                ),
              )
            else
              const Text('Brak zakończonych sesji.'),
          ],
        ),
      ),
    );
  }
}

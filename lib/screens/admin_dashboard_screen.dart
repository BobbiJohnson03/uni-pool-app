import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/session_model.dart';
import '../local_server/local_vote_server.dart';
import 'package:flutter/services.dart';
import '../utils/network_utils.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Box<SessionModel> sessionBox;
  late Box<SessionModel> archiveBox;

  LocalVoteServer? voteServer;
  String? localIp;
  final int localPort = 8080;

  @override
  void initState() {
    super.initState();
    _openBoxes();
    _startLocalServer();
  }

  Future<void> _openBoxes() async {
    sessionBox = await Hive.openBox<SessionModel>('sessions');
    archiveBox = await Hive.openBox<SessionModel>('archived_sessions');
    setState(() {}); // odśwież, jeśli dane już są
  }

  Future<void> _startLocalServer() async {
    voteServer = LocalVoteServer(port: localPort);
    await voteServer!.start();

    final ip = await getLocalIpAddress();
    setState(() {
      localIp = ip;
    });

    print('serwer WebSocket: ws://$localIp:$localPort');
  }

  void _closeSession(String id) async {
    final session = sessionBox.get(id);
    if (session != null) {
      await archiveBox.put(session.id, session);
      await sessionBox.delete(id);
      setState(() {});
    }
  }

  void _openResults(SessionModel session) {
    Navigator.pushNamed(context, '/admin_results', arguments: session);
  }

  @override
  void dispose() {
    voteServer?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSessions = sessionBox.values.toList();
    final archivedSessions = archiveBox.values.toList();

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
            if (activeSessions.isNotEmpty)
              ...activeSessions.map(
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
                      if (localIp != null)
                        QrImageView(
                          data: jsonEncode({
                            'serverUrl': 'ws://$localIp:$localPort',
                            'session': session.toJson(),
                          }),
                          version: QrVersions.auto,
                          size: 200.0,
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('⏳ Pobieranie adresu IP...'),
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
            if (archivedSessions.isNotEmpty)
              ...archivedSessions.map(
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

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import '../models/session_model.dart';
import '../network/websocket_client.dart';
import '../widgets/web_qr_scanner_widget.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  void handleScanResult(BuildContext context, String rawData) async {
    try {
      final parsed = jsonDecode(rawData);
      final sessionJson = parsed['session'];
      final serverUrl = parsed['serverUrl'];

      if (sessionJson == null || serverUrl == null) {
        throw Exception('Brakuje danych w kodzie QR!');
      }

      final session = SessionModel.fromJson(sessionJson);

      final box = await Hive.openBox<SessionModel>('sessions');
      await box.put(session.id, session);

      final voteClient = WebSocketVoteClient();
      voteClient.connect(serverUrl);

      Navigator.pushNamed(
        context,
        '/vote',
        arguments: {'session': session, 'webSocketClient': voteClient},
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Błąd: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skanuj kod QR')),
      body: WebQrScannerWidget(
        onCodeScanned: (data) => handleScanResult(context, data),
      ),
    );
  }
}

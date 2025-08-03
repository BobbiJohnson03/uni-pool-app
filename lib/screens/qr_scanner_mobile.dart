import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/session_model.dart';
import '../network/websocket_client.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller!.scannedDataStream.listen((scanData) async {
      controller!.pauseCamera(); // zatrzymaj po pierwszym skanie

      try {
        final rawData = scanData.code;
        final parsed = jsonDecode(rawData!);
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

        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/vote',
          arguments: {'session': session, 'webSocketClient': voteClient},
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd: ${e.toString()}')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skanuj kod QR')),
      body: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
    );
  }
}

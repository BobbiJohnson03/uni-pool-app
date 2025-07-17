import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import '../models/session_model.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!scanned) {
        scanned = true;
        try {
          final json = jsonDecode(scanData.code!);
          final session = SessionModel.fromJson(json);
          final box = await Hive.openBox<SessionModel>('sessions');
          await box.put(session.id, session);

          Navigator.pushReplacementNamed(context, '/vote', arguments: session);
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Nieprawidłowy kod QR: $e')));
          scanned = false; // Pozwól zeskanować jeszcze raz
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skanuj kod QR')),
      body: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
    );
  }
}

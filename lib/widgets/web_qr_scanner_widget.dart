// lib/widgets/web_qr_scanner_widget.dart
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:js/js.dart';

@JS()
external dynamic jsQR(html.ImageData imageData, int width, int height);

class WebQrScannerWidget extends StatefulWidget {
  final void Function(String)? onCodeScanned;

  const WebQrScannerWidget({Key? key, this.onCodeScanned}) : super(key: key);

  @override
  State<WebQrScannerWidget> createState() => _WebQrScannerWidgetState();
}

class _WebQrScannerWidgetState extends State<WebQrScannerWidget> {
  html.VideoElement? _video;
  html.CanvasElement? _canvas;
  Timer? _timer;
  String? _detectedCode;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _video = html.VideoElement();
    _video!
      ..autoplay = true
      ..muted = true
      ..style.width = '100%';

    _canvas = html.CanvasElement();

    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {'facingMode': 'environment'},
      });
      _video!.srcObject = stream;

      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        'qr-video-element',
        (int viewId) => _video!,
      );

      _timer = Timer.periodic(
        const Duration(milliseconds: 300),
        (_) => _scanFrame(),
      );
    } catch (e) {
      debugPrint('📷 Kamera niedostępna: $e');
    }

    setState(() {});
  }

  void _scanFrame() {
    if (_video == null || _canvas == null) return;

    final video = _video!;
    final canvas =
        _canvas!
          ..width = video.videoWidth!
          ..height = video.videoHeight!;
    final ctx = canvas.context2D;
    ctx.drawImage(video, 0, 0);

    final imageData = ctx.getImageData(0, 0, canvas.width!, canvas.height!);
    final result = jsQR(imageData, canvas.width!, canvas.height!);

    if (result != null && _detectedCode != result['data']) {
      _detectedCode = result['data'];
      debugPrint('✅ QR kod: $_detectedCode');
      if (widget.onCodeScanned != null) widget.onCodeScanned!(_detectedCode!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _video?.srcObject = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_video == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 300,
      child: HtmlElementView(viewType: 'qr-video-element'),
    );
  }
}

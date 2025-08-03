import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import '../models/vote_model.dart';

class LocalVoteServer {
  final int port;
  HttpServer? _server;
  final List<WebSocket> _clients = [];

  LocalVoteServer({this.port = 8080});

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    print('Serwer WebSocket działa na ws://${_server!.address.address}:$port');

    _server!.transform(WebSocketTransformer()).listen(_handleClient);
  }

  void _handleClient(WebSocket client) {
    print('Klient połączony: ${client.hashCode}');
    _clients.add(client);

    client.listen(
      (data) {
        print('Otrzymano dane od klienta: $data');

        try {
          final json = jsonDecode(data);

          if (json['type'] == 'vote') {
            _handleVote(json, client);
          }
        } catch (e) {
          print('Błąd przy przetwarzaniu danych: $e');
          client.add(jsonEncode({'type': 'error', 'message': 'Invalid data'}));
        }
      },
      onDone: () {
        print('Klient się rozłączył: ${client.hashCode}');
        _clients.remove(client);
      },
    );
  }

  Future<void> _handleVote(Map<String, dynamic> data, WebSocket client) async {
    try {
      final vote = VoteModel.fromJson(data['payload'], 'tajne-glosowanie');
      final box = await Hive.openBox<VoteModel>('votes');

      // sprawdź, czy głos już istnieje (opcjonalnie)
      final alreadyExists = box.values.any(
        (v) => v.sessionId == vote.sessionId && v.deviceId == vote.deviceId,
      );

      if (alreadyExists) {
        client.add(
          jsonEncode({
            'type': 'error',
            'message': 'Głos już został oddany z tego urządzenia.',
          }),
        );
        return;
      }

      await box.add(vote);
      print('Głos zapisany do Hive!');

      client.add(
        jsonEncode({'type': 'confirmation', 'message': 'Głos zapisany!'}),
      );

      // opcjonalnie: broadcast do UI admina
      _broadcastVoteUpdate(vote.sessionId);
    } catch (e) {
      print(' Błąd przy zapisie głosu: $e');
      client.add(jsonEncode({'type': 'error', 'message': e.toString()}));
    }
  }

  void _broadcastVoteUpdate(String sessionId) {
    final message = jsonEncode({'type': 'vote_update', 'sessionId': sessionId});
    for (var c in _clients) {
      c.add(message);
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _clients.clear();
  }
}

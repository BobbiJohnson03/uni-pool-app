import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketVoteClient {
  late WebSocketChannel _channel;
  Function(String)? onMessage;
  Function(dynamic)? onError;

  bool get isConnected => _channel != null;

  void connect(String serverUrl) {
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

    _channel.stream.listen(
      (data) {
        print('📥 Otrzymano z serwera: $data');
        onMessage?.call(data);
      },
      onError: (error) {
        print('Błąd połączenia WebSocket: $error');
        onError?.call(error);
      },
      onDone: () {
        print('🔌 Połączenie WebSocket zakończone.');
      },
    );
  }

  void sendVote(Map<String, dynamic> votePayload) {
    final json = jsonEncode({'type': 'vote', 'payload': votePayload});
    _channel.sink.add(json);
  }

  void disconnect() {
    _channel.sink.close();
  }
}

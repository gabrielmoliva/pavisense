import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/io.dart';

class WebsocketService {
  final _wsUrl = dotenv.env['WS_URL'];
  late IOWebSocketChannel? _channel;

  WebsocketService();

  void connect() {
    _channel = IOWebSocketChannel.connect(Uri.parse(_wsUrl!));
  }

  void disconnect() {
    _channel?.sink.close();
  }

  void sendData(Map<String, dynamic> data) {
    if (_channel != null) {
      final json = jsonEncode(data);
      _channel?.sink.add(json);
    }
    else {
      throw Exception("Erro ao enviar dados via websocket");
    }
  }
}

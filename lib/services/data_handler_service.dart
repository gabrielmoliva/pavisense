import 'dart:async';
import 'package:pavisense/services/draw_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/io.dart';
import 'package:pavisense/models/ponto_conforto_model.dart';

class DataHandlerService {
  Timer? _collectionTimer;
  final _wsUrl = dotenv.env['WS_URL'];
  late IOWebSocketChannel? _channel;

  void start(Duration collectionFrequency, DrawService drawService) async {
    _channel = IOWebSocketChannel.connect(Uri.parse(_wsUrl!));

    _receiveData(drawService);

    _collectionTimer = Timer.periodic(collectionFrequency, (_) async {
      final accEvent = await accelerometerEventStream().first;
      final gyroEvent = await gyroscopeEventStream().first;
      final position = await Geolocator.getCurrentPosition();

      final data = {
        'timestamp': DateTime.now().microsecondsSinceEpoch,
        'lat': position.latitude,
        'long': position.longitude,
        'acc_x_std': accEvent.x,
        'acc_y_std': accEvent.y,
        'acc_z_std': accEvent.z,
        'gyro_x_std': gyroEvent.x,
        'gyro_y_std': gyroEvent.y,
        'gyro_z_std': gyroEvent.z,
        'speed': position.speed,
      };

      if (_channel != null) {
        final json = jsonEncode(data);
        _channel?.sink.add(json);
      }
      else {
        throw Exception("Erro ao enviar dados via websocket");
      }
    });
  }

  void stop() {
    _collectionTimer?.cancel();
    _channel?.sink.close();
  }

  void _receiveData(DrawService drawService) {
    _channel?.stream.listen((message) {
      try {
        print("Mensagem recebida do WS: $message");
        print("Tipo após decode: ${jsonDecode(message).runtimeType}");
        final ponto = PontoConfortoModel.fromJson(jsonDecode(message));
        drawService.addPoints([ponto]);
      } catch (e) {
        throw "Erro ao processar mensagem do WebSocket: $e";
      }
    }, onError: (error) {
      print("Erro no WebSocket: $error");
    }, onDone: () {
      print("Conexão WebSocket encerrada");
    });
  }
}

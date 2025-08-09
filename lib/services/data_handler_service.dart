import 'dart:async';
import 'package:pavisense/services/websocket_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

class DataHandlerService {
  final WebsocketService _websocketService = WebsocketService();
  Timer? _collectionTimer;

  DataHandlerService();

  void start(Duration collectionFrequency) async {
    _websocketService.connect();

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

      _websocketService.sendData(data);
    });
  }

  void stop() {
    _collectionTimer?.cancel();
    _websocketService.disconnect();
  }
}

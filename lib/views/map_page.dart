import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pavisense/widgets/data_collection_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/location_service.dart';
import '../widgets/location_button.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/search_location_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng _center = LatLng(-14.235004, -51.92528); // Brasil
  StreamSubscription<Position>? _positionStream;
  bool _followUser = true;
  double defaultZoom = 18;
  bool _isCollecting = false;
  Timer? _collectionTimer;
  StreamSubscription<AccelerometerEvent>? _accSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  List<double>? _accValues;
  List<double>? _gyroValues;
  final wsUrl = dotenv.env['WS_URL']; // websocket url
  late WebSocketChannel _ws;

  // moves the map to the current user location
  void _goToUserLocation() async {
    final service = LocationService();
    final location = await service.getCurrentLocation();
    if (location != null) {
      final userPos = LatLng(location.latitude, location.longitude);
      setState(() {
        _center = userPos;
        _followUser = true;
      });
      _mapController.move(userPos, defaultZoom);
    }
  }

  // sets initial location for the map
  void _setInitialLocation() async {
    final service = LocationService();
    final initialLocation = await service.getCurrentLocation();
    if (initialLocation != null) {
      final userInitialPosition = LatLng(
        initialLocation.latitude,
        initialLocation.longitude,
      );
      setState(() => _center = userInitialPosition);
      _mapController.move(userInitialPosition, defaultZoom);
    }
  }

  // follows the location of the user and updates the map accordingly
  void _listenToLocationChanges() {
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          final newPos = LatLng(position.latitude, position.longitude);
          setState(() => _center = newPos);
          if (_followUser) {
            _mapController.move(newPos, _mapController.camera.zoom);
          }
        });
  }

  // starts collecting and sending data to backend
  void _toggleDataColletion() async {
    print('ativou colecao de dados');
    if (_isCollecting) {
      print('desativou colecao de dados');
      _collectionTimer?.cancel();
      _accSubscription?.cancel();
      _gyroSubscription?.cancel();
      setState(() => _isCollecting = false);
      return;
    }

    // inicia a coleta dos dados de acelerometro e giroscopio
    _accSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      _accValues = [event.x, event.y, event.z];
    });
    _gyroSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      _gyroValues = [event.x, event.y, event.z];
    });

    _collectionTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final position = await Geolocator.getCurrentPosition();
      final now = DateTime.now();

      _sendData(position, now);
    });
    _isCollecting = true;
  }

  // sends collected data to backend for model prediction
  void _sendData(Position position, DateTime now) async {
    // TODO: mover inicializacao do websocket pra ca ou pra funcao de cima
    final speed = position.speed;

    if (speed<=0) return;

    final lat = position.latitude;
    final long = position.longitude;
    final timestamp = now.millisecondsSinceEpoch;
    
    final String jsonPayload = jsonEncode({
      'timestamp': timestamp,
      'lat': lat,
      'long': long,
      'accValues': _accValues ?? [0.0, 0.0, 0.0],
      'gyroValues': _gyroValues ?? [0.0, 0.0, 0.0],
      'speed': speed,
    });

    _ws.sink.add(jsonPayload);
  }

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
    _listenToLocationChanges();
    print(wsUrl);
    _ws = WebSocketChannel.connect(Uri.parse(wsUrl!));
  }

  @override
  void dispose() {
    _ws.sink.close();
    _positionStream?.cancel(); // Cancele o stream ao destruir o widget
    super.dispose();
  }

  Marker userMarker() {
    return Marker(
      point: _center,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: const Icon(
          Icons.person_pin_circle,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Mapa com OSM")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 20,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _followUser) {
                  setState(() {
                    _followUser =
                        false; // para de seguir o usuario se ele mexer o mapa
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.pavisense.example',
              ),
              MarkerLayer(markers: [userMarker()]),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: DataCollectionButton(
                onPressed: _toggleDataColletion,
                isCollecting: _isCollecting,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
              child: LocationButton(onPressed: _goToUserLocation),
            ),
          ),
          Positioned(
            top: 40,
            left: 24,
            right: 24,
            child: SearchLocationBar(
              onLocationSelected: (lat, lon, displayName) {
                final newPos = LatLng(lat, lon);
                setState(() {
                  //_center = newPos;
                  _followUser = false;
                });
                _mapController.move(newPos, defaultZoom);
              },
            ),
          ),
        ],
      ),
    );
  }
}

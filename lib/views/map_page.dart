import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pavisense/services/data_handler_service.dart';
import 'package:pavisense/services/draw_service.dart';
import 'package:pavisense/widgets/data_collection_button.dart';
import '../services/location_service.dart';
import '../widgets/location_button.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/search_location_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final DataHandlerService dataHandlerService = DataHandlerService();
  final DrawService drawService = DrawService();
  LatLng _center = LatLng(-14.235004, -51.92528); // Brasil
  StreamSubscription<Position>? _positionStream;
  bool _followUser = true;
  double defaultZoom = 18;
  bool _isCollecting = false;
  List<List<LatLng>> polylines = [];

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

  // starts map on the users current location and starts to follow user
  Future<void> _initializeMap() async {
    final locationService = LocationService();

    final initialLocation = await locationService.getFirstPositionFromStream();
    if (initialLocation != null) {
      final initialLatLng = LatLng(initialLocation.latitude, initialLocation.longitude);
      setState(() => _center = initialLatLng);
      _mapController.move(initialLatLng, defaultZoom);
    }

    _positionStream = locationService.getPositionStream(distanceFilter: 1).listen((position) {
      final newPos = LatLng(position.latitude, position.longitude);
      setState(() => _center = newPos);

      if (_followUser) {
        _mapController.move(newPos, _mapController.camera.zoom);
      }
    });
  }

  // starts collecting and sending data to backend
  void _toggleDataColletion() async {
    if (_isCollecting) {
      dataHandlerService.stop();
      setState(() { 
        _isCollecting = false;
        polylines = drawService.getPolylines();
      });
      return;
    }
    _isCollecting = true;
    dataHandlerService.start(Duration(milliseconds: 100), drawService);
  }

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
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
              MarkerLayer(markers: [
                userMarker(),
              ]),
              PolylineLayer(
                 polylines: List<Polyline>.generate(
                  polylines.length,
                  (int index) {
                    return Polyline(
                      points: polylines[index],
                      strokeWidth: 4.0,
                      color: Colors.red,
                    );
                  }
                 ),
              ),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pavisense/widgets/data_collection_button.dart';
import '../services/location_service.dart';
import '../widgets/location_button.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng _center = LatLng(-14.235004, -51.92528); // Brasil
  StreamSubscription<Position>? _positionStream; // Adicione isso

  void _goToUserLocation() async {
    final service = LocationService();
    final location = await service.getCurrentLocation();
    if (location != null) {
      final userPos = LatLng(location.latitude, location.longitude);
      setState(() => _center = userPos);
      _mapController.move(userPos, 17);
    }
  }

  void _setInitialLocation() async {
    final service = LocationService();
    final initialLocation = await service.getCurrentLocation();
    if (initialLocation != null) {
      final userInitialPosition = LatLng(
        initialLocation.latitude,
        initialLocation.longitude,
      );
      setState(() => _center = userInitialPosition);
      _mapController.move(userInitialPosition, 17);
    }
  }

  void _listenToLocationChanges() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final newPos = LatLng(position.latitude, position.longitude);
      setState(() => _center = newPos);
      _mapController.move(newPos, _mapController.camera.zoom);
    });
  }

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
    _listenToLocationChanges();
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Cancele o stream ao destruir o widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Mapa com OSM")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _center, initialZoom: 20),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.pavisense.example',
              ),
              MarkerLayer(
                markers: [
                  Marker(
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
                        size:28,
                      ),
                    )
                  )
                ]
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: DataCollectionButton(onPressed: _goToUserLocation),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
              child: LocationButton(onPressed: _goToUserLocation),
            ),
          ),
        ],
      ),
    );
  }
}

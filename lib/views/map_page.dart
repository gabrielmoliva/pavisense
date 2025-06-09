import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../widgets/location_button.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng _center = LatLng(-14.235004, -51.92528); // Brasil

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
    if(initialLocation!=null) {
      final userInitialPosition = LatLng(initialLocation.latitude, initialLocation.longitude);
      setState(() => _center = userInitialPosition);
      _mapController.move(userInitialPosition, 17);
    }
  }

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Mapa com OSM")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 20,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.pavisense.exemple',
          ),
          /* MarkerLayer(
            markers: [
              Marker(
                point: _center,
                width: 50,
                height: 50,
                builder: (ctx) => const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ), */
        ],
      ),
      floatingActionButton: LocationButton(onPressed: _goToUserLocation),
    );
  }
}

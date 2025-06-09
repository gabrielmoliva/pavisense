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
  LatLng _center = LatLng(-23.55052, -46.633308); // São Paulo

  void _goToUserLocation() async {
    final service = LocationService();
    final location = await service.getCurrentLocation();
    if (location != null) {
      final userPos = LatLng(location.latitude, location.longitude);
      setState(() => _center = userPos);
      _mapController.move(userPos, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa com OSM")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.seuapp.exemplo',
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
      //floatingActionButton: LocationButton(onPressed: _goToUserLocation),
    );
  }
}

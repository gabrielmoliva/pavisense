import 'package:flutter/material.dart';
import '../utils/permissions.dart';

class LocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LocationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final granted = await requestLocationPermission();
        if (granted) {
          onPressed();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permissão de localização negada")),
          );
        }
      },
      child: const Icon(Icons.my_location),
    );
  }
}

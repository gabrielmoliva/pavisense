import 'package:flutter/material.dart';
import '../utils/permissions.dart';

class LocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LocationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
        child: SizedBox(
          width: 55,
          height: 55,
          child: FloatingActionButton(
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
            backgroundColor: Color(0xFF2C2C2C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
            ),
            child: const Icon(Icons.my_location),
            
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pavisense/utils/permissions.dart';

class DataCollectionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DataCollectionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () async {
            final granted = await requestLocationPermission();
            if (granted) {
              onPressed();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Permissão de localização negada"),
                ),
              );
            }
          },
          backgroundColor: Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(Icons.power_settings_new, size: 42),
        ),
      ),
    );
  }
}

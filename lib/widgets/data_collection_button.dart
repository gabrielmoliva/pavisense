import 'package:flutter/material.dart';
import '../utils/permissions.dart';

class DataCollectionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isCollecting;

  const DataCollectionButton({
    super.key,
    required this.onPressed,
    required this.isCollecting,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
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
        backgroundColor: const Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60),
        ),
        child: Icon(
          isCollecting ? Icons.close : Icons.power_settings_new,
          size: 42,
        ),
      ),
    );
  }
}

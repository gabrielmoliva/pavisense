import 'package:flutter/material.dart';
import 'package:pavisense/views/config_page.dart';

class ConfigButton extends StatelessWidget {
  const ConfigButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight, // fica no lado direito
      child: SizedBox(
        width: 55,
        height: 55,
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ConfigPage(),
              ),
            );
          },
          backgroundColor: const Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.settings),
        ),
      ),
    );
  }
}

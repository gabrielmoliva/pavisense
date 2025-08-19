import 'package:flutter/material.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  double _windowSize = 100; // valor inicial (backend)
  double _samplingRate = 1; // em segundos (frontend)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: const Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tamanho da janela
            const Text(
              "Tamanho da janela (backend)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _windowSize,
              min: 10,
              max: 100,
              divisions: 9,
              label: _windowSize.round().toString(),
              onChanged: (value) {
                setState(() => _windowSize = value);
              },
            ),
            Text("Valor atual: ${_windowSize.round()} amostras"),

            const SizedBox(height: 32),

            // Taxa de coleta
            const Text(
              "Taxa de coleta (frontend)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _samplingRate,
              min: 0.1,
              max: 5,
              divisions: 49,
              label: "${_samplingRate.toStringAsFixed(1)} s",
              onChanged: (value) {
                setState(() => _samplingRate = value);
              },
            ),
            Text("Intervalo: ${_samplingRate.toStringAsFixed(1)} segundos"),

            const Spacer(),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // aqui você poderia salvar em SharedPreferences
                  // e aplicar no app
                  Navigator.pop(context, {
                    "windowSize": _windowSize.round(),
                    "samplingRate": _samplingRate,
                  });
                },
                child: const Text(
                  "Salvar configurações",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

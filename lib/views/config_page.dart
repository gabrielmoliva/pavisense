import 'package:flutter/material.dart';
import 'package:pavisense/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  double _windowSize = 100; // valor inicial (backend)
  double _samplingRate = 1; // em segundos (frontend)
  final AuthService _authService = AuthService();
  int _selectedModel = 0; // 0 = extra trees; 1 = mlp

  @override
  void initState () {
    super.initState();
    _loadPreferences();
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _windowSize = prefs.getDouble("windowSize") ?? 100;
      _samplingRate = prefs.getDouble("samplingRate") ?? 1;
      _selectedModel = prefs.getInt("selectedModel") ?? 0;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("windowSize", _windowSize);
    await prefs.setDouble("samplingRate", _samplingRate);
    await prefs.setInt("selectedModel", _selectedModel);
  }

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

            const SizedBox(height: 32),

            const Text(
              "Modelo de previsão",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text(
                _selectedModel == 0
                    ? "ExtraTreesClassifier"
                    : "MLPClassifier",
              ),
              value: _selectedModel == 1,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  _selectedModel = value ? 1 : 0;
                });
              },
            ),

            const Spacer(),

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
                onPressed: () => _logout(),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

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
                onPressed: () async {
                  await _savePreferences();
                  Navigator.pop(context, {
                    "windowSize": _windowSize.round(),
                    "samplingRate": _samplingRate,
                    "selectedModel": _selectedModel,
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

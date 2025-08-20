import 'package:flutter/material.dart';
import 'package:pavisense/views/map_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pavisense/views/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("auth_token");

  runApp( MyApp(initialToken: token) );
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaviSense',
      initialRoute: initialToken != null ? "/map" : "/login",
      routes: {
        "/login": (context) => const LoginPage(),
        "/map": (context) => const MapPage(),
      }
    );
  }
}
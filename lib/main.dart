import 'package:flutter/material.dart';
import 'package:pavisense/views/map_page.dart';

void main() {
  runApp( MyApp() );
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MapPage(),
      )
    );
  }
}
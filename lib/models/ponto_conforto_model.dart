import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

class PontoConfortoModel {
  final LatLng coords;
  final NivelConforto conforto; // 0 = bom, 1 = ruim

  PontoConfortoModel({
    required this.coords,
    required this.conforto,
  });

  // Método para criar a partir de JSON
  factory PontoConfortoModel.fromJson(Map<String, dynamic> json) {
    return PontoConfortoModel(
      coords: LatLng(json['lat'], json['long']),
      conforto: json['conforto'] == 0 
        ? NivelConforto.goodRoad 
        : NivelConforto.badRoad,
    );
  }

  Color getColor() {
    if (conforto==1) {
      return Color.fromARGB(0, 86, 177, 48);
    }
    return Color(0xFFE00A0A);
  }
}

enum NivelConforto {
  goodRoad,
  badRoad
}
import 'package:flutter_map/flutter_map.dart';
import 'package:pavisense/models/ponto_conforto_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DrawService {
  final List<PontoConfortoModel> _globalPoints = [];

  List<Polyline> drawLines() {
    if (_globalPoints.isEmpty) return <Polyline>[];

    final List<Polyline> polylines = [];
    List<LatLng> currentSegment = [];
    Color? currentColor;

    for (var ponto in _globalPoints) {
      final color = ponto.getColor();

      if (currentColor == null) {
        currentColor = color;
        currentSegment.add(ponto.coords);
        continue;
      }

      if (currentColor.toARGB32()==color.toARGB32()) {
        currentSegment.add(ponto.coords);
      } else {
        polylines.add(
          Polyline(
            points: currentSegment,
            color: currentColor,
            strokeWidth: 6.0
          )
        );

        currentColor=color;
        currentSegment = [ponto.coords];
      }
    }

    if (currentSegment.isNotEmpty && currentColor != null) {
      polylines.add(
        Polyline(
          points: currentSegment,
          color: currentColor,
          strokeWidth: 6.0
        )
      );
    }
    return polylines;
  }

  void addPoint(PontoConfortoModel ponto) {
    _globalPoints.add(ponto);
  }

  void clear() {
    _globalPoints.clear();
  }
}
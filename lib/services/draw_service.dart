import 'package:pavisense/models/ponto_conforto_model.dart';
import 'package:flutter_map/flutter_map.dart';

class DrawService {
  final List<PontoConfortoModel> _globalTrajectories = [];
  List<Polyline> polylines = [];

  void addPoints(List<PontoConfortoModel> pontos) {
    _globalTrajectories.addAll(pontos);
    for (PontoConfortoModel ponto in _globalTrajectories) {
      polylines.add(Polyline(
        points: [ponto.coords],
        strokeWidth: 4,
        color: ponto.getColor()));
    }
  }

  List<PontoConfortoModel> getPoints() {
    return _globalTrajectories;
  }

  List<Polyline> getPolylines() {
    return polylines;
  }
}
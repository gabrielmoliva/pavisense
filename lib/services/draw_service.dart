import 'package:pavisense/models/ponto_conforto_model.dart';
import 'package:latlong2/latlong.dart';

class DrawService {
  final List<PontoConfortoModel> _globalTrajectories = [];
  final List<LatLng> _polyline = <LatLng>[];
  // final List<List<LatLng>> _polylines = [];

  void addPoints(List<PontoConfortoModel> pontos) async {
    _globalTrajectories.addAll(pontos);
    for (PontoConfortoModel ponto in pontos) {
      _polyline.add(ponto.coords);
    }
    // _polylines.add(_polyline);
  }

  List<PontoConfortoModel> getPoints() {
    return _globalTrajectories;
  }

  List<List<LatLng>> getPolylines() {
    return [_polyline];
  }
}
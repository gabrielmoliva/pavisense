class PontoConfortoModel {
  final double lat;
  final double long;
  final int conforto; // 1 = bom, 2 = ruim

  PontoConfortoModel({
    required this.lat,
    required this.long,
    required this.conforto,
  });

  // Método para criar a partir de JSON
  factory PontoConfortoModel.fromJson(Map<String, dynamic> json) {
    return PontoConfortoModel(
      lat: json['lat'],
      long: json['long'],
      conforto: json['conforto'],
    );
  }
}
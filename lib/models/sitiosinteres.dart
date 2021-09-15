import 'dart:convert';

SitiosInteres sitiosinteresFromJson(String str) =>
    SitiosInteres.fromJson(json.decode(str));

String sitiosinteresToJson(SitiosInteres data) => json.encode(data.toJson());

class SitiosInteres {
  int? idsitiointeres;
  int? idlugar;
  String? nombre;
  String? descripcion;
  List<SitiosInteres> toList = [];
  SitiosInteres({
    required this.idsitiointeres,
    required this.idlugar,
    this.nombre,
    this.descripcion,
  });

  factory SitiosInteres.fromJson(Map<String, dynamic> json) => SitiosInteres(
        idsitiointeres: json["idsitiointeres"],
        idlugar: json["idlugar"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
      );
  SitiosInteres.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((sitiosinteres) {
      SitiosInteres sitios = SitiosInteres.fromJson(sitiosinteres);
      toList.add(sitios);
    });
  }
  Map<String, dynamic> toJson() => {
        "idsitiointeres": idsitiointeres,
        "idlugar": idlugar,
        "nombre": nombre,
        "descripcion": descripcion,
      };
}

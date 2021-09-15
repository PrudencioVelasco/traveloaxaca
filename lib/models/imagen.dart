// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

Imagen imagenFromJson(String str) => Imagen.fromJson(json.decode(str));

String imagenToJson(Imagen data) => json.encode(data.toJson());

class Imagen {
  int? idimagen;
  int? idlugar;
  String? nombre;
  List<Imagen> toList = [];
  Imagen({
    required this.idimagen,
    required this.idlugar,
    this.nombre,
  });

  factory Imagen.fromJson(Map<String, dynamic> json) => Imagen(
        idimagen: json["idimagen"],
        idlugar: json["idlugar"],
        nombre: json["nombre"],
      );
  Imagen.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      Imagen imagen = Imagen.fromJson(element);
      toList.add(imagen);
    });
  }
  Map<String, dynamic> toJson() => {
        "idimagen": idimagen,
        "idlugar": idlugar,
        "nombre": nombre,
      };
}

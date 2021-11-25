// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

Categoria categoriaFromJson(String str) => Categoria.fromJson(json.decode(str));

String categoriaToJson(Categoria data) => json.encode(data.toJson());

class Categoria {
  int? idlugarprincipal;
  int? idlugarsecundario;
  int? idclasificacion;
  String? nombreclasificacion;
  String? icono;
  List<Categoria> toList = [];
  Categoria({
    required this.idlugarprincipal,
    required this.idlugarsecundario,
    required this.idclasificacion,
    this.nombreclasificacion,
    this.icono,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        idlugarprincipal: json["idlugarprincipal"],
        idlugarsecundario: json["idlugarsecundario"],
        idclasificacion: json["idclasificacion"],
        nombreclasificacion: json["nombreclasificacion"],
        icono: json["icono"],
      );
  Categoria.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      Categoria imagen = Categoria.fromJson(element);
      toList.add(imagen);
    });
  }
  Map<String, dynamic> toJson() => {
        "idlugarprincipal": idlugarprincipal,
        "idlugarsecundario": idlugarsecundario,
        "idclasificacion": idclasificacion,
        "nombreclasificacion": nombreclasificacion,
        "icono": icono,
      };
}

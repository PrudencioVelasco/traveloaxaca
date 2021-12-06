// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

LoveTour loveTourFromJson(String str) => LoveTour.fromJson(json.decode(str));

String loveTourToJson(LoveTour data) => json.encode(data.toJson());

class LoveTour {
  int? idlovetour;
  int? idtour;
  int? idusuario;
  String? fecharegistro;
  List<LoveTour> toList = [];
  LoveTour({
    this.idlovetour,
    this.idtour,
    this.idusuario,
    this.fecharegistro,
  });

  factory LoveTour.fromJson(Map<String, dynamic> json) => LoveTour(
        idlovetour: json["idlovetour"],
        idtour: json["idtour"],
        idusuario: json["idusuario"],
        fecharegistro: json["fecharegistro"],
      );
  LoveTour.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((element) {
      LoveTour loveTour = LoveTour.fromJson(element);
      toList.add(loveTour);
    });
  }
  Map<String, dynamic> toJson() => {
        "idlovetour": idlovetour,
        "idtour": idtour,
        "idusuario": idusuario,
        "fecharegistro": fecharegistro,
      };
}

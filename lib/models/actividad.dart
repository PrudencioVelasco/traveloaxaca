// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

Actividad actividadFromJson(String str) => Actividad.fromJson(json.decode(str));

String actividadToJson(Actividad data) => json.encode(data.toJson());

class Actividad {
  int? idlugar;
  int? idactividad;
  String? nombreactividad;
  List<Actividad> toList = [];
  Actividad({
    this.idlugar,
    this.idactividad,
    this.nombreactividad,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) => Actividad(
        idlugar: json["idlugar"],
        idactividad: json["idactividad"],
        nombreactividad: json["nombreactividad"],
      );
  Actividad.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      Actividad actividad = Actividad.fromJson(element);
      toList.add(actividad);
    });
  }
  Map<String, dynamic> toJson() => {
        "idlugar": idlugar,
        "idactividad": idactividad,
        "nombreactividad": nombreactividad,
      };
}

// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

Atractivo atractivoFromJson(String str) => Atractivo.fromJson(json.decode(str));

String atractivoToJson(Atractivo data) => json.encode(data.toJson());

class Atractivo {
  int? idlugar;
  int? idatractivo;
  String? nombreatractivo;
  List<Atractivo> toList = [];
  Atractivo({
    this.idlugar,
    this.idatractivo,
    this.nombreatractivo,
  });

  factory Atractivo.fromJson(Map<String, dynamic> json) => Atractivo(
        idlugar: json["idlugar"],
        idatractivo: json["idatractivo"],
        nombreatractivo: json["nombreatractivo"],
      );
  Atractivo.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      Atractivo actividad = Atractivo.fromJson(element);
      toList.add(actividad);
    });
  }
  Map<String, dynamic> toJson() => {
        "idlugar": idlugar,
        "idatractivo": idatractivo,
        "nombreatractivo": nombreatractivo,
      };
}

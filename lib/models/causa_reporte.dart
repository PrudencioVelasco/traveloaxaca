// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

CausaReporte causareporteFromJson(String str) =>
    CausaReporte.fromJson(json.decode(str));

String causareporteToJson(CausaReporte data) => json.encode(data.toJson());

class CausaReporte {
  int? idcausareporte;
  String? nombrecausareporte;
  int? activo;

  List<CausaReporte> toList = [];
  CausaReporte({
    this.idcausareporte,
    this.nombrecausareporte,
    this.activo,
  });

  factory CausaReporte.fromJson(Map<String, dynamic> json) => CausaReporte(
        idcausareporte: json["idcausareporte"],
        nombrecausareporte: json["nombrecausareporte"],
        activo: json["activo"],
      );
  CausaReporte.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      CausaReporte causaReporte = CausaReporte.fromJson(element);
      toList.add(causaReporte);
    });
  }
  Map<String, dynamic> toJson() => {
        "idcausareporte": idcausareporte,
        "nombrecausareporte": nombrecausareporte,
        "activo": activo,
      };
}

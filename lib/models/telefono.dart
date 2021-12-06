// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

Telefono telefonoFromJson(String str) => Telefono.fromJson(json.decode(str));

String telefonoToJson(Telefono data) => json.encode(data.toJson());

class Telefono {
  int? idtelefono;
  int? idcompania;
  String? numerotelefono;
  List<Telefono> toList = [];
  Telefono({
    this.idtelefono,
    this.idcompania,
    this.numerotelefono,
  });

  factory Telefono.fromJson(Map<String, dynamic> json) => Telefono(
        idtelefono: json["idtelefono"],
        idcompania: json["idcompania"],
        numerotelefono: json["numerotelefono"],
      );
  Telefono.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      Telefono actividad = Telefono.fromJson(element);
      toList.add(actividad);
    });
  }
  Map<String, dynamic> toJson() => {
        "idtelefono": idtelefono,
        "idcompania": idcompania,
        "numerotelefono": numerotelefono,
      };
}

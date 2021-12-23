// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

Horario horarioFromJson(String str) => Horario.fromJson(json.decode(str));

String horarioToJson(Horario data) => json.encode(data.toJson());

class Horario {
  int? idhorario;
  int? idcompania;
  int? iddia;
  String? nombredia;
  String? horainicial;
  String? horafinal;
  List<Horario> toList = [];
  Horario({
    this.idhorario,
    this.idcompania,
    this.iddia,
    this.nombredia,
    this.horainicial,
    this.horafinal,
  });

  factory Horario.fromJson(Map<String, dynamic> json) => Horario(
        idhorario: json["idhorario"],
        idcompania: json["idcompania"],
        iddia: json["iddia"],
        nombredia: json["nombredia"],
        horainicial: json["horainicial"],
        horafinal: json["horafinal"],
      );
  Horario.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((element) {
      Horario horario = Horario.fromJson(element);
      toList.add(horario);
    });
  }
  Map<String, dynamic> toJson() => {
        "idhorario": idhorario,
        "idcompania": idcompania,
        "iddia": iddia,
        "nombredia": nombredia,
        "horainicial": horainicial,
        "horafinal": horafinal,
      };
}

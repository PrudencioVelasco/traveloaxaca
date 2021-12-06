// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

Compania companiaFromJson(String str) => Compania.fromJson(json.decode(str));

String companiaToJson(Compania data) => json.encode(data.toJson());

class Compania {
  int? idclasificacion;
  String? nombreclasificacion;
  int? idcompania;
  String? rfc;
  String? logotipo;
  String? paginaweb;
  String? nombre;
  String? actividad;
  String? direccion;
  String? correo;
  String? contacto;
  List<Compania> toList = [];
  Compania({
    this.idclasificacion,
    this.nombreclasificacion,
    this.idcompania,
    this.rfc,
    this.logotipo,
    this.paginaweb,
    this.nombre,
    this.actividad,
    this.direccion,
    this.correo,
    this.contacto,
  });

  factory Compania.fromJson(Map<String, dynamic> json) => Compania(
        idclasificacion: json["idclasificacion"],
        nombreclasificacion: json["nombreclasificacion"],
        idcompania: json["idcompania"],
        rfc: json["rfc"],
        logotipo: json["logotipo"],
        paginaweb: json["paginaweb"],
        nombre: json["nombre"],
        actividad: json["actividad"],
        direccion: json["direccion"],
        correo: json["correo"],
        contacto: json["contacto"],
      );
  Compania.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((element) {
      Compania compania = Compania.fromJson(element);
      toList.add(compania);
    });
  }
  Map<String, dynamic> toJson() => {
        "idclasificacion": idclasificacion,
        "nombreclasificacion": nombreclasificacion,
        "idcompania": idcompania,
        "rfc": rfc,
        "logotipo": logotipo,
        "paginaweb": paginaweb,
        "nombre": nombre,
        "actividad": actividad,
        "direccion": direccion,
        "correo": correo,
        "contacto": contacto,
      };
}

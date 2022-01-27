// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

import 'package:traveloaxaca/models/imagen_compania.dart';

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
  int? love;
  int? comentario;
  double? rating;
  String? primeraimagen;
  String? actividad;
  String? direccion;
  double? latitud;
  double? longitud;
  String? correo;
  String? contacto;
  double? duracion;
  double? distancia;
  List<ImagenCompany>? imagenescompania = [];
  List<Compania> toList = [];
  Compania(
      {this.idclasificacion,
      this.nombreclasificacion,
      this.idcompania,
      this.rfc,
      this.logotipo,
      this.paginaweb,
      this.nombre,
      this.love,
      this.comentario,
      this.rating,
      this.primeraimagen,
      this.actividad,
      this.direccion,
      this.latitud,
      this.longitud,
      this.correo,
      this.contacto,
      this.duracion,
      this.distancia,
      this.imagenescompania});

  factory Compania.fromJson(Map<String, dynamic> json) => Compania(
        idclasificacion: json["idclasificacion"],
        nombreclasificacion: json["nombreclasificacion"],
        idcompania: json["idcompania"],
        rfc: json["rfc"],
        logotipo: json["logotipo"],
        paginaweb: json["paginaweb"],
        nombre: json["nombre"],
        love: json["love"],
        comentario: json["comentario"],
        rating: json["rating"] is String
            ? double.parse(json["rating"])
            : isInteger(json["rating"])
                ? json["rating"].toDouble()
                : json["rating"],
        primeraimagen: json["primeraimagen"],
        actividad: json["actividad"],
        direccion: json["direccion"],
        latitud: json["latitud"] is String
            ? double.parse(json["latitud"])
            : isInteger(json["latitud"])
                ? json["latitud"].toDouble()
                : json["latitud"],
        longitud: json["longitud"] is String
            ? double.parse(json["longitud"])
            : isInteger(json["longitud"])
                ? json["longitud"].toDouble()
                : json["longitud"],
        correo: json["correo"],
        contacto: json["contacto"],
        duracion: 0.0,
        distancia: (json["distancia"] != null)
            ? json["distancia"] is String
                ? double.parse(json["distancia"])
                : isInteger(json["distancia"])
                    ? json["distancia"].toDouble()
                    : json["distancia"]
            : 0.0,
        imagenescompania: json["imagenes"] == null
            ? []
            : List<ImagenCompany>.from(
                json["imagenes"].map((model) => ImagenCompany.fromJson(model))),
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
        "love": love,
        "comentario": comentario,
        "rating": rating,
        "primeraimagen": primeraimagen,
        "actividad": actividad,
        "direccion": direccion,
        "latitud": latitud,
        "longitud": longitud,
        "correo": correo,
        "contacto": contacto,
        "duracion": duracion,
        "distancia": distancia,
        "imagenescompania": imagenescompania!.map((e) => e.toJson()).toList(),
      };
  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}

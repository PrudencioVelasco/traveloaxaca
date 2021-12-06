// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

import 'package:traveloaxaca/models/imagen_tour.dart';

Tour tourFromJson(String str) => Tour.fromJson(json.decode(str));

String tourToJson(Tour data) => json.encode(data.toJson());

class Tour {
  int? idtour;
  int? idcompania;
  String? nombrecompania;
  String? nombre;
  String? descripcion;
  String? informacion;
  String? actividad;
  double? precioxpersona;
  String? horainicio;
  String? fechainicio;
  String? horafinal;
  String? fechafinal;
  double? rating;
  int? totalcomentarios;
  int? totalloves;
  //int? activo;
  List<Tour> toList = [];
  List<ImagenTour>? imagenestour = [];
  Tour({
    this.idtour,
    this.idcompania,
    this.nombre,
    this.nombrecompania,
    this.descripcion,
    this.informacion,
    this.actividad,
    this.precioxpersona,
    this.horainicio,
    this.fechainicio,
    this.horafinal,
    this.fechafinal,
    this.rating,
    this.totalcomentarios,
    this.totalloves,
    this.imagenestour,
    //this.activo,
  });

  factory Tour.fromJson(Map<String, dynamic> json) => Tour(
        idtour: json["idtour"],
        idcompania: json["idcompania"],
        nombrecompania: json["nombrecompania"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        informacion: json["informacion"],
        actividad: json["actividad"],
        precioxpersona: json["precioxpersona"] is String
            ? double.parse(json["precioxpersona"])
            : isInteger(json["precioxpersona"])
                ? json["precioxpersona"].toDouble()
                : json["precioxpersona"],
        horainicio: json["horainicio"],
        fechainicio: json["fechainicio"],
        horafinal: json["horafinal"],
        fechafinal: json["fechafinal"],
        rating: json["rating"] is String
            ? double.parse(json["rating"])
            : isInteger(json["rating"])
                ? json["rating"].toDouble()
                : json["rating"],
    totalcomentarios: json["totalcomentarios"],
    totalloves: json["totalloves"],
        imagenestour: json["imagenestour"] == null
            ? []
            : List<ImagenTour>.from(json["imagenestour"]
                .map((model) => ImagenTour.fromJson(model))),
        //  activo: json["activo"],
      );

  Tour.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((element) {
      Tour tour = Tour.fromJson(element);
      toList.add(tour);
    });
  }
  Map<String, dynamic> toJson() => {
        "idtour": idtour,
        "idcompania": idcompania,
        "nombrecompania": nombrecompania,
        "nombre": nombre,
        "descripcion": descripcion,
        "informacion": informacion,
        "actividad": actividad,
        "precioxpersona": precioxpersona,
        "horainicio": horainicio,
        "fechainicio": fechainicio,
        "horafinal": horafinal,
        "fechafinal": fechafinal,
        "rating": rating,
    "totalcomentarios": totalcomentarios,
    "totalloves": totalloves,
        "imagenestour": imagenestour!.map((e) => e.toJson()).toList(),
        //"activo": activo,
      };
  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}

// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

import 'package:traveloaxaca/models/horario.dart';
import 'package:traveloaxaca/models/imagen_compani.dart';
import 'package:traveloaxaca/models/imagen_tour.dart';
import 'package:traveloaxaca/models/telefono.dart';
import 'package:traveloaxaca/models/tour.dart';

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
  List<Telefono>? telefonos = [];
  List<Horario>? horarios = [];
  List<Tour>? tours = [];
  List<ImagenTour>? imagenestour = [];
  List<ImagenCompany>? imagenescompania = [];
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
    this.telefonos,
    this.tours,
    this.imagenestour,
    this.imagenescompania,
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
        telefonos: json["telefonos"] == null
            ? []
            : List<Telefono>.from(
                json["telefonos"].map((model) => Telefono.fromJson(model))),
        tours: json["tours"] == null
            ? []
            : List<Tour>.from(
                json["tours"].map((model) => Tour.fromJson(model))),
        imagenestour: json["imagenestour"] == null
            ? []
            : List<ImagenTour>.from(json["imagenestour"]
                .map((model) => ImagenTour.fromJson(model))),
        imagenescompania: json["imagenescompania"] == null
            ? []
            : List<ImagenCompany>.from(json["imagenescompania"]
                .map((model) => ImagenCompany.fromJson(model))),
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
        "telefonos": List<dynamic>.from(telefonos!.map((x) => x.toJson())),
        "tours": List<dynamic>.from(tours!.map((x) => x.toJson())),
        "imagenestour":
            List<dynamic>.from(imagenestour!.map((x) => x.toJson())),
        "imagenescompania":
            List<dynamic>.from(imagenescompania!.map((x) => x.toJson())),
      };
}

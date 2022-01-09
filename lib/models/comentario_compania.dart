// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

import 'package:traveloaxaca/models/imagen_comentario_compania.dart';

ComentarioCompania comentarioCompaniaFromJson(String str) =>
    ComentarioCompania.fromJson(json.decode(str));

String comentarioCompaniaToJson(ComentarioCompania data) =>
    json.encode(data.toJson());

class ComentarioCompania {
  int? idcomentario;
  int? idcompania;
  int? idconquienvisito;
  double? rating;
  String? comentario;
  String? fechavisito;
  int? eliminado;
  String? fecharegistro;
  int? idusuario;
  String? uid;
  String? userName;
  String? imageUrl;
  String? fecha;
  List<ComentarioCompania> toList = [];
  List<ImagenComentarioCompania>? imagenes = [];
  ComentarioCompania(
      {this.idcomentario,
      this.idcompania,
      this.idconquienvisito,
      this.rating,
      this.comentario,
      this.fechavisito,
      this.eliminado,
      this.fecharegistro,
      this.idusuario,
      this.uid,
      this.userName,
      this.imageUrl,
      this.fecha,
      this.imagenes});

  factory ComentarioCompania.fromJson(Map<String, dynamic> json) =>
      ComentarioCompania(
        idcomentario: json["idcomentario"],
        idcompania: json["idcompania"],
        idconquienvisito: json["idconquienvisito"],
        rating: json["rating"] is String
            ? double.parse(json["rating"])
            : isInteger(json["rating"])
                ? json["rating"].toDouble()
                : json["rating"],
        comentario: json["comentario"],
        fechavisito: json["fechavisito"],
        eliminado: json["eliminado"],
        fecharegistro: json["fecharegistro"],
        idusuario: json["idusuario"],
        uid: json["uid"],
        userName: json["userName"],
        imageUrl: json["imageUrl"],
        fecha: json["fecha"],
        imagenes: (json["imagenes"] == null || json["imagenes"] == '')
            ? []
            : List<ImagenComentarioCompania>.from(
                jsonDecode(json["imagenes"].toString())
                    .map((model) => ImagenComentarioCompania.fromJson(model))),
      );
  ComentarioCompania.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((element) {
      ComentarioCompania comentarioCompania =
          ComentarioCompania.fromJson(element);
      toList.add(comentarioCompania);
    });
  }
  Map<String, dynamic> toJson() => {
        "idcomentario": idcomentario,
        "idcompania": idcompania,
        "idconquienvisito": idconquienvisito,
        "rating": rating,
        "comentario": comentario,
        "fechavisito": fechavisito,
        "eliminado": eliminado,
        "fecharegistro": fecharegistro,
        "idusuario": idusuario,
        "uid": uid,
        "userName": userName,
        "imageUrl": imageUrl,
        "fecha": fecha,
        "imagenes": (imagenes!.length > 0)
            ? imagenes!.map((e) => e.toJson()).toList()
            : [],
      };
  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}

// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

ComentarioTour comentarioTourFromJson(String str) =>
    ComentarioTour.fromJson(json.decode(str));

String comentarioTourToJson(ComentarioTour data) => json.encode(data.toJson());

class ComentarioTour {
  int? idcomentario;
  int? idtour;
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
  List<ComentarioTour> toList = [];
  ComentarioTour({
    this.idcomentario,
    this.idtour,
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
  });

  factory ComentarioTour.fromJson(Map<String, dynamic> json) => ComentarioTour(
        idcomentario: json["idcomentario"],
        idtour: json["idtour"],
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
      );
  ComentarioTour.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((element) {
      ComentarioTour comentarioTour = ComentarioTour.fromJson(element);
      toList.add(comentarioTour);
    });
  }
  Map<String, dynamic> toJson() => {
        "idcomentario": idcomentario,
        "idtour": idtour,
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
      };
  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}

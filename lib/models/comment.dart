// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

Comentario comentarioFromJson(String str) =>
    Comentario.fromJson(json.decode(str));

String comentarioToJson(Comentario data) => json.encode(data.toJson());

class Comentario {
  int? idcomentario;
  int? idusuario;
  String? uid;
  String? userName;
  String? imageUrl;
  String? comentario;
  String? fecha;
  double? rating;
  List<Comentario> toList = [];
  Comentario({
    this.idcomentario,
    this.idusuario,
    this.uid,
    this.userName,
    this.imageUrl,
    this.comentario,
    this.fecha,
    this.rating,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(
        idcomentario: json["idcomentario"],
        idusuario: json["idusuario"],
        uid: json["uid"],
        userName: json["userName"],
        imageUrl: json["imageUrl"],
        comentario: json["comentario"],
        fecha: json["fecha"],
        rating: json["rating"] is String
            ? double.parse(json["rating"])
            : isInteger(json["rating"])
                ? json["rating"].toDouble()
                : json["rating"],
      );
  Comentario.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      Comentario comentario = Comentario.fromJson(element);
      toList.add(comentario);
    });
  }
  Map<String, dynamic> toJson() => {
        "idcomentario": idcomentario,
        "idusuario": idusuario,
        "uid": uid,
        "userName": userName,
        "imageUrl": imageUrl,
        "comentario": comentario,
        "fecha": fecha,
        "rating": rating,
      };
  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}

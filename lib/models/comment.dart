// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

Comentario comentarioFromJson(String str) =>
    Comentario.fromJson(json.decode(str));

String comentarioToJson(Comentario data) => json.encode(data.toJson());

class Comentario {
  int? idcomentario;
  String? uid;
  String? userName;
  String? imageUrl;
  String? comentario;
  String? fecha;
  List<Comentario> toList = [];
  Comentario({
    this.idcomentario,
    this.uid,
    this.userName,
    this.imageUrl,
    this.comentario,
    this.fecha,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(
        idcomentario: json["idcomentario"],
        uid: json["uid"],
        userName: json["userName"],
        imageUrl: json["imageUrl"],
        comentario: json["comentario"],
        fecha: json["fecha"],
      );
  Comentario.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      Comentario actividad = Comentario.fromJson(element);
      toList.add(actividad);
    });
  }
  Map<String, dynamic> toJson() => {
        "idcomentario": idcomentario,
        "uid": uid,
        "userName": userName,
        "imageUrl": imageUrl,
        "comentario": comentario,
        "fecha": fecha,
      };
}

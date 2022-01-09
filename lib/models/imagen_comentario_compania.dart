// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

ImagenComentarioCompania imagenComentarioCompaniaFromJson(String str) =>
    ImagenComentarioCompania.fromJson(json.decode(str));

String imagenComentarioCompaniaToJson(ImagenComentarioCompania data) =>
    json.encode(data.toJson());

class ImagenComentarioCompania {
  int? idimagencomentariocompania;
  int? idcomentariocompania;
  String? nombreimagen;
  String? imagenurl;
  List<ImagenComentarioCompania> toList = [];
  ImagenComentarioCompania({
    this.idimagencomentariocompania,
    this.idcomentariocompania,
    this.nombreimagen,
    this.imagenurl,
  });

  factory ImagenComentarioCompania.fromJson(Map<String, dynamic> json) =>
      ImagenComentarioCompania(
        idimagencomentariocompania: json["idimagencomentariocompania"],
        idcomentariocompania: json["idcomentariocompania "],
        nombreimagen: json["nombreimagen"],
        imagenurl: json["imagenurl"],
      );
  ImagenComentarioCompania.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      ImagenComentarioCompania imagen =
          ImagenComentarioCompania.fromJson(element);
      toList.add(imagen);
    });
  }
  Map<String, dynamic> toJson() => {
        "idimagencomentariocompania": idimagencomentariocompania,
        "idcomentariocompania ": idcomentariocompania,
        "nombreimagen": nombreimagen,
        "imagenurl": imagenurl,
      };
}

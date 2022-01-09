// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

ImagenComentarioLugar imagenComentarioLugarFromJson(String str) =>
    ImagenComentarioLugar.fromJson(json.decode(str));

String imagenComentarioLugarToJson(ImagenComentarioLugar data) =>
    json.encode(data.toJson());

class ImagenComentarioLugar {
  int? idimagencomentariolugar;
  int? idcomentariolugar;
  String? nombreimagen;
  String? imagenurl;
  List<ImagenComentarioLugar> toList = [];
  ImagenComentarioLugar({
    this.idimagencomentariolugar,
    this.idcomentariolugar,
    this.nombreimagen,
    this.imagenurl,
  });

  factory ImagenComentarioLugar.fromJson(Map<String, dynamic> json) =>
      ImagenComentarioLugar(
        idimagencomentariolugar: json["idimagencomentariolugar"],
        idcomentariolugar: json["idcomentariolugar "],
        nombreimagen: json["nombreimagen"],
        imagenurl: json["imagenurl"],
      );
  ImagenComentarioLugar.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      ImagenComentarioLugar imagen = ImagenComentarioLugar.fromJson(element);
      toList.add(imagen);
    });
  }
  Map<String, dynamic> toJson() => {
        "idimagencomentariolugar": idimagencomentariolugar,
        "idcomentariolugar ": idcomentariolugar,
        "nombreimagen": nombreimagen,
        "imagenurl": imagenurl,
      };
}

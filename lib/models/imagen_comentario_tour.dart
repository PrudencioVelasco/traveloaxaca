// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

ImagenComentarioTour imagenComentarioTourFromJson(String str) =>
    ImagenComentarioTour.fromJson(json.decode(str));

String imagenComentarioTourToJson(ImagenComentarioTour data) =>
    json.encode(data.toJson());

class ImagenComentarioTour {
  int? idimagencomentariotour;
  int? idcomentariotour;
  String? nombreimagen;
  String? imagenurl;
  List<ImagenComentarioTour> toList = [];
  ImagenComentarioTour({
    this.idimagencomentariotour,
    this.idcomentariotour,
    this.nombreimagen,
    this.imagenurl,
  });

  factory ImagenComentarioTour.fromJson(Map<String, dynamic> json) =>
      ImagenComentarioTour(
        idimagencomentariotour: json["idimagencomentariotour"],
        idcomentariotour: json["idcomentariotour "],
        nombreimagen: json["nombreimagen"],
        imagenurl: json["imagenurl"],
      );
  ImagenComentarioTour.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      ImagenComentarioTour imagen = ImagenComentarioTour.fromJson(element);
      toList.add(imagen);
    });
  }
  Map<String, dynamic> toJson() => {
        "idimagencomentariotour": idimagencomentariotour,
        "idcomentariotour ": idcomentariotour,
        "nombreimagen": nombreimagen,
        "imagenurl": imagenurl,
      };
}

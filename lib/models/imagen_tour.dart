// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

ImagenTour imagentourFromJson(String str) =>
    ImagenTour.fromJson(json.decode(str));

String imagentourToJson(ImagenTour data) => json.encode(data.toJson());

class ImagenTour {
  int? idimagentour;
  int? idtour;
  String? nombreimagen;
  String? url;
  int? tipousuario;
  List<ImagenTour> toList = [];
  ImagenTour({
    this.idimagentour,
    this.idtour,
    this.nombreimagen,
    this.url,
    this.tipousuario,
  });

  factory ImagenTour.fromJson(Map<String, dynamic> json) => ImagenTour(
        idimagentour: json["idimagentour"],
        idtour: json["idtour"],
        nombreimagen: json["nombreimagen"],
        url: json["url"],
        tipousuario: json["tipousuario"],
      );
  ImagenTour.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((element) {
      ImagenTour imagenTour = ImagenTour.fromJson(element);
      toList.add(imagenTour);
    });
  }
  Map<String, dynamic> toJson() => {
        "idimagentour": idimagentour,
        "idtour": idtour,
        "nombreimagen": nombreimagen,
        "url": url,
        "tipousuario": tipousuario,
      };
}

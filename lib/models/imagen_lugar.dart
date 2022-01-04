// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

ImagenLugar imagenlugarFromJson(String str) =>
    ImagenLugar.fromJson(json.decode(str));

String imagenlugarToJson(ImagenLugar data) => json.encode(data.toJson());

class ImagenLugar {
  int? idimagenlugar;
  int? idlugar;
  String? nombreimagen;
  String? url;
  int? tipousuario;
  List<ImagenLugar> toList = [];
  ImagenLugar({
    this.idimagenlugar,
    this.idlugar,
    this.nombreimagen,
    this.url,
    this.tipousuario,
  });

  factory ImagenLugar.fromJson(Map<String, dynamic> json) => ImagenLugar(
        idimagenlugar: json["idimagenlugar"],
        idlugar: json["idlugar"],
        nombreimagen: json["nombreimagen"],
        url: json["url"],
        tipousuario: json["tipousuario"],
      );
  ImagenLugar.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((element) {
      ImagenLugar imagenTour = ImagenLugar.fromJson(element);
      toList.add(imagenTour);
    });
  }
  Map<String, dynamic> toJson() => {
        "idimagenlugar": idimagenlugar,
        "idlugar": idlugar,
        "nombreimagen": nombreimagen,
        "url": url,
        "tipousuario": tipousuario,
      };
}

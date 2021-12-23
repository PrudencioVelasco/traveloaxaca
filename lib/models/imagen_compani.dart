// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);

import 'dart:convert';

ImagenCompany imagencompanyFromJson(String str) =>
    ImagenCompany.fromJson(json.decode(str));

String imagencompanyToJson(ImagenCompany data) => json.encode(data.toJson());

class ImagenCompany {
  int? idimagencompania;
  int? idcompania;
  String? nombreimagen;
  String? url;
  int? tipousuario;
  List<ImagenCompany> toList = [];
  ImagenCompany({
    this.idimagencompania,
    this.idcompania,
    this.nombreimagen,
    this.url,
    this.tipousuario,
  });

  factory ImagenCompany.fromJson(Map<String, dynamic> json) => ImagenCompany(
        idimagencompania: json["idimagencompania"],
        idcompania: json["idcompania"],
        nombreimagen: json["nombreimagen"],
        url: json["url"],
        tipousuario: json["tipousuario"],
      );
  ImagenCompany.fromJsonToList(List<dynamic> jsonList) {
    jsonList.forEach((element) {
      ImagenCompany imagenCompany = ImagenCompany.fromJson(element);
      toList.add(imagenCompany);
    });
  }
  Map<String, dynamic> toJson() => {
        "idimagencompania": idimagencompania,
        "idcompania": idcompania,
        "nombreimagen": nombreimagen,
        "url": url,
        "tipousuario": tipousuario,
      };
}

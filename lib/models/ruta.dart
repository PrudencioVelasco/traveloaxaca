import 'dart:convert';

Ruta rutaFromJson(String str) => Ruta.fromJson(json.decode(str));

String rutaToJson(Ruta data) => json.encode(data.toJson());

class Ruta {
  int? idruta;
  int? idclasificacion;
  String? nombre;
  String? slogan;
  String? subtituloslogan;
  String? imagen;
  String? descripcion;
  int? visible;
  int? principal;
  List<Ruta> toList = [];
  Ruta({
    required this.idruta,
    required this.idclasificacion,
    this.nombre,
    this.slogan,
    this.subtituloslogan,
    this.imagen,
    this.descripcion,
    this.visible,
    this.principal,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) => Ruta(
        idruta: json["idruta"],
        idclasificacion: json["idclasificacion"],
        nombre: json["nombre"],
        slogan: json["slogan"],
        subtituloslogan: json["subtituloslogan"],
        imagen: json["imagen"],
        descripcion: json["descripcion"],
        visible: json["visible"],
        principal: json["principal"],
      );
  Ruta.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      Ruta imagen = Ruta.fromJson(element);
      toList.add(imagen);
    });
  }
  Map<String, dynamic> toJson() => {
        "idruta": idruta,
        "idclasificacion": idclasificacion,
        "nombre": nombre,
        "slogan": slogan,
        "subtituloslogan": subtituloslogan,
        "imagen": imagen,
        "descripcion": descripcion,
        "visible": visible,
        "principal": principal,
      };
}

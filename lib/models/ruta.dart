import 'dart:convert';

Ruta rutaFromJson(String str) => Ruta.fromJson(json.decode(str));

String rutaToJson(Ruta data) => json.encode(data.toJson());

class Ruta {
  int? idruta;
  int? idclasificacion;
  String? nombre;
  String? imagen;
  String? descripcion;
  int? visible;
  List<Ruta> toList = [];
  Ruta({
    required this.idruta,
    required this.idclasificacion,
    this.nombre,
    this.imagen,
    this.descripcion,
    this.visible,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) => Ruta(
        idruta: json["idruta"],
        idclasificacion: json["idclasificacion"],
        nombre: json["nombre"],
        imagen: json["imagen"],
        descripcion: json["descripcion"],
        visible: json["visible"],
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
        "imagen": imagen,
        "descripcion": descripcion,
        "visible": visible,
      };
}

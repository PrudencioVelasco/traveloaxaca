// To parse this JSON data, do
//
//     final lugar = lugarFromJson(jsonString);
import 'dart:convert';

Lugar lugarFromJson(String str) => Lugar.fromJson(json.decode(str));

String lugarToJson(Lugar data) => json.encode(data.toJson());

class Lugar {
  int? idlugar;
  String? nombre;
  String? direccion;
  double? latitud;
  double? longitud;
  String? descripcion;
  String? historia;
  String? resena;
  int? love;
  int? comentario;
  double? rating;
  String? primeraimagen;
  String? nombreclasificacion;
  //String? actividades;
  int? principal;
  //List<Imagen?> imagenes = [];
  //List<Actividad?> actividades = [];
  List<Lugar> toList = [];
  int? numero;
  Lugar({
    this.idlugar,
    this.nombre,
    this.direccion,
    this.latitud,
    this.longitud,
    this.descripcion,
    this.historia,
    this.resena,
    this.love,
    this.comentario,
    this.rating,
    this.primeraimagen,
    this.nombreclasificacion,
    // required this.imagenes,
    //required this.actividades,
    this.principal,
    this.numero,
  });

  factory Lugar.fromJson(Map<String, dynamic> json) => Lugar(
        idlugar: json["idlugar"],
        nombre: json["nombre"],
        direccion: json["direccion"],
        latitud: json["latitud"] is String
            ? double.parse(json["latitud"])
            : isInteger(json["latitud"])
                ? json["latitud"].toDouble()
                : json["latitud"],
        longitud: json["longitud"] is String
            ? double.parse(json["longitud"])
            : isInteger(json["longitud"])
                ? json["longitud"].toDouble()
                : json["longitud"],
        descripcion: json["descripcion"],
        historia: json["historia"],
        resena: json["resena"],
        love: json["love"],
        comentario: json["comentario"],
    rating: json["rating"] is String
        ? double.parse(json["rating"])
        : isInteger(json["rating"])
        ? json["rating"].toDouble()
        : json["rating"],
        primeraimagen: json["primeraimagen"],
        nombreclasificacion: json["nombreclasificacion"],
        numero: json["numero"],
        //imagenes: json["imagenes"],
        /*actividades: json["actividades"] == null
            ? []
            : List<Actividad>.from(
                json["actividades"].map((model) => Imagen.fromJson(model))),

        principal: json["principal"],
        imagenes: json["imagenes"] == null
            ? []
            : List<Imagen>.from(
                json["imagenes"].map((model) => Imagen.fromJson(model))),
                */
      );
  Lugar.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      Lugar lugar = Lugar.fromJson(element);
      toList.add(lugar);
    });
  }
  Map<String, dynamic> toJson() => {
        "idlugar": idlugar,
        "nombre": nombre,
        "direccion": direccion,
        "latitud": latitud,
        "longitud": longitud,
        "descripcion": descripcion,
        "historia": historia,
        "resena": resena,
        "love": love,
        "comentario": comentario,
        "rating": rating,
        "primeraimagen": primeraimagen,
        "nombreclasificacion": nombreclasificacion,
        "principal": principal,
        "numero": numero,
      };

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}

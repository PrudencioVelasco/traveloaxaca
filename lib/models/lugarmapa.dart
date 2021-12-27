import 'package:traveloaxaca/models/actividad.dart';

class LugarMapa {
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
  int? principal;
  List<Actividad?>? actividades = [];
  int? numero;
  String? geometria;
  double? distancia;
  double? duracion;
  LugarMapa(
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
    this.actividades,
    this.principal,
    this.numero,
    this.geometria,
    this.distancia,
    this.duracion,
  );
}

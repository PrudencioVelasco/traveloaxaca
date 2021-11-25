import 'dart:convert';

ConquienVisito conquienvisitoFromJson(String str) =>
    ConquienVisito.fromJson(json.decode(str));

String conquienvisitoToJson(ConquienVisito data) => json.encode(data.toJson());

class ConquienVisito {
  int? idconquienvisito;
  String? nombre;
  int? activo;
  List<ConquienVisito> toList = [];
  ConquienVisito({
    this.idconquienvisito,
    this.nombre,
    this.activo,
  });

  factory ConquienVisito.fromJson(Map<String, dynamic> json) => ConquienVisito(
        idconquienvisito: json["idconquienvisito"],
        nombre: json["nombre"],
        activo: json["activo"],
      );
  ConquienVisito.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      ConquienVisito actividad = ConquienVisito.fromJson(element);
      toList.add(actividad);
    });
  }
  Map<String, dynamic> toJson() => {
        "idconquienvisito": idconquienvisito,
        "nombre": nombre,
        "activo": activo,
      };
}

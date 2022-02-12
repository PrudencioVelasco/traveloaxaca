import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/actividad.dart';
import 'package:traveloaxaca/models/response_api.dart';

class ActividadBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    refresh();
  }

  Future<List<Actividad?>> obtenerActividades() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/actividad';
    try {
      Uri url = Uri.https(_url, '$_api/todasActividades');
      // String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Actividad actividad = Actividad.fromJsonToList(responseApi.data);
      return actividad.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Actividad?>> obtenerActividadLugar(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/actividad';
    try {
      Uri url = Uri.https(_url, '$_api/obtenerActividadLugar');
      String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Actividad actividad = Actividad.fromJsonToList(responseApi.data);
      return actividad.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  onRefresh() {
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/telefono.dart';

class CompaniaBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    refresh();
  }

  Future<Compania?> obtenerCompaniaClasificacion(int idclasificacion) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/compania';
    try {
      Uri url = Uri.http(_url, '$_api/mostrarCompaniasXClasificacion');
      String bodyParams = json.encode({'idclasificacion': idclasificacion});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Compania compania = Compania.fromJson(responseApi.data);
      return compania;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<List<Telefono>?> obtenerTelefonosCompania(int idcompania) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/telefono';
    try {
      Uri url = Uri.http(_url, '$_api/telefonosCompania');
      String bodyParams = json.encode({'idcompania': idcompania});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Telefono telefono = Telefono.fromJsonToList(responseApi.data);
      return telefono.toList;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<Compania?> detalleCompania(int idcompania) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/compania';
    try {
      Uri url = Uri.http(_url, '$_api/detallecompania');
      String bodyParams = json.encode({'idcompania': idcompania});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Compania compania = Compania.fromJson(responseApi.data);
      return compania;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  onRefresh() {
    notifyListeners();
  }
}

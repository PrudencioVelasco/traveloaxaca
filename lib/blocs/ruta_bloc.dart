import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/ruta.dart';

class RutasBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    getData();
    refresh();
  }

  List<Ruta> _data = [];
  List<Ruta> get data => _data;

  Future<List<Ruta?>> getData() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/ruta';
    try {
      Uri url = Uri.http(_url, '$_api/todasRutasVisibles');
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Ruta lug = Ruta.fromJsonToList(responseApi.data);
      return _data = lug.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Ruta?>> obtenerRutasPrincipales() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/ruta';
    try {
      Uri url = Uri.http(_url, '$_api/todasRutasPrincipales');
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Ruta lug = Ruta.fromJsonToList(responseApi.data);
      return _data = lug.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Lugar?>> getLugaresRuta(int idruta) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/ruta';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerLugaresRuta');
      String bodyParams = json.encode({'idruta': idruta});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Lugar lug = Lugar.fromJsonToList(responseApi.data);
      return lug.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  onRefresh() {
    _data.clear();
    getData();
    notifyListeners();
  }
}

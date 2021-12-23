import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/imagen.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/response_api.dart';

class PopularPlacesBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    getData();
    refresh();
  }

  List<Lugar> _data = [];
  List<Lugar> get data => _data;

  Future<List<Lugar>?> getData() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.http(_url, '$_api/sliderLugaresTops');
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);

      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Lugar lug = Lugar.fromJsonToList(responseApi.data);
      return _data = lug.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Imagen?>> obtenerImagenesLugar(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerImagenesLugar');
      String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);

      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Imagen img = Imagen.fromJsonToList(responseApi.data);
      return img.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Lugar?>> obtenerLugaresDentroLugar(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerLugaresDentroLugar');
      String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);

      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Lugar lugar = Lugar.fromJsonToList(responseApi.data);
      return lugar.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<Lugar?> obtenerDetalleLugar(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerLugaresDentroLugar');
      String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Lugar lugar = Lugar.fromJsonToList(responseApi.data);
      return lugar;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  onRefresh() {
    _data.clear();
    getData();
    notifyListeners();
  }
}

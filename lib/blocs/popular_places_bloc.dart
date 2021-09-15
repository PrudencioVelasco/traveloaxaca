import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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
      // String bodyParams = json.encode({'valor': valor});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);

      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      //return responseApi.data;
      //lista = new List<Lugar>.from(responseApi.data);
      Lugar lug = Lugar.fromJsonToList(responseApi.data);
      return _data = lug.toList;

      // return lug.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
    //return null;
  }

  Future<List<Imagen>?> obtenerImagenesLugar(int idLugar) async {
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
      //return responseApi.data;
      //lista = new List<Lugar>.from(responseApi.data);
      Imagen img = Imagen.fromJsonToList(responseApi.data);
      //_data = img.toList;

      return img.toList;
    } catch (error) {
      print('Error: $error');
      return null;
    }
    //return null;
  }

  Future<List<Lugar>?> obtenerLugaresDentroLugar(int idLugar) async {
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
      //return responseApi.data;
      //lista = new List<Lugar>.from(responseApi.data);
      Lugar img = Lugar.fromJsonToList(responseApi.data);
      //_data = img.toList;

      return img.toList;
    } catch (error) {
      print('Error: $error');
      return null;
    }
    //return null;
  }

  onRefresh() {
    _data.clear();
    getData();
    notifyListeners();
  }
}

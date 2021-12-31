import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveloaxaca/models/response_api.dart';

class LugarBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    obtenerLugaresRecienVisitados();
    refresh();
  }

  SearchBloc() {
    getRecentSearchList();
  }

  List<String> _recentSearchData = [];
  List<String> get recentSearchData => _recentSearchData;

  List<Lugar> _recentSearchDataLugar = [];
  List<Lugar> get recentSearchDataLugar => _recentSearchDataLugar;

  Future getRecentSearchList() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData = sp.getStringList('recien_visitado') ?? [];
    notifyListeners();
  }

  Future addToSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.add(value);
    await sp.setStringList('recien_visitado', _recentSearchData);
    obtenerLugaresRecienVisitados();
    notifyListeners();
  }

  Future removeFromSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.remove(value);
    await sp.setStringList('recien_visitado', _recentSearchData);
    notifyListeners();
  }

  Future obtenerLugaresRecienVisitados() async {
    //recentSearchData.
    getRecentSearchList();
    if (_recentSearchData.length > 0) {
      String s = _recentSearchData.join(', ');
      String _url = Environment.API_DELIVERY;
      String _api = '/monarca/lugar';
      try {
        Uri url = Uri.http(_url, '$_api/buscarLugaresActivosIn');
        String bodyParams = json.encode({
          'idslugares': s,
        });
        Map<String, String> headers = {
          'Content-Type': 'application/json;charset=UTF-8',
          'Charset': 'utf-8'
        };
        final res = await http.post(url, headers: headers, body: bodyParams);
        final data = json.decode(res.body);
        ResponseApi responseApi = ResponseApi.fromJson(data);
        Lugar lug = Lugar.fromJsonToList(responseApi.data);
        _recentSearchDataLugar = lug.toList;
        notifyListeners();
        // return lug.toList;
      } catch (error) {
        print('Error: $error');
        // return [];
      }
    }
    //return [];
  }

  Future<List<Lugar?>> obtenerTodosLugares() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerTodosLugares');
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);

      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Lugar lugar = Lugar.fromJsonToList(responseApi.data);
      return lugar.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Lugar?>> obtenerTodosLugaresCercanos(
      double latitud, double longitud) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerTodosLugaresCercanos');
      String bodyParams = json.encode({
        'latitud': latitud,
        'longitud': longitud,
      });
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

  Future<Lugar?> obtenerDetalleLugar(int idlugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerDetalleLugar');
      String bodyParams = json.encode({
        'idlugar': idlugar,
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);

      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Lugar lugar = Lugar.fromJson(responseApi.data);
      return lugar;
      // return lugar.toList;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  saerchInitialize() {
    notifyListeners();
  }

  onRefresh() {
    notifyListeners();
    obtenerLugaresRecienVisitados();
  }
}

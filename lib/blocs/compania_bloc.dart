import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
/*
  SearchBloc (){
    getRecentSearchList();
  }
  */

  List<String> _recentSearchData = [];
  List<String> get recentSearchData => _recentSearchData;

  String _searchText = '';
  String get searchText => _searchText;

  bool _searchStarted = false;
  bool get searchStarted => _searchStarted;

  TextEditingController _textFieldCtrl = TextEditingController();
  TextEditingController get textfieldCtrl => _textFieldCtrl;
/*
  Future getRecentSearchList() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData = sp.getStringList('recent_search_data_categoria') ?? [];
    notifyListeners();
  }


  Future addToSearchList (String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.add(value);
    await sp.setStringList('recent_search_data_categoria', _recentSearchData);
    notifyListeners();
  }
  Future removeFromSearchList (String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.remove(value);
    await sp.setStringList('recent_search_data_categoria', _recentSearchData);
    notifyListeners();
  }
*/
  Future<List<Compania?>> getData(int idclasificacion) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/compania';
    try {
      Uri url = Uri.http(_url, '$_api/buscarCompania');
      String bodyParams = json.encode({
        'valor': _searchText.toLowerCase(),
        'idclasificacion': idclasificacion
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      Compania lug = Compania.fromJsonToList(responseApi.data);
      return lug.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  setSearchText(value) {
    _textFieldCtrl.text = value;
    _searchText = value;
    _searchStarted = true;
    notifyListeners();
  }

  saerchInitialize() {
    _textFieldCtrl.clear();
    _searchStarted = false;
    notifyListeners();
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

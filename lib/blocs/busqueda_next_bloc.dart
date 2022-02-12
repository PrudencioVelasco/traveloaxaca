import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:http/http.dart' as http;

class BusquedaNextBloc with ChangeNotifier {
  SearchBloc() {
    getRecentSearchList();
  }

  List<String> _recentSearchData = [];
  List<String> get recentSearchData => _recentSearchData;

  String _searchText = '';
  String get searchText => _searchText;

  bool _searchStarted = false;
  bool get searchStarted => _searchStarted;

  TextEditingController _textFieldCtrl = TextEditingController();
  TextEditingController get textfieldCtrl => _textFieldCtrl;

  Future getRecentSearchList() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData = sp.getStringList('recent_search_data') ?? [];
    notifyListeners();
  }

  Future addToSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.add(value);
    await sp.setStringList('recent_search_data', _recentSearchData);
    notifyListeners();
  }

  Future removeFromSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.remove(value);
    await sp.setStringList('recent_search_data', _recentSearchData);
    notifyListeners();
  }

  Future<List<Lugar>?> getData() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.https(_url, '$_api/buscarLugaresActivos');
      String bodyParams = json.encode({'valor': _searchText.toLowerCase()});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      Lugar lug = Lugar.fromJsonToList(responseApi.data);
      return lug.toList;
    } catch (error) {
      print('Error: $error');
      return null;
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
}

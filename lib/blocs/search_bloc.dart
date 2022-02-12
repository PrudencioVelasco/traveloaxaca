import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:http/http.dart' as http;

class SearchBloc with ChangeNotifier {
  BuildContext? context;
  Future? init(BuildContext context) async {
    this.context = context;
    getRecentSearchList();
  }

  // SearchBloc() {
  //   getRecentSearchList();
  // }

  String _searchText = '';
  String get searchText => _searchText;

  TextEditingController _textFieldCtrl = TextEditingController();
  TextEditingController get textfieldCtrl => _textFieldCtrl;

  List<String> _recentSearchData = [];
  List<String> get recentSearchData => _recentSearchData;

  bool _searchStarted = false;
  bool get searchStarted => _searchStarted;

  String parametroPasado = "";
  Future getRecentSearchList() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData = sp.getStringList('recent_search_data') ?? [];
    //notifyListeners();
  }

  Future addToSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.add(value);
    await sp.setStringList('recent_search_data', _recentSearchData);
    //notifyListeners();
  }

  Future removeFromSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.remove(value);
    await sp.setStringList('recent_search_data', _recentSearchData);
    //notifyListeners();
  }

  Future<List<Lugar>?> getData() async {
    parametroPasado = _textFieldCtrl.text;
    if (parametroPasado.isNotEmpty) {
      String _url = Environment.API_DELIVERY;
      String _api = '/monarca/lugar';
      //List<Lugar> lista = [];
      try {
        Uri url = Uri.https(_url, '$_api/buscarLugaresActivos');
        String bodyParams = json.encode({'valor': _textFieldCtrl.text});
        Map<String, String> headers = {
          'Content-Type': 'application/json;charset=UTF-8',
          'Charset': 'utf-8'
        };
        final res = await http.post(url, headers: headers, body: bodyParams);
        final data = json.decode(res.body);

        ResponseApi responseApi = ResponseApi.fromJson(data);
        //return responseApi.data;
        //lista = new List<Lugar>.from(responseApi.data);
        Lugar lug = Lugar.fromJsonToList(responseApi.data);
        return lug.toList;
      } catch (error) {
        print('Error: $error');
        return null;
      }
    } else {
      return null;
    }
    //return null;
  }

  setSearchText(value) {
    parametroPasado = value;
    _textFieldCtrl.text = value;
    _searchText = value;
    _searchStarted = true;
    notifyListeners();
  }

  saerchInitialize() {
    parametroPasado = "";
    _textFieldCtrl.clear();
    _searchStarted = false;
    notifyListeners();
  }
}

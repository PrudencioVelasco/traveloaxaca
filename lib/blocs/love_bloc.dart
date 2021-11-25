import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/models/response_api.dart';

class LoveBloc extends ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  SignInBloc _signInBloc = SignInBloc();
  String? _token = "";
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _token = await _signInBloc.getToken();
    refresh();
  }

  bool _mostrarMarcadoCorazon = false;
  int _totalLoves = 0;
  bool get mostrarMarcadoCorazon => _mostrarMarcadoCorazon;
  int get totalLoves => _totalLoves;
  Future onLoveIconClick(int idLugar) async {
    int totalLove = 0;
    totalLove = await obtenerLovePorUsuario(idLugar);

    if (totalLove == 0) {
      agregarLove(idLugar);
      _mostrarMarcadoCorazon = true;
    } else {
      eliminarLove(idLugar);
      _mostrarMarcadoCorazon = false;
    }
    _totalLoves = await obtenerTotalLove(idLugar);

    notifyListeners();
  }

  Future<bool> eliminarLove(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/love';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.http(_url, '$_api/eliminarLove');
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'x-token': token!
      };
      String bodyParams = json.encode({'idlugar': idLugar});

      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      return responseApi.success!;
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<ResponseApi?> agregarLove(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/love';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.http(_url, '$_api/agregarLove');
      String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'x-token': token!
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      return responseApi;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<int> obtenerLovePorUsuario(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/love';
    try {
      String? token = await _signInBloc.getToken();
      Uri url = Uri.http(_url, '$_api/totalLoveLugarUsuario');
      String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'x-token': token!
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      return responseApi.data;
    } catch (error) {
      print('Error: $error');
      return 0;
    }
  }

  Future principalTotalLoves(int idLugar) async {
    _totalLoves = await obtenerTotalLove(idLugar);
    if (_totalLoves == 0) {
      _mostrarMarcadoCorazon = false;
    } else {
      _mostrarMarcadoCorazon = true;
    }
    notifyListeners();
  }

  Future<int> obtenerTotalLove(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/love';
    try {
      Uri url = Uri.http(_url, '$_api/totalLove');
      String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      return responseApi.data;
    } catch (error) {
      print('Error: $error');
      return 0;
    }
  }

  onRefresh() {
    notifyListeners();
  }
}

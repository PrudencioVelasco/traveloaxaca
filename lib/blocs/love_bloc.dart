import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/response_api.dart';

class LoveBloc extends ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    refresh();
  }

  bool _mostrarMarcadoCorazon = false;
  //int _totalComentarios = 0;
  int _totalLoves = 0;
  bool get mostrarMarcadoCorazon => _mostrarMarcadoCorazon;
  // int get totalComentarios => _totalComentarios;
  int get totalLoves => _totalLoves;
  Future onLoveIconClick(int idLugar) async {
    int totalLove = 0;
    totalLove = await obtenerLovePorUsuario(idLugar, 1);

    if (totalLove == 0) {
      agregarLove(idLugar, 1);
      _mostrarMarcadoCorazon = true;
    } else {
      eliminarLove(idLugar, 1);
      _mostrarMarcadoCorazon = false;
    }
    _totalLoves = await obtenerTotalLove(idLugar);

    notifyListeners();
  }

  Future<bool> eliminarLove(int idLugar, int idUsuario) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/love';
    try {
      Uri url = Uri.http(_url, '$_api/eliminarLove');
      String bodyParams = json.encode({'idlugar': idLugar, 'idusuario': 1});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      //Categoria img = Categoria.fromJsonToList(responseApi.data);
      return responseApi.success!;
      // return responseApi.data;
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<bool> agregarLove(int idLugar, int idUsuario) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/love';
    try {
      Uri url = Uri.http(_url, '$_api/agregarLove');
      String bodyParams = json.encode({'idlugar': idLugar, 'idusuario': 1});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      //Categoria img = Categoria.fromJsonToList(responseApi.data);
      return responseApi.success!;
      // return responseApi.data;
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<int> obtenerLovePorUsuario(int idLugar, int idUsuario) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/love';
    try {
      Uri url = Uri.http(_url, '$_api/totalLoveLugarUsuario');
      String bodyParams =
          json.encode({'idlugar': idLugar, 'idusuario': idUsuario});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      //Categoria img = Categoria.fromJsonToList(responseApi.data);

      return responseApi.data;
    } catch (error) {
      print('Error: $error');
      return 0;
    }
    //return null;
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
      //Categoria img = Categoria.fromJsonToList(responseApi.data);

      return responseApi.data;
    } catch (error) {
      print('Error: $error');
      return 0;
    }
    //return null;
  }

  onRefresh() {
    notifyListeners();
  }
}

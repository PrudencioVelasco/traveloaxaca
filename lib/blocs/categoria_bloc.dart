import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/response_api.dart';

class CategoriaBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    obtenerTodascategorias();
    refresh();
  }

  void kilometros() async {}
  Future<List<Categoria?>> obtenerTodascategorias() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/categoria';
    try {
      Uri url = Uri.http(_url, '$_api/todasCategorias');
      // String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Categoria categoria = Categoria.fromJsonToList(responseApi.data);

      return categoria.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Categoria?>> obtenerTodascategoriasPrincipal() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/categoria';
    try {
      Uri url = Uri.http(_url, '$_api/todasCategoriasPrincipal');
      // String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Categoria categoria = Categoria.fromJsonToList(responseApi.data);

      return categoria.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Categoria?>> obtenercategoriasPorLugar(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/categoria';
    try {
      Uri url = Uri.http(_url, '$_api/categoriasPorLugar');
      String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Categoria categoria = Categoria.fromJsonToList(responseApi.data);

      return categoria.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Lugar>?> obtenerLugaresPorCategoria(int idcategoria) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerLugaresPorCategoria');
      String bodyParams = json.encode({'idclasificacion': idcategoria});
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
      return null;
    }
  }

  onRefresh() {
    obtenerTodascategorias();
    notifyListeners();
  }
}

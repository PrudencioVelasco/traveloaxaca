import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
      Categoria img = Categoria.fromJsonToList(responseApi.data);

      return img.toList;
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
      Categoria img = Categoria.fromJsonToList(responseApi.data);

      return img.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
    //return null;
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
    obtenerTodascategorias();
    notifyListeners();
  }
}

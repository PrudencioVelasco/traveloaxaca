import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/models/comentario_tour.dart';
import 'package:traveloaxaca/models/love_tour.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/tour.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TourBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  SignInBloc _signInBloc = SignInBloc();
  String? _token = "";
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _token = await _signInBloc.getToken();
    // iniciarValor();
    refresh();
  }

  List<String> _recentSearchData = [];
  bool _contar = false;
  bool get contarcomentario => _contar;
  bool _contarlove = false;
  bool get contarlove => _contarlove;
  Future<List<Tour?>> todosLosTours(String? parametro) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/tour';
    try {
      Uri url = Uri.https(_url, '$_api/todosLosTours');
      String bodyParams =
          json.encode({'texto': (parametro != null) ? parametro : ''});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Tour tour = Tour.fromJsonToList(responseApi.data);
      return tour.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  void iniciarValor() {
    _contar = true;
    _contarlove = true;
    notifyListeners();
  }

  Future<List<LoveTour?>> lovesLovesTours(int idtour) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/tour';
    try {
      Uri url = Uri.https(_url, '$_api/todosLosLoves');
      String bodyParams = json.encode({'idtour': idtour});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      LoveTour loveTour = LoveTour.fromJsonToList(responseApi.data);
      return loveTour.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<ComentarioTour?>> commentsTours(int idtour) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/tour';
    try {
      Uri url = Uri.https(_url, '$_api/todosLosComentarios');
      String bodyParams = json.encode({'idtour': idtour});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      ComentarioTour comentarioTour =
          ComentarioTour.fromJsonToList(responseApi.data);
      return comentarioTour.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<ResponseApi?> agregarLoveTour(int idtour) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/love';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.https(_url, '$_api/agregarLoveTour');
      String bodyParams = json.encode({'idtour': idtour});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'x-token': token!
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      this.iniciarValor();
      _contarlove = true;
      notifyListeners();
      return responseApi;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<int> obtenerLoveTourUsuario(int idtour) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/love';
    try {
      String? token = await _signInBloc.getToken();
      Uri url = Uri.https(_url, '$_api/totalLoveTourUsuario');
      String bodyParams = json.encode({'idtour': idtour});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'x-token': token!
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);

      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      if (responseApi.success == true) {
        return responseApi.data;
      }
      return 0;
    } catch (error) {
      print('Error: $error');
      return 0;
    }
  }

  Future<ResponseApi?> agregarReporteComentarioTour(
      int idcomentario, int idmotivo, String? comentario) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.https(_url, '$_api/agregarReporteComentarioTour');
      String bodyParams = json.encode({
        'idcomentario': idcomentario,
        'idcausareporte': idmotivo,
        'comentario': comentario,
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      // await totalComentariosLugar(idlugar);
      return responseApi;
    } catch (error) {
      print('Error: $error');
    }
  }

  onRefresh() {
    notifyListeners();
  }

  Future guardarRecientesTour(int idtour) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.add(idtour.toString());
    await sp.setStringList("tour_recent_key", _recentSearchData);
  }

  Future obtenerRecientesTour() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData = sp.getStringList('tour_recent_key') ?? [];
  }

  Future eliminarDeRecientesTour(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.remove(value);
    await sp.setStringList('recent_search_data', _recentSearchData);
    notifyListeners();
  }
}

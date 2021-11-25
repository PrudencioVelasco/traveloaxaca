import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:http/http.dart' as http;
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/models/comment.dart';
import 'package:traveloaxaca/models/response_api.dart';

class CommentsBloc extends ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  SignInBloc _signInBloc = new SignInBloc();
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    refresh();
  }

  String date = "";
  String timestamp1 = "";
  int _totalComentarios = 0;
  int get totalComentarios => _totalComentarios;
  int _totalComentariosUsuarioLugar = 0;
  int get totalComentariosUsuarioLugar => _totalComentariosUsuarioLugar;

  Future<ResponseApi?> agregarCommentario(
      int idlugar, String comentario) async {
    String? token = await _signInBloc.getToken();
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.http(_url, '$_api/agregarComentario');
      String bodyParams =
          json.encode({'idlugar': idlugar, 'comentario': comentario});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'x-token': token!
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      await totalComentariosLugar(idlugar);
      return responseApi;
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<ResponseApi?> eliminarCommentario(
      int idcomentario, int idlugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.http(_url, '$_api/eliminarComentariov2');
      String bodyParams = json.encode({
        'idcomentario': idcomentario,
      });
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
    }
    await totalComentariosLugar(idlugar);
  }

  Future<List<Comentario?>> obtenerComentariosPorLugar(
      int idLugar, int idcomentario, int limite) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerComentariosPorLugar');
      String bodyParams = json.encode({
        'idlugar': idLugar,
        'idcomentario': (idcomentario == 0) ? '' : idcomentario,
        'limite': limite
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Comentario comentario = Comentario.fromJsonToList(responseApi.data);

      return comentario.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<Comentario?>> obtenerComentariosLugarv2(
      int idLugar, int idcomentario, int limite) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerComentariosLugarv2');
      String bodyParams = json.encode({
        'idlugar': idLugar,
        'idcomentario': (idcomentario == 0) ? '' : idcomentario,
        'limite': limite
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Comentario comentario = Comentario.fromJsonToList(responseApi.data);

      return comentario.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future totalComentariosLugar(int idLugar) async {
    this._totalComentarios = await obtenerTotalComentariosPorLugar(idLugar);
    this._totalComentariosUsuarioLugar =
        await obtenerTotalComentariosPorLugarUsuario(idLugar);
    notifyListeners();
  }

  Future<int> obtenerTotalComentariosPorLugar(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.http(_url, '$_api/totalComentarioLugar');
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

  Future<int> obtenerTotalComentariosPorLugarUsuario(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.http(_url, '$_api/totalComentarioLugarUsuario');
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

  Future<ResponseApi?> agregarComentarioLugar(int idlugar, double rating,
      String comentario, int conquienvisito, DateTime fechavisita) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.http(_url, '$_api/agregarComentarioLugar');
      String bodyParams = json.encode({
        'idlugar': idlugar,
        'idconquienvisito': conquienvisito,
        'rating': rating,
        'comentario': comentario,
        'fechavisito': fechavisita.toString()
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'x-token': token!
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

  Future<ResponseApi?> agregarReporteComentarioLugar(
      int idcomentario, int idmotivo, String? comentario) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.http(_url, '$_api/agregarReporteComentarioLugar');
      String bodyParams = json.encode({
        'idcomentario': idcomentario,
        'idcausareporte': idmotivo,
        'comentario': comentario,
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'x-token': token!
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
}

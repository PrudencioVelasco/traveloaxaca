import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:http/http.dart' as http;
import 'package:traveloaxaca/models/comment.dart';
import 'package:traveloaxaca/models/response_api.dart';

class CommentsBloc extends ChangeNotifier {
  BuildContext? context;
  TextEditingController _comentario = new TextEditingController();
  Future? init(BuildContext context) async {
    this.context = context;
  }

  String date = "";
  String timestamp1 = "";

  Future agregarCommentario(
      int idusuario, int idlugar, String comentario) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.http(_url, '$_api/agregarComentario');
      String bodyParams = json.encode({
        'idusuario': idusuario,
        'idlugar': idlugar,
        'comentario': comentario
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      // Comentario img = Atractivo.fromJsonToList(responseApi.data);
      return responseApi.success;
      // return img.toList;
    } catch (error) {
      print('Error: $error');
    }
  }

  Future eliminarCommentario(int idcomentario) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.http(_url, '$_api/eliminarComentario');
      String bodyParams = json.encode({
        'idusuario': idcomentario,
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      // Comentario img = Atractivo.fromJsonToList(responseApi.data);
      return responseApi.success;
      // return img.toList;
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<List<Comentario?>> obtenerComentariosPorLugar(int idLugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerComentariosPorLugar');
      String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Comentario img = Comentario.fromJsonToList(responseApi.data);

      return img.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
    //return null;
  }
}

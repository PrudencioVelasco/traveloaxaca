import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:http/http.dart' as http;
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/models/comentario_compania.dart';
import 'package:traveloaxaca/models/comentario_tour.dart';
import 'package:traveloaxaca/models/comment.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'dart:async';
import 'package:http_parser/http_parser.dart';

class CommentsBloc extends ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  SignInBloc _signInBloc = new SignInBloc();
  Dio _dio = Dio();
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
      Uri url = Uri.https(_url, '$_api/agregarComentario');
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

  Future<ResponseApi?> eliminarCommentarioLugar(
      int idcomentario, int idlugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.https(_url, '$_api/eliminarComentarioLugar');
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

  Future<ResponseApi?> eliminarCommentarioTour(int idcomentario) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.https(_url, '$_api/eliminarComentarioTour');
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
    //  await totalComentariosLugar(idlugar);
  }

  Future<ResponseApi?> eliminarCommentarioCompania(
      int idcomentario, int idlugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.https(_url, '$_api/eliminarComentarioCompania');
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
  }

  Future<List<Comentario?>> obtenerComentariosPorLugar(
      int idLugar, int idcomentario, int limite) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.https(_url, '$_api/obtenerComentariosPorLugar');
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

  Future<List<Comentario?>> obtenerComentariosLugar(
      int idLugar, int idcomentario, int limite) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.https(_url, '$_api/obtenerComentariosLugar');
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

  Future<List<ComentarioTour?>> obtenerComentariosTour(
      int idtour, int idcomentario, int limite) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.https(_url, '$_api/obtenerComentariosTour');
      String bodyParams = json.encode({
        'idtour': idtour,
        'idcomentario': (idcomentario == 0) ? '' : idcomentario,
        'limite': (limite == 0) ? '' : limite,
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      ComentarioTour comentario =
          ComentarioTour.fromJsonToList(responseApi.data);

      return comentario.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<ComentarioCompania?>> obtenerComentariosCompania(
      int idcompania, int idcomentario, int limite) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.https(_url, '$_api/obtenerComentariosCompania');
      String bodyParams = json.encode({
        'idcompania': idcompania,
        'idcomentario': (idcomentario == 0) ? '' : idcomentario,
        'limite': (limite == 0) ? '' : limite,
      });
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      ComentarioCompania comentario =
          ComentarioCompania.fromJsonToList(responseApi.data);

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
      Uri url = Uri.https(_url, '$_api/totalComentarioLugar');
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

  Future<int> obtenerTotalComentariosCompania(int idcompania) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.https(_url, '$_api/totalComentarioCompania');
      String bodyParams = json.encode({'idcompania': idcompania});
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
      Uri url = Uri.https(_url, '$_api/totalComentarioLugarUsuario');
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

  Future<bool> agregarComentarioLugar(
      int idlugar,
      double rating,
      String comentario,
      int conquienvisito,
      DateTime fechavisita,
      List<Asset> imagenes) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.https(_url, '$_api/agregarComentarioLugar');
      Uri urlSubirFoto = Uri.https(_url, '$_api/subirFotosComentarioLugar');
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
      if (responseApi.success!) {
        List<MultipartFile> imageList = [];
        if (imagenes.length > 0) {
          for (Asset asset in imagenes) {
            ByteData byteData = await asset.getByteData();
            List<int> imageData = byteData.buffer.asUint8List();
            MultipartFile multipartFile = new MultipartFile.fromBytes(
              imageData,
              filename: asset.name,
              contentType: MediaType("image", "jpg"),
            );
            imageList.add(multipartFile);
          }
          FormData formData = FormData.fromMap(
              {"multipartFiles": imageList, "idcomentario": responseApi.data});
          var response = await _dio.put(urlSubirFoto.toString(),
              data: formData, options: Options(headers: {'x-token': token}));
          if (response.statusCode == 200) {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      } else {
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<bool> agregarComentarioCompania(
      int idcompania,
      double rating,
      String comentario,
      int conquienvisito,
      DateTime fechavisita,
      List<Asset> imagenes) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.https(_url, '$_api/agregarComentarioCompania');
      Uri urlSubirFoto = Uri.https(_url, '$_api/subirFotosComentarioCompania');
      String bodyParams = json.encode({
        'idcompania': idcompania,
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
      if (responseApi.success!) {
        List<MultipartFile> imageList = [];
        if (imagenes.length > 0) {
          for (Asset asset in imagenes) {
            ByteData byteData = await asset.getByteData();
            List<int> imageData = byteData.buffer.asUint8List();
            MultipartFile multipartFile = new MultipartFile.fromBytes(
              imageData,
              filename: asset.name,
              contentType: MediaType("image", "jpg"),
            );
            imageList.add(multipartFile);
          }
          FormData formData = FormData.fromMap(
              {"multipartFiles": imageList, "idcomentario": responseApi.data});
          var response = await _dio.put(urlSubirFoto.toString(),
              data: formData, options: Options(headers: {'x-token': token}));
          if (response.statusCode == 200) {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      } else {
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<bool> subirFotosTour(int idtour, List<Asset> imagenes) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    Uri urlSubirFoto = Uri.https(_url, '$_api/subirFotosTour');
    List<MultipartFile> imageList = [];
    for (Asset asset in imagenes) {
      ByteData byteData = await asset.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      MultipartFile multipartFile = new MultipartFile.fromBytes(
        imageData,
        filename: asset.name,
        contentType: MediaType("image", "jpg"),
      );
      imageList.add(multipartFile);
    }
    FormData formData =
        FormData.fromMap({"multipartFiles": imageList, "idtour": idtour});
    var response = await _dio.put(urlSubirFoto.toString(),
        data: formData, options: Options(headers: {'x-token': token}));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> subirFotosLugar(int idlugar, List<Asset> imagenes) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    Uri urlSubirFoto = Uri.https(_url, '$_api/subirFotosLugar');
    List<MultipartFile> imageList = [];
    for (Asset asset in imagenes) {
      ByteData byteData = await asset.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      MultipartFile multipartFile = new MultipartFile.fromBytes(
        imageData,
        filename: asset.name,
        contentType: MediaType("image", "jpg"),
      );
      imageList.add(multipartFile);
    }
    FormData formData =
        FormData.fromMap({"multipartFiles": imageList, "idlugar": idlugar});
    var response = await _dio.put(urlSubirFoto.toString(),
        data: formData, options: Options(headers: {'x-token': token}));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> agregarComentarioTour(
      int idtour,
      double rating,
      String comentario,
      int conquienvisito,
      DateTime fechavisita,
      List<Asset> imagenes) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    String? token = await _signInBloc.getToken();
    try {
      Uri url = Uri.https(_url, '$_api/agregarComentarioTour');
      Uri urlSubirFoto = Uri.https(_url, '$_api/subirFotosComentarioTour');
      String bodyParams = json.encode({
        'idtour': idtour,
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
      if (responseApi.success!) {
        if (imagenes.length > 0) {
          List<MultipartFile> imageList = [];
          for (Asset asset in imagenes) {
            ByteData byteData = await asset.getByteData();
            List<int> imageData = byteData.buffer.asUint8List();
            MultipartFile multipartFile = new MultipartFile.fromBytes(
              imageData,
              filename: asset.name,
              contentType: MediaType("image", "jpg"),
            );
            imageList.add(multipartFile);
          }
          FormData formData = FormData.fromMap({
            "multipartFiles": imageList,
            "idcomentariotour": responseApi.data
          });
          var response = await _dio.put(urlSubirFoto.toString(),
              data: formData, options: Options(headers: {'x-token': token}));
          if (response.statusCode == 200) {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      } else {
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<ResponseApi?> agregarReporteComentarioLugar(
      int idcomentario, int idmotivo, String? comentario) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/comentario';
    try {
      Uri url = Uri.https(_url, '$_api/agregarReporteComentarioLugar');
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
}

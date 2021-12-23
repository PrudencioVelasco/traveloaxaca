import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/imagen_compani.dart';
import 'package:traveloaxaca/models/response_api.dart';

class ImagenBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    refresh();
  }

  Future<List<ImagenCompany?>> obtenerImagenesCompania(int idcompania) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/imagencompania';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerImagenes');
      String bodyParams = json.encode({'idcompania': idcompania});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      ImagenCompany imagenCompany =
          ImagenCompany.fromJsonToList(responseApi.data);
      return imagenCompany.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  onRefresh() {
    notifyListeners();
  }
}

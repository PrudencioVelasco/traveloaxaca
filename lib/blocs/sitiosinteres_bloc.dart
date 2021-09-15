import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/sitiosinteres.dart';
import 'package:traveloaxaca/models/response_api.dart';

class SitiosInteresBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    refresh();
  }

  Future<List<SitiosInteres>?> getSitiosInteres(int idlugar) async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/sitiosinteres';
    try {
      Uri url = Uri.http(_url, '$_api/obtenerSitiosInteresPorLugar');
      String bodyParams = json.encode({'idlugar': idlugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      SitiosInteres lug = SitiosInteres.fromJsonToList(responseApi.data);
      return lug.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  onRefresh() {
    notifyListeners();
  }
}

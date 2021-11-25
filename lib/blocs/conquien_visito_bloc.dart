import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/conquien_visitaste.dart';
import 'package:traveloaxaca/models/response_api.dart';

class ConQuienVisitoBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    refresh();
  }

  Future<List<ConquienVisito?>> obtenerConQuienVisito() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/conquienvisito';
    try {
      Uri url = Uri.http(_url, '$_api/todosConQuienVisito');
      // String bodyParams = json.encode({'idlugar': idLugar});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      ConquienVisito conquienvisito =
          ConquienVisito.fromJsonToList(responseApi.data);
      return conquienvisito.toList;
    } catch (error) {
      //print('Error: $error');
      return [];
    }
  }

  onRefresh() {
    notifyListeners();
  }
}

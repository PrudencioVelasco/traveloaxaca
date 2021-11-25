import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/tour.dart';

class TourBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    refresh();
  }

  Future<List<Tour?>> todosLosTours() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/tour';
    try {
      Uri url = Uri.http(_url, '$_api/todosLosTours');
      /*String bodyParams = json.encode({'idlugar': idLugar});*/
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      Tour tour = Tour.fromJsonToList(responseApi.data);
      return tour.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  onRefresh() {
    notifyListeners();
  }
}

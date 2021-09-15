import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/response_api.dart';

class UsersProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/monarca/lugar';

  Future<ResponseApi?> buscarLugares(String valor) async {
    try {
      Uri url = Uri.http(_url, '$_api/buscarLugaresActivos');
      String bodyParams = json.encode({'valor': valor});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }
}

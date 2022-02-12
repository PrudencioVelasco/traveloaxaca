import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/response_api.dart';

class FeaturedBloc with ChangeNotifier {
  BuildContext? context;
  Function? refresh;
  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    getData();
    refresh();
  }

  List<Lugar> _data = [];
  List<Lugar> get data => _data;

  Future<List<Lugar?>> getData() async {
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/lugar';
    try {
      Uri url = Uri.https(_url, '$_api/sliderPrincipal');
      // String bodyParams = json.encode({'valor': valor});
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);

      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      //return responseApi.data;
      //lista = new List<Lugar>.from(responseApi.data);
      Lugar lug = Lugar.fromJsonToList(responseApi.data);
      _data = lug.toList;
      return _data;
      // return lug.toList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
    //return null;
  }

  onRefresh() {
    // featuredList.clear();
    _data.clear();
    getData();
    notifyListeners();
  }
}

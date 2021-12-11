import 'dart:async';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/helpers/debouncer.dart';
import 'package:traveloaxaca/models/reverse_query_response.dart';

import 'package:traveloaxaca/models/search_response.dart';
import 'package:traveloaxaca/models/traffic_response.dart';

class TrafficService {
  // Singleton
  TrafficService._privateConstructor();
  static final TrafficService _instance = TrafficService._privateConstructor();
  factory TrafficService() {
    return _instance;
  }

  final _dio = new Dio();
  final debouncer = Debouncer<String>(duration: Duration(milliseconds: 400));

  final StreamController<SearchResponse> _sugerenciasStreamController =
      new StreamController<SearchResponse>.broadcast();
  Stream<SearchResponse> get sugerenciasStream =>
      this._sugerenciasStreamController.stream;

  Future<DrivingResponse> getCoordsInicioYDestino(
      LatLng inicio, LatLng destino) async {
    final coordString =
        '${inicio.longitude},${inicio.latitude};${destino.longitude},${destino.latitude}';
    final url = '${Config().baseUrlDir}/mapbox/driving/$coordString';

    final resp = await this._dio.get(url, queryParameters: {
      'alternatives': 'true',
      'geometries': 'polyline6',
      'steps': 'false',
      'access_token': Config().apiKey,
      'language': 'es',
    });

    final data = DrivingResponse.fromJson(resp.data);

    return data;
  }

  Future<DrivingResponse> getCoordsInicioYDestino2(double inicioLatitud,
      double inicioLongitud, double finalLatitud, double finalLongitud) async {
    final coordString =
        '${inicioLongitud},${inicioLatitud};${finalLongitud},${finalLatitud}';
    final url = '${Config().baseUrlDir}/mapbox/driving/$coordString';

    final resp = await this._dio.get(url, queryParameters: {
      'alternatives': 'true',
      'geometries': 'polyline6',
      'steps': 'false',
      'access_token': Config().apiKey,
      'language': 'es',
    });

    final data = DrivingResponse.fromJson(resp.data);

    return data;
  }

  Future<SearchResponse> getResultadosPorQuery(
      String busqueda, LatLng proximidad) async {
    print('Buscando!!!!!');

    final url = '${Config().baseUrlGeo}/mapbox.places/$busqueda.json';

    try {
      final resp = await this._dio.get(url, queryParameters: {
        'access_token': Config().apiKey,
        'autocomplete': 'true',
        'proximity': '${proximidad.longitude},${proximidad.latitude}',
        'language': 'es',
      });

      final searchResponse = searchResponseFromJson(resp.data);

      return searchResponse;
    } catch (e) {
      return SearchResponse(features: []);
    }
  }

  void getSugerenciasPorQuery(String busqueda, LatLng proximidad) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final resultados = await this.getResultadosPorQuery(value, proximidad);
      this._sugerenciasStreamController.add(resultados);
    };

    final timer = Timer.periodic(Duration(milliseconds: 200), (_) {
      debouncer.value = busqueda;
    });

    Future.delayed(Duration(milliseconds: 201)).then((_) => timer.cancel());
  }

  Future<ReverseQueryResponse> getCoordenadasInfo(LatLng destinoCoords) async {
    final url =
        '${Config().baseUrlGeo}/mapbox.places/${destinoCoords.longitude},${destinoCoords.latitude}.json';

    final resp = await this._dio.get(url, queryParameters: {
      'access_token': Config().apiKey,
      'language': 'es',
    });

    final data = reverseQueryResponseFromJson(resp.data);

    return data;
  }
}

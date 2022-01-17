import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/lugar_mapa.dart';
import 'package:traveloaxaca/models/search_response.dart';
import 'package:traveloaxaca/services/traffic_service.dart';
import 'package:flutter_map/flutter_map.dart' as fluttermap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traveloaxaca/config/config.dart';
class MapaDetalleLugarPage extends StatefulWidget {
  final Lugar? placeData;
  MapaDetalleLugarPage({Key? key, required this.placeData}) : super(key: key);

  @override
  _MapaDetalleLugarPageState createState() => _MapaDetalleLugarPageState();
}

class _MapaDetalleLugarPageState extends State<MapaDetalleLugarPage> {
  List<MapaLugarDetalle> _alldata = [];
  PageController _pageController = PageController();

  TrafficService _trafficService = new TrafficService();
  int? prevPage;
  List _markers = [];
  Uint8List? _customMarkerIcon;
  MapaLugarDetalle? detalleCompania;
  int selectIndex = 0;
  bool cargando = true;
  AnimationController? _animationController;
  @override
  void initState() {
    super.initState();
    getData();
    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future getData() async {
    double latitud = widget.placeData!.latitud!;
    double longitud = widget.placeData!.longitud!;
    // SearchResponse responsehotel =
    //     await _trafficService.getResultadosPorQuery('hotel', latitud, longitud);

    SearchResponse responserestaurante = await _trafficService
        .getResultadosPorQuery('restaurant', latitud, longitud);

    /*if (responsehotel.features != null) {
      for (var item in responsehotel.features!) {
        MapaLugarDetalle d = MapaLugarDetalle(
          'hotel',
          item != null
              ? (item.textEs != null)
                  ? item.textEs!
                  : ''
              : '',
          item != null ? item.placeName! : '',
          item!.center![1] ?? 0,
          item.center![0] ?? 0,
          0,
          0,
        );
        _alldata.add(d);
      }
    }*/
    if (responserestaurante.features != null) {
      for (var item in responserestaurante.features!) {
        MapaLugarDetalle d = MapaLugarDetalle(
          'restaurante',
          item != null
              ? (item.textEs != null)
                  ? item.textEs!
                  : ''
              : '',
          item != null ? item.placeName! : '',
          item!.center![1] ?? 0,
          item.center![0] ?? 0,
          0,
          0,
        );
        _alldata.add(d);
      }
    }
    if (mounted) {
      setState(() {
        if (mounted) {
          cargando = false;
        }
      });
    }
  }

  List<fluttermap.Marker> _buildMarkrs() {
    final _marketList = <fluttermap.Marker>[];
    for (int i = 0; i < _alldata.length; i++) {
      _marketList.add(fluttermap.Marker(
        point: latlong.LatLng(_alldata[i].lat, _alldata[i].lng),
        height: Config().marketSizeExpanded,
        width: Config().marketSizeExpanded,
        builder: (_) {
          return GestureDetector(
            onTap: () {
              selectIndex = i;

              /* setState(() {
                _pageController.animateToPage(i,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.elasticOut); 
                print(i);
              });*/
            },
            child: LocationMarket(
              selected: selectIndex == i,
              detalle: _alldata[i],
            ),
          );
        },
      ));
    }
    return _marketList;
  }

  @override
  Widget build(BuildContext context) {
    var brishtness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brishtness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: <Widget>[
          fluttermap.FlutterMap(
            options: fluttermap.MapOptions(
              minZoom: 5,
              maxZoom: 18,
              zoom: 15,
              center: latlong.LatLng(
                  widget.placeData!.latitud!, widget.placeData!.longitud!),
            ),
            nonRotatedLayers: [
              fluttermap.TileLayerOptions(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                additionalOptions: {
                  'accessToken': Config().apiKey,
                  'id': (isDarkMode)
                      ? Config().mapBoxStyleDark
                      : Config().mapBoxStyleLight
                },
              ),
              //  if (_buildMarkrs().length > 0)
              fluttermap.MarkerLayerOptions(
                markers: _buildMarkrs(),
              ),
            ],
          ),
          if (cargando)
            Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}

class LocationMarket extends StatelessWidget {
  const LocationMarket({Key? key, this.selected = false, required this.detalle})
      : super(key: key);
  final bool selected;
  final MapaLugarDetalle detalle;
  @override
  Widget build(BuildContext context) {
    final size =
        (selected) ? Config().marketSizeExpanded : Config().marketSizeShrink;
    return Center(
      child: AnimatedContainer(
        height: size,
        width: size,
        duration: Duration(milliseconds: 400),
        child: (detalle.tipo == 'hotel')
            ? Image.asset('assets/images/hotel_pin.png')
            : Image.asset('assets/images/restaurant_pin.png'),
      ),
    );
  }
}

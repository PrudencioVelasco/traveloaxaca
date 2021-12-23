import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/models/mapabusqueda.dart';
import 'package:traveloaxaca/services/traffic_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart' as fluttermap;
import 'package:latlong2/latlong.dart' as latlong;

const MAPBOX_ACCESS_TOKEN =
    "sk.eyJ1IjoiZHVndWVyIiwiYSI6ImNrd3puampxZTB3am0zMnE5dXp3cXpjcXcifQ.hZUrbDidn2hDJIvMSs3aPQ";
const MAPBOX_STYLE = "mapbox/streets-v11";
const MARKER_cOLOR = Color(0xFF3DC5A7);
final myLocation = LatLng(16.28127274045661, -97.8204067527212);
const MARKET_SIZE_EXPANDED = 55.0;
const MARKET_SIZE_SHRINK = 38.0;
String distancia(int minutos) {
  var d = Duration(minutes: minutos);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}

class MapaPage extends StatefulWidget {
  final int? idclasificacion;
  final String? nombreclasificacion;

  const MapaPage(
      {Key? key,
      required this.idclasificacion,
      required this.nombreclasificacion})
      : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  RutasBloc _rutasBloc = new RutasBloc();
  fluttermap.MapController? _controller;
  List<CompaniaMapa> _alldata = [];
  int? prevPage;
  List<fluttermap.Marker> _marketList = [];
  List<Compania?> _listaCompania = [];
  CompaniaBloc _companiaBloc = new CompaniaBloc();
  final trafficService = new TrafficService();
  double _latitudInicial = 0;
  double _longitudInicial = 0;
  int selectIndex = 0;
  bool presionado = false;
  CompaniaMapa? detalleCompania;
  latlong.LatLng? _center;
  Position? currentLocation;
  bool cargando = true;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController!.repeat();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
    });
    super.initState();
    getUserLocation()
        .then((value) => getData().then((value) => _buildMarkrs()));
    //getData().then((value) => _buildMarkrs());
    refresh();
    //latitudLongitudInicial();
  }

  Future<Position?> locateUser() async {
    final permisoGPS = await Permission.location.isGranted;
    // GPS está activo
    final gpsActivo = await Geolocator.isLocationServiceEnabled();

    if (permisoGPS && gpsActivo) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      return null;
    }
  }

  Future getUserLocation() async {
    currentLocation = await locateUser();
    if (currentLocation != null) {
      setState(() {
        _center = latlong.LatLng(
            currentLocation!.latitude, currentLocation!.longitude);
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<double> obtenerLatitud() async {
    currentLocation = await locateUser();
    return currentLocation!.latitude;
  }

  Future<double> obtenerLongitud() async {
    currentLocation = await locateUser();
    return currentLocation!.longitude;
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  _buildMarkrs() {
    for (var i = 0; i < _alldata.length; i++) {
      setState(() {
        _marketList.add(fluttermap.Marker(
          point: latlong.LatLng(_alldata[i].latitud!, _alldata[i].longitud!),
          height: MARKET_SIZE_EXPANDED,
          width: MARKET_SIZE_EXPANDED,
          builder: (_) {
            return GestureDetector(
              onTap: () {
                selectIndex = i;
                setState(() {
                  detalleCompania = _alldata[i];
                });
              },
              child: LocationMarket(
                selected: selectIndex == i,
              ),
            );
          },
        ));
      });
    }
    // return _marketList;
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future getData() async {
    _listaCompania = await _companiaBloc.getData(widget.idclasificacion!);
    if (_listaCompania.length == 0) {
      openEmptyDialog();
    } else {
      for (var item in _listaCompania) {
        final trafficResponse = await trafficService.getCoordsInicioYDestino2(
            _center!.latitude,
            _center!.longitude,
            item!.latitud!,
            item.longitud!);
        CompaniaMapa d = CompaniaMapa(
          item.idcompania!,
          item.rfc ?? '',
          item.logotipo ?? '',
          item.paginaweb ?? '',
          item.nombre ?? '',
          item.love ?? 0,
          item.comentario ?? 0,
          item.rating ?? 0.0,
          item.primeraimagen ?? '',
          item.actividad ?? '',
          item.direccion ?? '',
          item.latitud ?? 0.0,
          item.longitud ?? 0.0,
          item.correo ?? '',
          item.contacto ?? '',
          (trafficResponse.code == "Ok")
              ? trafficResponse.routes![0]!.geometry
              : "",
          (trafficResponse.code == "Ok")
              ? trafficResponse.routes![0]!.duration
              : 0,
          (trafficResponse.code == "Ok")
              ? trafficResponse.routes![0]!.distance
              : 0,
        );
        _alldata.add(d);
      }
    }
  }

  Future allCompanias() async {
    _listaCompania = await _companiaBloc.getData(widget.idclasificacion!);
  }

  void openEmptyDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("we didn't find any nearby places in this area").tr(),
            title: Text(
              'no places found',
              style: TextStyle(fontWeight: FontWeight.w700),
            ).tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreclasificacion.toString(),
            style: Theme.of(context).textTheme.headline6),
      ),
      body: Stack(
        children: <Widget>[
          (cargando)
              ? Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
              : (!cargando && _center == null)
                  ? Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  : fluttermap.FlutterMap(
                      options: fluttermap.MapOptions(
                        minZoom: 5,
                        maxZoom: 18,
                        zoom: 13,
                        center: _center,
                      ),
                      nonRotatedLayers: [
                        fluttermap.TileLayerOptions(
                          urlTemplate:
                              'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                          additionalOptions: {
                            'accessToken': MAPBOX_ACCESS_TOKEN,
                            'id': MAPBOX_STYLE
                          },
                        ),
                        fluttermap.MarkerLayerOptions(
                          markers: _marketList,
                        ),
                        fluttermap.MarkerLayerOptions(
                          markers: [
                            fluttermap.Marker(
                              width: 60,
                              height: 60,
                              point: latlong.LatLng(
                                  _center!.latitude, _center!.longitude),
                              builder: (_) {
                                return MyLocationMarket(_animationController!);
                              },
                            )
                          ],
                        ),
                      ],
                    ),
          detalleCompania == null
              ? Container()
              : FlotanteCompania(alldata: detalleCompania!),
          Positioned(
              top: 15,
              left: 10,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 8, left: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text("list".tr()),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          onSurface: Colors.black,
                          //shadowColor: Colors.grey,
                          padding: EdgeInsets.all(10.0),
                          elevation: 4,

                          shape: RoundedRectangleBorder(
                              side: BorderSide(),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 8, left: 8),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text("activity".tr()),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          onSurface: Colors.black,
                          //shadowColor: Colors.grey,
                          padding: EdgeInsets.all(10.0),
                          elevation: 4,

                          shape: RoundedRectangleBorder(
                              side: BorderSide(),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 8, left: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          // modalSortBy();
                        },
                        child: Text("sort by".tr()),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          onSurface: Colors.black,
                          //shadowColor: Colors.grey,
                          padding: EdgeInsets.all(10.0),
                          elevation: 4,

                          shape: RoundedRectangleBorder(
                              side: BorderSide(),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }
}

class FlotanteCompania extends StatelessWidget {
  const FlotanteCompania({
    Key? key,
    required CompaniaMapa alldata,
  })  : _alldata = alldata,
        super(key: key);

  final CompaniaMapa _alldata;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        right: 0,
        bottom: 20,
        height: MediaQuery.of(context).size.height * 0.25,
        child: MapItemDetails(companiaMapa: _alldata));
  }
}

class LocationMarket extends StatelessWidget {
  const LocationMarket({Key? key, this.selected = false}) : super(key: key);
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final size = (selected) ? MARKET_SIZE_EXPANDED : MARKET_SIZE_SHRINK;
    return Center(
      child: AnimatedContainer(
        height: size,
        width: size,
        duration: Duration(milliseconds: 400),
        child: Image.asset('assets/images/destination_map_marker.png'),
      ),
    );
  }
}

class MyLocationMarket extends AnimatedWidget {
  const MyLocationMarket(Animation<double> animation, {Key? key})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    final newValue = lerpDouble(0.5, 1.0, value);
    final size = 50;
    return Center(
      child: Stack(
        children: [
          Center(
            child: Container(
              width: size * newValue!,
              height: size * newValue,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MARKER_cOLOR.withOpacity(0.5),
              ),
            ),
          ),
          Center(
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: MARKER_cOLOR,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapItemDetails extends StatelessWidget {
  const MapItemDetails({Key? key, required this.companiaMapa})
      : super(key: key);
  final CompaniaMapa companiaMapa;
  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(color: Colors.grey[700], fontSize: 20);
    return Padding(
      padding: EdgeInsets.all(
        15.0,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                      margin: EdgeInsets.only(
                        right: 10,
                      ),
                      padding: EdgeInsets.all(15),
                      height: MediaQuery.of(context).size.height,
                      width: 110,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 0.5, color: Colors.grey)),
                      child: Image.asset(Config().placeMarkerIcon)),
                  Flexible(
                    child: Wrap(
                      children: [
                        Container(
                          height: 10,
                        ),
                        Text(
                          companiaMapa.nombre.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          companiaMapa.direccion.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54),
                        ),
                        Expanded(
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 20,
                                      width: 90,
                                      child: RatingBar.builder(
                                        // ignoreGestures: true,
                                        itemSize: 20,
                                        initialRating: companiaMapa.rating!,
                                        minRating: companiaMapa.rating!,
                                        maxRating: companiaMapa.rating!,
                                        ignoreGestures: true,
                                        direction: Axis.horizontal,
                                        allowHalfRating: false,
                                        itemCount: 5,
                                        itemPadding: EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {
                                          //_rating = rating;
                                          //print(rating);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Container(
                                    child: Text(
                                      'Duración: ${distancia((companiaMapa.tiempo! / 60).floor())} minutos',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54),
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            MaterialButton(
              padding: EdgeInsets.zero,
              color: MARKER_cOLOR,
              elevation: 6,
              onPressed: () {},
              child: Text("Visitar"),
            )
          ],
        ),
      ),
    );
  }
}
/*import 'package:dio/dio.dart';
Dio dio = new Dio();
Response response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C,-73.9976592&key=YOUR_API_KEY");
print(response.data);*/

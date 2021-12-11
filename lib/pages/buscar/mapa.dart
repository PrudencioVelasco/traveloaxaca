import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/blocs/mi_ubicacion/mi_ubicacion_bloc.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/mapabusqueda.dart';
import 'package:traveloaxaca/services/traffic_service.dart';
import 'package:traveloaxaca/utils/convert_map_icon.dart';
import 'package:easy_localization/easy_localization.dart';

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

class _MapaPageState extends State<MapaPage> {
  RutasBloc _rutasBloc = new RutasBloc();
  GoogleMapController? _controller;
  List<CompaniaMapa> _alldata = [];
  PageController? _pageController;
  int? prevPage;
  List _markers = [];
  Uint8List? _customMarkerIcon;
  List<Lugar?> _lugares = [];
  List<Compania?> _listaCompania = [];
  CompaniaBloc _companiaBloc = new CompaniaBloc();
  MiUbicacionBloc _miUbicacionBloc = new MiUbicacionBloc();
  Completer<GoogleMapController> _controllerPunto = Completer();
  final trafficService = new TrafficService();
  Position? _currentPosition;
  double _latitudInicial = 0;
  double _longitudInicial = 0;
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
    });
    super.initState();
    _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
      ..addListener(_onScroll);
    setMarkerIcon();
    getData().then((value) {
      animateCameraAfterInitialization();
      _addMarker();
    });
    latitudLongitudInicial();
  }

  latitudLongitudInicial() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (!position.latitude.isNaN && !position.longitude.isNaN) {
      setState(() {
        _latitudInicial = position.latitude;
        _longitudInicial = position.longitude;
      });
    }
  }

  Uint8List? _sourceIcon;
  Uint8List? _destinationIcon;
  setMarkerIcon() async {
    _customMarkerIcon = await getBytesFromAsset(Config().hotelPinIcon, 100);
  }

  _setMarkerIcons() async {
    _sourceIcon = await getBytesFromAsset(Config().drivingMarkerIcon, 110);
    _destinationIcon =
        await getBytesFromAsset(Config().destinationMarkerIcon, 110);
  }

  _addMarker() {
    for (var data in _alldata) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId(data.nombre!),
            position: LatLng(data.latitud!, data.longitud!),
            //infoWindow: InfoWindow(title: data.nombre, snippet: data.direccion),
            icon: BitmapDescriptor.defaultMarker,
            onTap: () {
              _onCardTapIcono(data);
            }));
      });
    }
  }

  void _onScroll() {
    if (_pageController!.page!.toInt() != prevPage) {
      prevPage = _pageController!.page!.toInt();
      moveCamera();
    }
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future getData() async {
    // final inicio = _miUbicacionBloc.state.ubicacion;
    /*var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final trafficResponse = await trafficService.getCoordsInicioYDestino2(
        position.latitude, position.longitude, 15.667251, -96.4921985);
    final geometry = trafficResponse.routes![0]!.geometry;
    final duracion = trafficResponse.routes![0]!.duration;
    final distancia = trafficResponse.routes![0]!.distance;*/

    _listaCompania = await _companiaBloc.getData(widget.idclasificacion!);
    if (_listaCompania.length == 0) {
      openEmptyDialog();
    } else {
      for (var item in _listaCompania) {
        final trafficResponse = await trafficService.getCoordsInicioYDestino2(
            _latitudInicial, _longitudInicial, item!.latitud!, item.longitud!);
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
            content: Text("we didn't find any nearby hotels in this area").tr(),
            title: Text(
              'no hotels found',
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

  _hotelList(index) {
    return AnimatedBuilder(
        animation: _pageController!,
        builder: (BuildContext context, Widget? widget) {
          double value = 1;
          if (_pageController!.position.haveDimensions) {
            value = (_pageController!.page! - index);
            value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
          }
          return Center(
            child: SizedBox(
              height: Curves.easeInOut.transform(value) * 140.0,
              width: Curves.easeInOut.transform(value) * 350.0,
              child: widget,
            ),
          );
        },
        child: InkWell(
          onTap: () {
            _onCardTap(index);
          },
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.grey, blurRadius: 5)
                ]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        '${_alldata[index].nombre}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _alldata[index].direccion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 20,
                            width: 100,
                            child: RatingBar.builder(
                              // ignoreGestures: true,
                              itemSize: 18,
                              initialRating: _alldata[index].rating!,
                              ignoreGestures: true,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 0.0),
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
                          SizedBox(
                            width: 2,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                              '${(_alldata[index].tiempo! / 60).floor()} minutos',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _onCardTapIcono(CompaniaMapa row) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 500,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 15, top: 10, right: 5),
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.orangeAccent,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              '${row.nombre}',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: Colors.orangeAccent,
                              size: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                row.direccion!,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.book,
                                  color: Colors.orangeAccent,
                                  size: 25,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  row.actividad!,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  maxLines: 8,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                ),
                              )
                            ]),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.timer,
                              color: Colors.orangeAccent,
                              size: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                                    '${(row.tiempo! / 60).floor()} minutos',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54))),
                          ],
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    alignment: Alignment.bottomRight,
                    height: 50,
                    child: TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  _onCardTap(index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 500,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 15, top: 10, right: 5),
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.orangeAccent,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Image(
                            image: AssetImage(Config().hotelIcon),
                            height: 120,
                            width: 120,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              '${_alldata[index].nombre}',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: Colors.orangeAccent,
                              size: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                _alldata[index].direccion!,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.book,
                                  color: Colors.orangeAccent,
                                  size: 25,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  _alldata[index].actividad!,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  maxLines: 8,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                ),
                              )
                            ]),
                        Divider(),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    alignment: Alignment.bottomRight,
                    height: 50,
                    child: TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nombreclasificacion.toString(),
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                compassEnabled: false,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: Config().initialCameraPosition,
                markers: Set.from(_markers),
                onMapCreated: mapCreated,
              ),
            ),
            _alldata.isEmpty
                ? Container()
                : Positioned(
                    bottom: 10.0,
                    child: Container(
                      height: 200.0,
                      width: MediaQuery.of(context).size.width,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _alldata.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _hotelList(index);
                        },
                      ),
                    ),
                  ),
            Positioned(
                top: 15,
                left: 10,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        // width: MediaQuery.of(context).size.width * 0.80,
                        child: ToggleSwitch(
                          minWidth: 90.0,
                          initialLabelIndex: 1,
                          cornerRadius: 20.0,
                          activeFgColor: Colors.white,
                          inactiveBgColor: Colors.grey,
                          inactiveFgColor: Colors.white,
                          totalSwitches: 2,
                          labels: ['list', 'map'],
                          icons: [FontAwesomeIcons.list, FontAwesomeIcons.map],
                          activeBgColors: [
                            [Colors.blue],
                            [Colors.pink]
                          ],
                          onToggle: (index) {
                            print('switched to: $index');
                            if (index == 0) {
                              Navigator.pop(context, true);
                              //nextScreen(context, MapaPage(idclasificacion: widget.idclasificacion, nombreclasificacion: widget.nombreclasificacion));
                            }
                            setState(() {});
                          },
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
            _alldata.isEmpty
                ? Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  void animateCameraAfterInitialization() async {
    final GoogleMapController control = await _controllerPunto.future;
    control.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(_latitudInicial, _longitudInicial),
      zoom: 13,
    )));
  }

  moveCamera() {
    _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_alldata[_pageController!.page!.toInt()].latitud!,
            _alldata[_pageController!.page!.toInt()].longitud!),
        zoom: 15,
        bearing: 90.0,
        tilt: 45.0)));
  }
}
/*import 'package:dio/dio.dart';
Dio dio = new Dio();
Response response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C,-73.9976592&key=YOUR_API_KEY");
print(response.data);*/
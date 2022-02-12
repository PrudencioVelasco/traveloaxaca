import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/models/mapabusqueda.dart';
import 'package:traveloaxaca/pages/compania/detalle_compania.dart';
import 'package:traveloaxaca/services/traffic_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart' as fluttermap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:traveloaxaca/utils/next_screen.dart';

class MapaPage extends StatefulWidget {
  final int? idclasificacion;
  final String? nombreclasificacion;
  final List<Compania?> companias;

  const MapaPage(
      {Key? key,
      required this.idclasificacion,
      required this.nombreclasificacion,
      required this.companias})
      : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  RutasBloc _rutasBloc = new RutasBloc();
  fluttermap.MapController? _controller;
  List<CompaniaMapa?> _alldata = [];
  List<CompaniaMapa?> _listaDataOriginal = [];
  List<CompaniaMapa?> _listaDataPrincipal = [];
  bool filtrando = false;
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
  PageController _pageController = PageController();
  String? _sortValue;
  String? _ascValue;
  List<Map> _listaRating = [
    {"id": 1, "nombre": "1 start".tr()},
    {"id": 2, "nombre": "2 start".tr()},
    {"id": 3, "nombre": "3 start".tr()},
    {"id": 4, "nombre": "4 start".tr()},
    {"id": 5, "nombre": "5 start".tr()},
  ];
  List<Map> _listaComLove = [
    {"id": 1, "nombre": "more comments".tr()},
    // {"id": 2, "nombre": "more loves".tr()},
  ];
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController!.repeat();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
    });
    super.initState();
    getUserLocation().then((value) => getData());
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
      if (mounted) {
        setState(() {
          _center = latlong.LatLng(
              currentLocation!.latitude, currentLocation!.longitude);
          cargando = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
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

  List<fluttermap.Marker> _buildMarkrs() {
    final _marketList = <fluttermap.Marker>[];
    for (var i = 0; i < _alldata.length; i++) {
      _marketList.add(fluttermap.Marker(
        point: latlong.LatLng(_alldata[i]!.latitud!, _alldata[i]!.longitud!),
        height: Config().marketSizeExpanded,
        width: Config().marketSizeExpanded,
        builder: (_) {
          return GestureDetector(
            onTap: () {
              selectIndex = i;

              setState(() {
                _pageController.animateToPage(i,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.elasticOut);
                // _pageController.jumpToPage(i);
                print(i);
              });
            },
            child: LocationMarket(
              selected: selectIndex == i,
            ),
          );
        },
      ));
    }
    return _marketList;
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future getData() async {
    //_listaCompania = await _companiaBloc.getData(widget.idclasificacion!);
    if (widget.companias.length == 0 && widget.companias != []) {
      openEmptyDialog();
    } else {
      for (var item in widget.companias) {
        CompaniaMapa d = CompaniaMapa(
            item!.idcompania!,
            item.rfc ?? '',
            item.logotipo ?? '',
            item.paginaweb ?? '',
            item.nombre ?? '',
            item.love ?? 0,
            item.comentario ?? 0,
            item.rating ?? 0.0,
            item.primeraimagen ?? null,
            item.actividad ?? '',
            item.direccion ?? '',
            item.latitud ?? 0.0,
            item.longitud ?? 0.0,
            item.correo ?? '',
            item.contacto ?? '',
            '',
            0.0,
            item.duracion);
        _alldata.add(d);
        _alldata.sort((a, b) => a!.duracion!.compareTo(b!.duracion!));
      }
    }
    setState(() {
      _listaDataOriginal = _alldata;
      _listaDataPrincipal = _alldata;
      cargando = false;
    });
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
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var brishtness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brishtness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.nombreclasificacion.toString() +
                " " +
                "nearby".tr().toUpperCase(),
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
                            'accessToken': Config().apiKey,
                            'id': (isDarkMode)
                                ? Config().mapBoxStyleDark
                                : Config().mapBoxStyleLight
                          },
                        ),
                        if (_buildMarkrs().length > 0)
                          fluttermap.MarkerLayerOptions(
                            markers: _buildMarkrs(),
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            height: MediaQuery.of(context).size.height * 0.25,
            child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              itemCount: _alldata.length,
              itemBuilder: (BuildContext context, index) {
                final item = _alldata[index];
                return MapItemDetails(
                  companiaMapa: item!,
                  context: context,
                );
              },
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
                        onPressed: () {
                          modalSortBy(context);
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
          if (cargando)
            Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }

  Future<void> modalSortBy(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              margin: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        margin: EdgeInsets.only(top: 5, bottom: 5),
                        height: 5,
                        width: 150,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(40)),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 12, right: 10),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.sort,
                              // color: Color(0xff808080),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text("rate").tr(),
                                isDense: true,
                                items: _listaRating.map((Map value) {
                                  return DropdownMenuItem(
                                    value: value["id"].toString(),
                                    child: Text(
                                      value["nombre"].toString(),
                                    ),
                                  );
                                }).toList(),
                                value: _sortValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    _sortValue = newValue;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 8, right: 10),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.sort_by_alpha,
                              //  color: Color(0xff808080),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text("reactions").tr(),
                                items: _listaComLove.map((Map value) {
                                  return DropdownMenuItem(
                                    value: value["id"].toString(),
                                    child: Text(value["nombre"].toString(),
                                        style: TextStyle(fontSize: 16)),
                                  );
                                }).toList(),
                                value: _ascValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    _ascValue = newValue;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              child: Text("clean").tr(),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                onSurface: Colors.black,
                                //shadowColor: Colors.grey,
                                padding: EdgeInsets.all(10.0),
                                elevation: 2,

                                shape: RoundedRectangleBorder(
                                    side: BorderSide(),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onPressed: () {
                                Navigator.pop(context, true);
                                btnCancelar();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              child: Text("filter").tr(),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                onSurface: Colors.black,
                                //shadowColor: Colors.grey,
                                padding: EdgeInsets.all(10.0),
                                elevation: 2,

                                shape: RoundedRectangleBorder(
                                    side: BorderSide(),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onPressed: () {
                                btnBuscar();
                                Navigator.pop(context, true);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void btnCancelar() async {
    _alldata = [];
    setState(() {
      _ascValue = null;
      _sortValue = null;
      filtrando = false;
      _alldata = _listaDataPrincipal;
    });
  }

  void btnBuscar() {
    List<CompaniaMapa?> filteredStrings = [];
    _alldata = [];
    int opcion = 0;
    if (_sortValue != null) {
      opcion = 0;
      filteredStrings = _listaDataOriginal
          .where((item) =>
              item!.rating == int.parse(_sortValue.toString()).toDouble())
          .toList();
    }
    if (_ascValue != null) {
      if (_ascValue!.toString() == "1") {
        if (_sortValue != null) {
          opcion = 0;
          filteredStrings.sort((a, b) =>
              a!.comentario!.toInt().compareTo(b!.comentario!.toInt()));
        } else {
          opcion = 1;
          _listaDataOriginal.sort((a, b) =>
              a!.comentario!.toInt().compareTo(b!.comentario!.toInt()));
        }
      }
    }
    setState(() {
      filtrando = true;
      _alldata = (opcion == 1) ? _listaDataOriginal : filteredStrings;
      if (_alldata.length == 0) {
        // resultadointerno = false;
        // cargando = false;
        openEmptyDialog();
      }
    });
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
        child: MapItemDetails(
          companiaMapa: _alldata,
          context: context,
        ));
  }
}

class LocationMarket extends StatelessWidget {
  const LocationMarket({Key? key, this.selected = false}) : super(key: key);
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final size =
        (selected) ? Config().marketSizeExpanded : Config().marketSizeShrink;
    return Center(
      child: AnimatedContainer(
        height: size,
        width: size,
        duration: Duration(milliseconds: 400),
        child: (selected)
            ? Image.asset('assets/images/pin_activo.png')
            : Image.asset('assets/images/pin_noactivo.png'),
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
                color: Config().marketColor.withOpacity(0.5),
              ),
            ),
          ),
          Center(
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: Config().marketColor,
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
  MapItemDetails({Key? key, required this.companiaMapa, required this.context})
      : super(key: key);

  final CompaniaMapa companiaMapa;
  final BuildContext context;
  final _lugarCompaniaBloc = new CompaniaBloc();
  Future siguiente(int idcompania) async {
    Compania? detalle = await _lugarCompaniaBloc.detalleCompania(idcompania);
    if (detalle != null) {
      nextScreen(context, DetalleCompaniaPage(compania: detalle));
    }
  }

  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(color: Colors.grey[700], fontSize: 20);
    return Padding(
      padding: EdgeInsets.all(
        15.0,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        // color: Colors.white,
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
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    companiaMapa.nombre.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    companiaMapa.direccion.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      //color: Colors.black54
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingBar.builder(
                                  // ignoreGestures: true,
                                  itemSize: 20,
                                  initialRating: companiaMapa.rating!,
                                  minRating: companiaMapa.rating!,
                                  maxRating: companiaMapa.rating!,
                                  ignoreGestures: true,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  //  itemPadding: EdgeInsets.symmetric(
                                  //     horizontal: 4.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star_border_outlined,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    //_rating = rating;
                                    //print(rating);
                                  },
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  FontAwesomeIcons.solidHeart,
                                  color: Colors.red,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "(" + companiaMapa.love.toString() + ")",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  FontAwesomeIcons.comments,
                                  color: Colors.blueAccent,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "(" +
                                      companiaMapa.comentario.toString() +
                                      ")",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.drive_eta_outlined),
                                Expanded(
                                    child: Container(
                                  child: Text(
                                    '${Config().distancia((companiaMapa.duracion! / 60).floor())}' +
                                        " " +
                                        'minutes'.tr(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: MaterialButton(
                padding: EdgeInsets.zero,
                color: Config().marketColor,
                elevation: 6,
                onPressed: () async {
                  siguiente(companiaMapa.idcompania!);
                },
                child: Text("visit".tr()),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:translator/translator.dart';
import 'package:traveloaxaca/blocs/actividad_bloc.dart';
import 'dart:async';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/models/actividad.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/lugarmapa.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/services/traffic_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart' as fluttermap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:traveloaxaca/utils/next_screen.dart';
/*String distancia(int minutos) {
  var d = Duration(minutes: minutos);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}*/

class MapaCercanoPage extends StatefulWidget {
  final int? idclasificacion;
  final String? nombreclasificacion;
  final List<Lugar?> lugares;
  MapaCercanoPage(
      {Key? key,
      required this.idclasificacion,
      required this.nombreclasificacion,
      required this.lugares})
      : super(key: key);

  @override
  _MapaCercanoPageState createState() => _MapaCercanoPageState();
}

class _MapaCercanoPageState extends State<MapaCercanoPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  fluttermap.MapController? _controller;
  PageController _pageController = PageController();
  List<LugarMapa> _alldata = [];
  List<LugarMapa> _alldataOriginal = [];
  List<LugarMapa> _listaLugarSegundo = [];
  int? prevPage;
  List<Actividad?> _listActividad = [];
  List<Lugar?> _listaLugar = [];
  LugarBloc _lugarBloc = new LugarBloc();
  final trafficService = new TrafficService();
  double _latitudInicial = 0;
  double _longitudInicial = 0;
  int selectIndex = 0;
  int _selectedIndex = 0;
  bool presionado = false;
  LugarMapa? detalleCompania;
  latlong.LatLng? _center;
  Position? currentLocation;
  bool cargando = true;
  bool ubicado = false;
  String? _sortValue;
  String? _ascValue;
  List<String?> _filters = [];
  ActividadBloc _actividadBloc = new ActividadBloc();
  List<Map> _listaRating = [
    {"id": 1, "nombre": "1 start".tr()},
    {"id": 2, "nombre": "2 start".tr()},
    {"id": 3, "nombre": "3 start".tr()},
    {"id": 4, "nombre": "4 start".tr()},
    {"id": 5, "nombre": "5 start".tr()},
  ];
  List<Map> _listaComLove = [
    {"id": 1, "nombre": "more comments".tr()},
    {"id": 2, "nombre": "more loves".tr()},
  ];
  final translator = GoogleTranslator();
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
    allActividades2();
  }

  Future allActividades2() async {
    _listActividad = await _actividadBloc.obtenerActividades();
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
        ubicado = true;
      });
    } else {
      setState(() {
        ubicado = false;
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

  List<fluttermap.Marker> _buildMarkrs() {
    final _marketList = <fluttermap.Marker>[];
    for (int i = 0; i < _alldata.length; i++) {
      // setState(() {
      final mapItem = _alldata[i];
      _marketList.add(fluttermap.Marker(
        point: latlong.LatLng(_alldata[i].latitud!, _alldata[i].longitud!),
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
      // });
    }

    return _marketList;
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future getData() async {
    if (widget.lugares.length == 0 && widget.lugares != []) {
      openEmptyDialog();
    } else {
      for (var item in widget.lugares) {
        if (item!.latitud != 0 && item.longitud != 0) {
          LugarMapa d = LugarMapa(
            item.idlugar!,
            item.nombre ?? '',
            item.direccion ?? '',
            item.latitud ?? 0.0,
            item.longitud ?? 0.0,
            item.descripcion ?? '',
            item.historia ?? '',
            item.resena ?? '',
            item.love ?? 0,
            item.comentario ?? 0,
            item.rating ?? 0.0,
            item.primeraimagen ?? null,
            item.nombreclasificacion ?? '',
            item.actividades ?? [],
            item.principal ?? 0,
            item.numero ?? 0,
            '',
            0.0,
            item.duracion,
          );
          _alldata.add(d);
          _alldata.sort((a, b) => a.duracion!.compareTo(b.duracion!));
        }
      }
    }
    setState(() {
      cargando = false;
      _alldataOriginal = _alldata;
    });
  }

  Future allCompanias() async {
    _listaLugar = await _lugarBloc.obtenerTodosLugares();
  }

  void btnCancelar() async {
    setState(() {
      _selectedIndex = 0;
      _ascValue = null;
      _sortValue = null;
      _alldata = _alldataOriginal;
      //resultadointerno = true;
    });
  }

  btnBuscar() {
    List<LugarMapa> filteredStrings = [];
    //_listaLugarSegundo = [];
    //List<Lugar?> _listaLugarOriginal = [];
    int opcion = 0;
    if (_sortValue != null && _ascValue != null && _selectedIndex == 0) {
      opcion = 1;
      _listaLugarSegundo = [];
      _listaLugarSegundo = _alldataOriginal;
    }
    if (_selectedIndex != 0) {
      opcion = 0;
      filteredStrings = _alldataOriginal
          .where((element) => element.actividades!
              .any((res) => res!.idactividad == _selectedIndex))
          .toList();
    }
    if (_sortValue != null) {
      opcion = 0;
      filteredStrings = _alldataOriginal
          .where((item) =>
              item.rating == int.parse(_sortValue.toString()).toDouble())
          .toList();
    }
    if (_ascValue != null) {
      if (_ascValue!.toString() == "1") {
        if (_sortValue != null) {
          opcion = 0;
          filteredStrings
              .sort((a, b) => a.love!.toInt().compareTo(b.love!.toInt()));
        } else {
          opcion = 1;
          _alldataOriginal
              .sort((a, b) => a.love!.toInt().compareTo(b.love!.toInt()));
        }
      }
      if (_ascValue!.toString() == "2") {
        if (_sortValue != null) {
          opcion = 0;
          filteredStrings.sort(
              (a, b) => a.comentario!.toInt().compareTo(b.comentario!.toInt()));
        } else {
          opcion = 1;
          _alldataOriginal.sort(
              (a, b) => a.comentario!.toInt().compareTo(b.comentario!.toInt()));
        }
      }
    }
    setState(() {
      _alldata = (opcion == 1) ? _alldataOriginal : filteredStrings;
      if (_alldata.length == 0) {
        // resultadointerno = false;
        // cargando = false;
        openEmptyDialog();
      }
    });
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
                    // Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<String> someFutureStringFunction(
      BuildContext context, String texto) async {
    Locale myLocale = Localizations.localeOf(context);
    if (myLocale.languageCode == "en") {
      var translation = await translator.translate(texto, from: 'es', to: 'en');
      return translation.toString();
    } else {
      return texto.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final _listMarkes = _buildMarkrs();
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
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            //if (!cargando)

            if (widget.lugares != [])
              fluttermap.FlutterMap(
                options: fluttermap.MapOptions(
                  minZoom: 5,
                  maxZoom: 18,
                  zoom: 8,
                  center: latlong.LatLng(widget.lugares.first!.latitud!,
                      widget.lugares.first!.longitud!),
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
                  if (_center != null)
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
                    companiaMapa: item,
                    context: context,
                  );
                },
              ),
            ),
            detalleCompania == null ? Container() : Container(),
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
                            modalActivity(context);
                          },
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
                            modalSortBy();
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
      ),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  modalSortBy() {
    showModalBottomSheet(
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

  modalActivity(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  height: 5,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(40)),
                ),
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: Container(
                    // color: Colors.green,
                    // height: MediaQuery.of(context).size.height * 0.42,
                    padding: new EdgeInsets.only(bottom: 10),
                    child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: [
                          Container(
                              child: getFilterChipsWidgets(setState, context)),
                        ]),
                  ),
                ),
                SafeArea(
                  child: Container(
                    height: 65,
                    padding: EdgeInsets.only(
                        top: 8, bottom: 10, right: 20, left: 20),
                    margin: EdgeInsets.only(bottom: 20),
                    width: double.infinity,
                    child: Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
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
                  ),
                )
              ],
            );
          });
        });
  }

  Widget getFilterChipsWidgets(StateSetter setState, BuildContext context) {
    List<Widget> tags_list = [];
    for (var i = 0; i < _listActividad.length; i++) {
      FilterChip item = new FilterChip(
        label: FutureBuilder(
            future: someFutureStringFunction(
                context, _listActividad[i]!.nombreactividad!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data.toString(),
                );
              } else if (snapshot.hasError) {
                return Text("error");
              }
              return Text("loading...".tr());
            }),
        selected: _selectedIndex == _listActividad[i]!.idtipoactividad,
        onSelected: (bool value) {
          setState(() {
            if (value) {
              _selectedIndex = _listActividad[i]!.idtipoactividad!;
            }
          });
        },
        pressElevation: 15,
        selectedColor: Colors.grey[400],
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide()),
      );
      tags_list.add(
        Container(
          margin: EdgeInsets.all(2),
          child: item,
        ),
      );
    }
    return Wrap(children: tags_list);
  }

  Widget _conQuienVisito(Actividad? item) {
    return StatefulBuilder(
      builder: (context, setStateChild) {
        return InkWell(
          child: Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 0),
            child: ChoiceChip(
              elevation: 5,
              pressElevation: 5,
              label: Text(item!.nombreactividad!),
              selected: _selectedIndex == item.idtipoactividad,
              selectedColor: Colors.red,
              padding: EdgeInsets.all(10),
              labelStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              backgroundColor: Colors.grey[500],
              onSelected: (bool selected) {
                setStateChild(() {
                  if (selected) {
                    _selectedIndex = item.idtipoactividad!;
                    print(_selectedIndex);
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildChoiceChips() {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      child: ListView.builder(
        itemCount: _listActividad.length,
        itemBuilder: (BuildContext context, int index) {
          return FilterChip(
            backgroundColor: Colors.tealAccent[200],
            avatar: CircleAvatar(
              backgroundColor: Colors.cyan,
              child: Text(
                _listActividad[index]!.nombreactividad!.toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            label: Text(
              _listActividad[index]!.nombreactividad!,
            ),
            selected: _filters.contains(_listActividad[index]!.idtipoactividad),
            selectedColor: Colors.purpleAccent,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _filters
                      .add(_listActividad[index]!.idtipoactividad.toString());
                } else {
                  _filters.removeWhere((name) {
                    return name ==
                        _listActividad[index]!.idtipoactividad.toString();
                  });
                }
              });
            },
          );
        },
      ),
    );
  }
}

class FlotanteCompania extends StatelessWidget {
  const FlotanteCompania({
    Key? key,
    required LugarMapa alldata,
  })  : _alldata = alldata,
        super(key: key);

  final LugarMapa _alldata;

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
  final LugarMapa companiaMapa;
  final BuildContext context;
  final _lugarBloc = new LugarBloc();
  Future siguiente(int idlugar) async {
    Lugar? detalle = await _lugarBloc.obtenerDetalleLugar(idlugar);
    if (detalle != null) {
      nextScreen(context,
          PlaceDetails(data: detalle, tag: 'popular${detalle.idlugar}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(color: Colors.grey[700], fontSize: 20);
    return Container(
      padding: EdgeInsets.all(10),
      child: Card(
        margin: EdgeInsets.zero,
        //color: Colors.white,
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
                          borderRadius: BorderRadius.circular(
                            5,
                          ),
                          border: Border.all(
                            width: 0.5,
                          )),
                      child: Image.asset(Config().placeMarkerIcon)),
                  Flexible(
                    child: Wrap(
                      children: [
                        Container(
                          height: 10,
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    companiaMapa.nombre.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              ],
                            )
                          ],
                        )),
                        Expanded(
                            child: Column(
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
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        )),
                        Expanded(
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RatingBar.builder(
                                    // ignoreGestures: true,
                                    itemSize: 22,
                                    initialRating: companiaMapa.rating!,
                                    minRating: companiaMapa.rating!,
                                    maxRating: companiaMapa.rating!,
                                    ignoreGestures: true,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    //itemPadding: EdgeInsets.symmetric(
                                    //    horizontal: 4.0),
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
                        ),
                        Expanded(
                          child: Column(
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
                          ),
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
                  siguiente(companiaMapa.idlugar!);
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

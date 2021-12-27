import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:translator/translator.dart';
import 'package:traveloaxaca/blocs/actividad_bloc.dart';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:traveloaxaca/models/actividad.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/buscar/mapa_cercano.dart';
import 'package:traveloaxaca/services/traffic_service.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/list_card.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;

class MiUbicacionLugarPage extends StatefulWidget {
  final int? idclasificacion;
  final String? nombreclasificacion;
  MiUbicacionLugarPage(
      {Key? key,
      required this.idclasificacion,
      required this.nombreclasificacion})
      : super(key: key);

  @override
  _MiUbicacionLugarPageState createState() => _MiUbicacionLugarPageState();
}

class _MiUbicacionLugarPageState extends State<MiUbicacionLugarPage> {
  String? _sortValue;
  String? _ascValue;
  bool cargando = true;
  bool sinresultado = false;
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
  List<Lugar?> _listaLugar = [];
  List<Lugar?> _listaLugarSegundo = [];
  List<Actividad?> _listActividad = [];
  List<MultiSelectItem<Actividad>> _items = [];
  LugarBloc _lugarBloc = new LugarBloc();
  ActividadBloc _actividadBloc = new ActividadBloc();
  List<String> selectedReportList = [];
  List<Actividad?> _selectedAnimals2 = [];
  List<Actividad?> _listaActividad = [];
  List<String?> _filters = [];
  List _myActivities = [];
  bool mapa = false;
  bool? _isSelected;
  final translator = GoogleTranslator();
  int _choiceIndex = 0;
  int _selectedIndex = 0;
  final _multiSelectKey = GlobalKey<FormFieldState>();
  latlong.LatLng? _center;
  Position? currentLocation;
  bool ubicado = false;
  final trafficService = new TrafficService();
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _lugarBloc.init(context, refresh);
      _actividadBloc.init(context, refresh);
    });
    //  allLugares();
    allActividades();
    allActividades2();
    refresh();
    getUserLocation().then((value) => allLugares());
  }

  Future allActividades2() async {
    _listActividad = await _actividadBloc.obtenerActividades();
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

  Future allActividades() async {
    List<Actividad?> data = await _actividadBloc.obtenerActividades();
    final _items1 = data
        .map((animal) =>
            MultiSelectItem<Actividad>(animal!, animal.nombreactividad!))
        .toList();
    setState(() {
      _items = _items1;
      // _listaActividad = data;
    });
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future allLugares() async {
    _listaLugar = await _lugarBloc.obtenerTodosLugares();
    if (_listaLugar.length > 0) {
      for (var item in _listaLugar) {
        if (item!.latitud != 0 && item.longitud != 0) {
          final trafficResponse = await trafficService.getCoordsInicioYDestino2(
              _center!.latitude,
              _center!.longitude,
              item.latitud!,
              item.longitud!);
          double? valor = (trafficResponse.code == "Ok")
              ? trafficResponse.routes![0]!.duration
              : 0.0;
          if (valor != null && valor < 10800) {
            _listaLugarSegundo.add(Lugar(
              idlugar: item.idlugar!,
              nombre: item.nombre ?? '',
              direccion: item.direccion ?? '',
              latitud: item.latitud ?? 0.0,
              longitud: item.longitud ?? 0.0,
              descripcion: item.descripcion ?? '',
              historia: item.historia ?? '',
              resena: item.resena ?? '',
              love: item.love ?? 0,
              comentario: item.comentario ?? 0,
              rating: item.rating ?? 0.0,
              primeraimagen: item.primeraimagen ?? null,
              nombreclasificacion: item.nombreclasificacion ?? '',
              actividades: item.actividades ?? [],
              principal: item.principal ?? 0,
              numero: item.numero ?? 0,
              duracion: (trafficResponse.code == "Ok")
                  ? trafficResponse.routes![0]!.duration
                  : 0.0,
            ));
            _listaLugarSegundo
                .sort((a, b) => a!.duracion!.compareTo(b!.duracion!));
          }
        }
      }
      if (mounted) {
        setState(() {
          cargando = false;
          sinresultado = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          cargando = false;
          sinresultado = true;
        });
      }
    }
  }

  Future<List<Lugar?>> obtenerLugares() async {
    return await _lugarBloc.obtenerTodosLugares();
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
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            title: FutureBuilder(
                future: someFutureStringFunction(
                    context, widget.nombreclasificacion!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data.toString().toUpperCase() +
                          " " +
                          "nearby".tr().toUpperCase(),
                      style: Theme.of(context).textTheme.headline6,
                    );
                  } else if (snapshot.hasError) {
                    return Text("error");
                  }
                  return Text("loading...".tr());
                }),
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
          ),
        ];
      },
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 8, left: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            nextScreen(
                                context,
                                MapaCercanoPage(
                                  idclasificacion: widget.idclasificacion,
                                  nombreclasificacion:
                                      widget.nombreclasificacion,
                                  lugares: _listaLugarSegundo,
                                ));
                          },
                          child: Text("map".tr()),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.black,
                            //onSurface: Colors.red,
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
                    ]),
                  ),
                ),
              ],
            ),
            Expanded(
                child: (cargando)
                    ? ListView.separated(
                        padding: EdgeInsets.all(15),
                        itemCount: 5,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(
                          height: 10,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return LoadingCard(height: 120);
                        },
                      )
                    : (sinresultado)
                        ? EmptyPage(
                            icon: FeatherIcons.clipboard,
                            message: 'no places found'.tr(),
                            message1: "try again".tr(),
                          )
                        : ListView.separated(
                            // padding: EdgeInsets.all(10),
                            itemCount: _listaLugarSegundo.length,
                            separatorBuilder: (context, index) => SizedBox(
                              height: 5,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return ListCardNearby(
                                d: _listaLugarSegundo[index],
                                tag: "search$index",
                                color: Colors.white,
                                tipo: "miubicacion",
                              );
                            },
                          )),
          ],
        ),
      ),
    ));
  }

  modalSortBy() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
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
                              //btnCancelar();
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
                              //btnBuscar();
                              //Navigator.pop(context, true);
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
                Container(
                  // color: Colors.green,
                  height: MediaQuery.of(context).size.height * 0.42,
                  padding: new EdgeInsets.only(bottom: 10),
                  child: ListView(scrollDirection: Axis.vertical, children: [
                    Container(
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              child: getFilterChipsWidgets(setState, context)),
                        ],
                      ),
                    ),
                  ]),
                ),
                Container(
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
                            //btnCancelar();
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
                            //btnBuscar();
                            //Navigator.pop(context, true);
                          },
                        ),
                      )
                    ],
                  ),
                ),
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

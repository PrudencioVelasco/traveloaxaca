import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:latlong2/latlong.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/full_mapa_lugares_cercanos.dart';
import 'package:easy_localization/easy_localization.dart';

class MapaLugaresCercanosPage extends StatefulWidget {
  MapaLugaresCercanosPage({Key? key}) : super(key: key);

  @override
  _MapaLugaresCercanosPageState createState() =>
      _MapaLugaresCercanosPageState();
}

class _MapaLugaresCercanosPageState extends State<MapaLugaresCercanosPage>
    with SingleTickerProviderStateMixin {
  LatLng? _center;
  Position? currentLocation;
  bool cargando = true;
  bool ubicado = false;
  bool sinresultado = false;
  List<Lugar?> _listaLugar = [];
  List<Lugar?> _listaLugarSegundo = [];
  LugarBloc _lugarBloc = new LugarBloc();
  int selectIndex = 0;
  PageController _pageController = PageController();
  AnimationController? _animationController;
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController!.repeat();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _lugarBloc.init(context, refresh);
    });
    checkGpsYLocation();
    getUserLocation().then((value) => getData());
  }

  Future checkGpsYLocation() async {
    // PermisoGPS
    final permisoGPS = await Permission.location.isGranted;
    // GPS está activo
    final gpsActivo = await Geolocator.isLocationServiceEnabled();

    if (permisoGPS && gpsActivo) {
      // return '';
      print("su");
    } else if (!permisoGPS) {
      //return 'Es necesario el permiso de GPS';
      mostrarAlertaGPS(context, "GPS", "Es necesario el permiso de GPS");
      print('Es necesario el permiso de GPS');
    } else {
      print('Active el GPS');
    }
  }

  Future getData() async {
    _listaLugar = await _lugarBloc.obtenerTodosLugares();
    if (_listaLugar.length > 0) {
      for (var item in _listaLugar) {
        _listaLugarSegundo.add(Lugar(
          idlugar: item!.idlugar!,
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
          duracion: 0.0,
          imagenes: item.imagenes ?? [],
        ));
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
        _center = LatLng(currentLocation!.latitude, currentLocation!.longitude);
        ubicado = true;
        print(_center);
      });
    } else {
      setState(() {
        ubicado = false;
        print("object");
        print(_center);
      });
    }
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  List<Marker> _buildMarkrs() {
    final _marketList = <Marker>[];
    for (int i = 0; i < _listaLugarSegundo.length; i++) {
      // setState(() {
      final mapItem = _listaLugarSegundo[i];
      _marketList.add(Marker(
        point: LatLng(
            _listaLugarSegundo[i]!.latitud!, _listaLugarSegundo[i]!.longitud!),
        height: Config().marketSizeExpanded,
        width: Config().marketSizeExpanded,
        builder: (_) {
          return GestureDetector(
            onTap: () {
              selectIndex = i;
              nextScreen(
                  context,
                  FullMapaLugaresCercanosPage(
                    lugares: _listaLugarSegundo,
                  ));
              setState(() {
                //_pageController.animateToPage(i,
                //    duration: Duration(milliseconds: 500),
                //   curve: Curves.elasticOut);
                // _pageController.jumpToPage(i);
                //print(i);
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

  @override
  Widget build(BuildContext context) {
    var brishtness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brishtness == Brightness.dark;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 15,
              top: 10,
              bottom: 10,
            ),
            child: Text("nearby places".tr(),
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  //color: Colors.grey[800]
                )),
          ),
          Container(
            height: 300,
            width: double.infinity,
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  //if (!cargando)
                  if (_center != null && !cargando)
                    FlutterMap(
                      options: MapOptions(
                          minZoom: 5,
                          maxZoom: 18,
                          zoom: 8,
                          center:
                              LatLng(_center!.latitude, _center!.longitude)),
                      nonRotatedLayers: [
                        TileLayerOptions(
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
                          MarkerLayerOptions(
                            markers: _buildMarkrs(),
                          ),
                        if (_center != null)
                          MarkerLayerOptions(
                            markers: [
                              Marker(
                                width: 60,
                                height: 60,
                                point: LatLng(
                                    _center!.latitude, _center!.longitude),
                                builder: (_) {
                                  return MyLocationMarket(
                                      _animationController!);
                                },
                              )
                            ],
                          ),
                      ],
                    ),
                  if (_center == null && !cargando)
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: double.infinity,
                      child: Text(
                        'please active your GPS for look the map'.tr(),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),

                  if (cargando)
                    Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationMarket extends StatelessWidget {
  const LocationMarket({Key? key, this.selected = false}) : super(key: key);
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final size = Config().marketSizeShrink;
    return Center(
      child: AnimatedContainer(
        height: size,
        width: size,
        duration: Duration(milliseconds: 400),
        child: Image.asset('assets/images/pin_noactivo.png'),
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

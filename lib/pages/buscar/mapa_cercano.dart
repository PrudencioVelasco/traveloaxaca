import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
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
  int? prevPage;

  List<Lugar?> _listaLugar = [];
  LugarBloc _lugarBloc = new LugarBloc();
  final trafficService = new TrafficService();
  double _latitudInicial = 0;
  double _longitudInicial = 0;
  int selectIndex = 0;
  bool presionado = false;
  LugarMapa? detalleCompania;
  latlong.LatLng? _center;
  Position? currentLocation;
  bool cargando = true;
  bool ubicado = false;
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
    });
  }

  Future allCompanias() async {
    _listaLugar = await _lugarBloc.obtenerTodosLugares();
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
    // final _listMarkes = _buildMarkrs();
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
                  zoom: 12,
                  center: latlong.LatLng(widget.lugares.first!.latitud!,
                      widget.lugares.first!.longitud!),
                ),
                nonRotatedLayers: [
                  fluttermap.TileLayerOptions(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                    additionalOptions: {
                      'accessToken': Config().apiKey,
                      'id': Config().mapBoxStyle
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

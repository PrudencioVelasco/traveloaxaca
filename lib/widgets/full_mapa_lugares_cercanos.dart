import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:latlong2/latlong.dart';
import 'package:traveloaxaca/models/lugarmapa.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class FullMapaLugaresCercanosPage extends StatefulWidget {
  final List<Lugar?> lugares;
  FullMapaLugaresCercanosPage({Key? key, required this.lugares})
      : super(key: key);

  @override
  _FullMapaLugaresCercanosPageState createState() =>
      _FullMapaLugaresCercanosPageState();
}

class _FullMapaLugaresCercanosPageState
    extends State<FullMapaLugaresCercanosPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  PageController _pageController = PageController();
  List<LugarMapa> _alldata = [];
  int selectIndex = 0;
  bool cargando = true;
  LatLng? _center;
  Position? currentLocation;
  bool ubicado = false;
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
        _center = LatLng(currentLocation!.latitude, currentLocation!.longitude);
        ubicado = true;
      });
    } else {
      setState(() {
        ubicado = false;
      });
    }
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
        }
      }
    }
    setState(() {
      cargando = false;
    });
  }

  List<Marker> _buildMarkrs() {
    final _marketList = <Marker>[];
    for (int i = 0; i < _alldata.length; i++) {
      // setState(() {
      _marketList.add(Marker(
        point: LatLng(_alldata[i].latitud!, _alldata[i].longitud!),
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
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final _listMarkes = _buildMarkrs();
    var brishtness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brishtness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            //if (!cargando)

            if (_center != null)
              FlutterMap(
                options: MapOptions(
                    minZoom: 5,
                    maxZoom: 18,
                    zoom: 8,
                    center: LatLng(_center!.latitude, _center!.longitude)),
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
                          point: LatLng(_center!.latitude, _center!.longitude),
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

            Positioned(
                top: 15,
                left: 10,
                child: Row(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 10,
                                  offset: Offset(3, 3))
                            ]),
                        child: Icon(
                          Icons.keyboard_backspace,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
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
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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

                                      itemBuilder: (context, _) => Icon(
                                        Icons.star_border_outlined,
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
                        Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.heart,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  companiaMapa.love.toString(),
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Icon(
                                  FontAwesomeIcons.comment,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  companiaMapa.comentario.toString(),
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                                Spacer(),
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

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/mapalugaresruta.dart';
import 'package:traveloaxaca/models/ruta.dart';
import 'package:traveloaxaca/utils/convert_map_icon.dart';
import 'package:easy_localization/easy_localization.dart';

class MapaRutasPage extends StatefulWidget {
  //final Lugar? placeData;
  final Ruta data;
  MapaRutasPage({Key? key, required this.data}) : super(key: key);

  @override
  _MapaRutasPageState createState() => _MapaRutasPageState();
}

class _MapaRutasPageState extends State<MapaRutasPage> {
  RutasBloc _rutasBloc = new RutasBloc();
  GoogleMapController? _controller;

  List<LugaresRutaMapa> _alldata = [];
  PageController? _pageController;
  int? prevPage;
  List _markers = [];
  Uint8List? _customMarkerIcon;
  List<Lugar?> _lugares = [];
  Completer<GoogleMapController> _controllerPunto = Completer();
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

  Future getData() async {
    _lugares = (await _rutasBloc.getLugaresRuta(widget.data.idruta!))!;
    if (_lugares.length == 0) {
      openEmptyDialog();
    } else {
      _lugares.forEach((element) {
        LugaresRutaMapa d = LugaresRutaMapa(
            element!.nombre!,
            element.direccion ?? '',
            element.latitud ?? 0.0,
            element.longitud ?? 0.0,
            element.numero ?? 0,
            element.descripcion ?? '');
        _alldata.add(d);
        _alldata.sort((a, b) => a.numero.compareTo(b.numero));
      });
    }

    // refresh();
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
            markerId: MarkerId(data.nombre),
            position: LatLng(data.latitud, data.longitud),
            infoWindow: InfoWindow(title: data.nombre, snippet: data.direccion),
            icon: BitmapDescriptor.defaultMarker,
            onTap: () {}));
      });
    }
  }

  void _onScroll() {
    if (_pageController!.page!.toInt() != prevPage) {
      prevPage = _pageController!.page!.toInt();
      moveCamera();
    }
  }

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
    });
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8)
      ..addListener(_onScroll);
    setMarkerIcon();
    getData().then((value) {
      //animateCameraAfterInitialization();
      _addMarker();
    });
  }

  static final CameraPosition _kLake = CameraPosition(
      // bearing: 192.8334901395799,
      target: LatLng(16.2817, -97.8209),
      // tilt: 59.440717697143555,
      zoom: 10);
  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controllerPunto.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
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
            margin: EdgeInsets.only(left: 5, right: 5, bottom: 30),
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
                        ' ${_alldata[index].numero} -  ${_alldata[index].nombre}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _alldata[index].direccion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54),
                      ),
                      /* Row(
                        children: <Widget>[
                          Container(
                            height: 20,
                            width: 90,
                            child: ListView.builder(
                              itemCount: _alldata[index].numero.round(),
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Icon(
                                  LineIcons.star,
                                  color: Colors.orangeAccent,
                                  size: 16,
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            '(${_alldata[index].numero})',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 13),
                          )
                        ],
                      )*/
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
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
                                _alldata[index].direccion,
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
                                  _alldata[index].descripcion,
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
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                mapToolbarEnabled: true,
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
                        child: Icon(Icons.keyboard_backspace),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey, width: 0.5)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 10, bottom: 10, right: 15),
                        child: Text(
                          '${widget.data.nombre}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
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

  /*animateCameraAfterInitialization() {
    _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target:
          LatLng(_alldata.firstOrNull!.longitud, _alldata.firstOrNull!.latitud),
      zoom: 13,
    )));
  }*/

  moveCamera() {
    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(_alldata[_pageController!.page!.toInt()].latitud,
                _alldata[_pageController!.page!.toInt()].longitud),
            zoom: 15,
            bearing: 90.0,
            tilt: 45.0),
      ),
    );
  }
}

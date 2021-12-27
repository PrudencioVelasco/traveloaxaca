import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/restaurant.dart';
import 'package:flutter_map/flutter_map.dart' as fluttermap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:traveloaxaca/models/search_response.dart';
import 'package:traveloaxaca/services/traffic_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RestaurantPage extends StatefulWidget {
  final Lugar? placeData;
  RestaurantPage({Key? key, required this.placeData}) : super(key: key);

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage>
    with SingleTickerProviderStateMixin {
  List<Restaurant> _alldata = [];
  PageController _pageController = PageController();
  TrafficService _trafficService = new TrafficService();
  int? prevPage;
  List _markers = [];
  Uint8List? _customMarkerIcon;
  Restaurant? detalleCompania;
  int selectIndex = 0;
  bool cargando = true;
  List<fluttermap.Marker> _marketList = [];
  AnimationController? _animationController;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController!.repeat();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
    });
    super.initState();
    getData();
    refresh();
  }

  Future getData() async {
    double latitud = widget.placeData!.latitud!;
    double longitud = widget.placeData!.longitud!;
    SearchResponse response = await _trafficService.getResultadosPorQuery(
        'restaurant', latitud, longitud);

    if (response.features == null) {
      openEmptyDialog();
    } else {
      for (var item in response.features!) {
        Restaurant d = Restaurant(
          item != null ? item.textEs! : '',
          item != null ? item.placeName! : '',
          item!.center![1] ?? 0,
          item.center![0] ?? 0,
          0,
          0,
          false,
        );
        _alldata.add(d);
      }
    }
    setState(() {
      if (mounted) {
        cargando = false;
      }
    });
  }

  List<fluttermap.Marker> _buildMarkrs() {
    final _marketList = <fluttermap.Marker>[];
    for (var i = 0; i < _alldata.length; i++) {
      setState(() {
        _marketList.add(fluttermap.Marker(
          point: latlong.LatLng(_alldata[i].lat, _alldata[i].lng),
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
              child: LocationMarketRestaurant(
                selected: selectIndex == i,
              ),
            );
          },
        ));
      });
    }
    return _marketList;
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

  void openEmptyDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content:
                Text("we didn't find any nearby restaurants in this area").tr(),
            title: Text(
              'no restaurants found',
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
        title: Text("nearby restaurants".tr(),
            style: Theme.of(context).textTheme.headline6),
      ),
      body: Stack(
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
                  'id': Config().mapBoxStyle
                },
              ),
              fluttermap.MarkerLayerOptions(
                markers: _buildMarkrs(),
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
                return MapItemDetailsRestaurant(
                  companiaMapa: item,
                );
              },
            ),
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

class FlotanteCompaniaRestaurant extends StatelessWidget {
  const FlotanteCompaniaRestaurant({
    Key? key,
    required Restaurant alldata,
  })  : _alldata = alldata,
        super(key: key);

  final Restaurant _alldata;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        right: 0,
        bottom: 20,
        height: MediaQuery.of(context).size.height * 0.25,
        child: MapItemDetailsRestaurant(companiaMapa: _alldata));
  }
}

class LocationMarketRestaurant extends StatelessWidget {
  const LocationMarketRestaurant({Key? key, this.selected = false})
      : super(key: key);
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
        child: Image.asset('assets/images/restaurant_pin.png'),
      ),
    );
  }
}

class MapItemDetailsRestaurant extends StatelessWidget {
  const MapItemDetailsRestaurant({Key? key, required this.companiaMapa})
      : super(key: key);
  final Restaurant companiaMapa;

  openMapsSheet(BuildContext context) async {
    final availableMaps = await MapLauncher.installedMaps;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: SingleChildScrollView(
            child: Container(
              child: Wrap(
                children: [
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                          coords: Coords(companiaMapa.lat, companiaMapa.lng),
                          title: companiaMapa.name),
                      title: Text(map.mapName),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30.0,
                        width: 30.0,
                      ),
                    )
                ],
              ),
            ),
          ));
        });
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
                      child: Image.asset('assets/images/restaurant.png')),
                  Flexible(
                    child: Wrap(
                      children: [
                        Container(
                          height: 10,
                        ),
                        Text(
                          companiaMapa.name.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Text(
                          companiaMapa.address.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            MaterialButton(
              padding: EdgeInsets.zero,
              color: Config().marketColor,
              elevation: 6,
              onPressed: () => openMapsSheet(context),
              child: Text("visit").tr(),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
//import 'package:flutter_map/flutter_map.dart';
import 'package:geo/geo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:latlong2/latlong.dart';

const MAPBOX_ACCESS_TOKEN =
    "sk.eyJ1IjoiZHVndWVyIiwiYSI6ImNrd3puampxZTB3am0zMnE5dXp3cXpjcXcifQ.hZUrbDidn2hDJIvMSs3aPQ";
const MAPBOX_STYLE = "mapbox/dark-v10";
const MARKER_cOLOR = Color(0xFF3DC5A7);
//final myLocation = LatLng(16.28127274045661, -97.8204067527212);

class MapaDarkPage extends StatefulWidget {
  const MapaDarkPage({Key? key}) : super(key: key);

  @override
  _MapaDarkPageState createState() => _MapaDarkPageState();
}

class _MapaDarkPageState extends State<MapaDarkPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


/*class MapMarket {
  String? image;
  String? title;
  String? addres;
  LatLng? location;
  const MapMarket({
    required this.image,
    required this.title,
    required this.addres,
    required this.location,
  });
}*/

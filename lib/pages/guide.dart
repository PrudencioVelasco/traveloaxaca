import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/utils/convert_map_icon.dart';

class GuiaPage extends StatefulWidget {
  final Lugar? data;
  //GuiaPage(this.data);
  const GuiaPage({Key? key, @required this.data}) : super(key: key);
  @override
  _GuiaPageState createState() => _GuiaPageState();
}

class _GuiaPageState extends State<GuiaPage> {
  double _latitud = 99.00;
  double? _longitud;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setMarkerIcons();
    // _latitud = widget.data!.latitud!;
  }

  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Uint8List? _sourceIcon;
  Uint8List? _destinationIcon;
  CameraPosition? _currentPosition;
  List<MarkerId> listMarkerIds = List<MarkerId>.empty(growable: true);

  _setMarkerIcons() async {
    _sourceIcon = await getBytesFromAsset(Config().drivingMarkerIcon, 110);
    _destinationIcon =
        await getBytesFromAsset(Config().destinationMarkerIcon, 110);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.data!.nombre.toString(),
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        child: GoogleMap(
          mapToolbarEnabled: true,
          // initialCameraPosition: Config().initialCameraPosition,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.data!.latitud!, widget.data!.longitud!),
            zoom: 11.0,
          ),
          onTap: (_) {},
          mapType: MapType.normal,
          markers: Set<Marker>.of(markers.values),
          onMapCreated: (GoogleMapController controler) {
            _controller.complete(controler);

            MarkerId markerId2 = MarkerId("2");
            listMarkerIds.add(markerId2);

            Marker marker2 = Marker(
              // consumeTapEvents: true,
              markerId: markerId2,
              position: LatLng(widget.data!.latitud!, widget.data!.longitud!),
              infoWindow: InfoWindow(
                title: widget.data!.nombre!,
                snippet: widget.data!.direccion!,
              ),
              icon: BitmapDescriptor.fromBytes(_destinationIcon!),
            );
            setState(() {
              markers[markerId2] = marker2;
            });
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:traveloaxaca/pages/buscar/mi_ubicacion_lugar_categoria.dart';
import 'package:easy_localization/easy_localization.dart';

class AccesoGpsPage extends StatefulWidget {
  final String? nombre;
  final int? idclasificacion;
  const AccesoGpsPage(
      {Key? key, required this.nombre, required this.idclasificacion})
      : super(key: key);
  @override
  _AccesoGpsPageState createState() => _AccesoGpsPageState();
}

class _AccesoGpsPageState extends State<AccesoGpsPage>
    with WidgetsBindingObserver {
  bool popup = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && !popup) {
      if (await Permission.location.isGranted) {
        await Navigator.of(context).pushReplacement(new MaterialPageRoute(
            settings: RouteSettings(name: 'principal_buscar'),
            builder: (context) => MiUbicacionPage(
                nombreclasificacion: widget.nombre,
                idclasificacion: widget.idclasificacion)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 25, right: 25, top: 10),
            child: Text(
              "please active your GPS for look the map".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 25, right: 25, top: 10),
            child: Text(
              'please activate and reload'.tr(),
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          MaterialButton(
              child: Text('reload'.tr(), style: TextStyle(color: Colors.white)),
              color: Colors.black,
              shape: StadiumBorder(),
              elevation: 0,
              splashColor: Colors.transparent,
              onPressed: () async {
                popup = true;
                final status = await Permission.location.request();
                await this.accesoGPS(status);

                popup = false;
              })
        ],
      )),
    );
  }

  Future accesoGPS(PermissionStatus status) async {
    switch (status) {
      case PermissionStatus.granted:
        bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
        if (isLocationEnabled) {
          await Navigator.of(context).pushReplacement(new MaterialPageRoute(
              settings: RouteSettings(name: 'principal_buscar'),
              builder: (context) => MiUbicacionPage(
                  nombreclasificacion: widget.nombre,
                  idclasificacion: widget.idclasificacion)));
        }
        break;

      // case PermissionStatus.undetermined:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        openAppSettings();
    }
  }
}

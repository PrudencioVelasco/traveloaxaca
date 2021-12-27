import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:traveloaxaca/helpers/helpers.dart';
import 'package:traveloaxaca/pages/buscar/mi_ubicacion.dart';
import 'package:traveloaxaca/pages/buscar/mi_ubicacion_lugar.dart';
import 'package:traveloaxaca/utils/acceso_gps_page.dart';
import 'package:permission_handler/permission_handler.dart';

class PermisoGpsPage extends StatefulWidget {
  final String? nombre;
  final int? idclasificacion;
  const PermisoGpsPage(
      {Key? key, required this.nombre, required this.idclasificacion})
      : super(key: key);
  @override
  _PermisoGpsPageState createState() => _PermisoGpsPageState();
}

class _PermisoGpsPageState extends State<PermisoGpsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (await Geolocator.isLocationServiceEnabled()) {
        Navigator.pushReplacement(
            context,
            navegarMapaFadeIn(
                context,
                PermisoGpsPage(
                    nombre: widget.nombre!,
                    idclasificacion: widget.idclasificacion!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: this.checkGpsYLocation(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Center(child: Text(snapshot.data));
          } else {
            return Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
        },
      ),
    );
  }

  Future checkGpsYLocation(BuildContext context) async {
    // PermisoGPS
    final permisoGPS = await Permission.location.isGranted;
    // GPS está activo
    final gpsActivo = await Geolocator.isLocationServiceEnabled();

    if (permisoGPS && gpsActivo) {
      Navigator.pushReplacement(
        context,
        navegarMapaFadeIn(
          context,
          (widget.idclasificacion == 16)
              ? MiUbicacionLugarPage(
                  idclasificacion: widget.idclasificacion,
                  nombreclasificacion: widget.nombre)
              : MiUbicacionPage(
                  idclasificacion: widget.idclasificacion,
                  nombreclasificacion: widget.nombre),
        ),
      );
      return '';
    } else if (!permisoGPS) {
      Navigator.pushReplacement(
          context,
          navegarMapaFadeIn(
              context,
              AccesoGpsPage(
                  idclasificacion: widget.idclasificacion,
                  nombre: widget.nombre)));
      return 'Es necesario el permiso de GPS';
    } else {
      return 'Active el GPS';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:traveloaxaca/helpers/helpers.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/utils/acceso_gps_full_mapa.dart';
import 'package:traveloaxaca/widgets/full_mapa_lugares_cercanos.dart';
import 'package:easy_localization/easy_localization.dart';

class PermisoGPSFullMapaPage extends StatefulWidget {
  final List<Lugar?> lugares;
  PermisoGPSFullMapaPage({Key? key, required this.lugares}) : super(key: key);

  @override
  State<PermisoGPSFullMapaPage> createState() => _PermisoGPSFullMapaPageState();
}

class _PermisoGPSFullMapaPageState extends State<PermisoGPSFullMapaPage>
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
              context, FullMapaLugaresCercanosPage(lugares: widget.lugares)),
        );
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
            context, FullMapaLugaresCercanosPage(lugares: widget.lugares)),
      );
      return '';
    } else if (!permisoGPS) {
      Navigator.pushReplacement(
        context,
        navegarMapaFadeIn(
          context,
          AccesoGPSFullMapaPage(
            lugares: widget.lugares,
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        navegarMapaFadeIn(
            context, AccesoGPSFullMapaPage(lugares: widget.lugares)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        navegarMapaFadeIn(
            context, AccesoGPSFullMapaPage(lugares: widget.lugares)),
      );
    }
  }
}

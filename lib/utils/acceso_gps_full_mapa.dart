import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/full_mapa_lugares_cercanos.dart';

class AccesoGPSFullMapaPage extends StatefulWidget {
  final List<Lugar?> lugares;
  AccesoGPSFullMapaPage({Key? key, required this.lugares}) : super(key: key);

  @override
  State<AccesoGPSFullMapaPage> createState() => _AccesoGPSFullMapaPageState();
}

class _AccesoGPSFullMapaPageState extends State<AccesoGPSFullMapaPage>
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
          Container(
            child: MaterialButton(
                child:
                    Text('reload'.tr(), style: TextStyle(color: Colors.white)),
                color: Colors.black,
                shape: StadiumBorder(),
                elevation: 0,
                splashColor: Colors.transparent,
                onPressed: () async {
                  popup = true;
                  final status = await Permission.location.request();
                  await this.accesoGPS(status);
                  popup = false;
                }),
          )
        ],
      )),
    );
  }

  Future accesoGPS(PermissionStatus status) async {
    switch (status) {
      case PermissionStatus.granted:
        bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
        if (isLocationEnabled) {
          // location service is enabled,
          nextScreenReplace(
              context, FullMapaLugaresCercanosPage(lugares: widget.lugares));
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

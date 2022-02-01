import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:traveloaxaca/pages/explorar.dart';

mostrarAlertaGPS(BuildContext context, String titulo, String subtitulo) {
  if (Platform.isAndroid) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(titulo),
              content: Text(subtitulo),
              actions: <Widget>[
                MaterialButton(
                    child: Text('Ok'),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () => Navigator.pop(context)),
                MaterialButton(
                    child: Text('Activar'),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () async {
                      // final status = await Permission.location.request();
                      // await accesoGPS(status, context);
                      final status = await Permission.location.request();
                      switch (status) {
                        case PermissionStatus.granted:
                          // Navigator.of(context).pushNamedAndRemoveUntil(
                          //     "/explorar", (route) => false);
                          // await Navigator.of(context).pushReplacementNamed('/explore');
                          Navigator.pop(context);
                          Navigator.of(context, rootNavigator: true).pop();
                          await Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => Explorar()));
                          Navigator.of(context, rootNavigator: true).pop();
                          break;

                        //  case PermissionStatus.undetermined:
                        case PermissionStatus.denied:
                        case PermissionStatus.restricted:
                        case PermissionStatus.permanentlyDenied:
                          openAppSettings();
                          break;
                        case PermissionStatus.limited:
                          // TODO: Handle this case.
                          break;
                      }
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).pop();
                    })
              ],
            ));
  }

  showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
            title: Text(titulo),
            content: Text(subtitulo),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Ok'),
                onPressed: () => Navigator.pop(context),
              ),
              MaterialButton(
                  child: Text('Activar'),
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () async {
                    // final status = await Permission.location.request();
                    // await accesoGPS(status, context);
                    final status = await Permission.location.request();
                    switch (status) {
                      case PermissionStatus.granted:
                        // Navigator.of(context).pushNamedAndRemoveUntil(
                        //     "/explorar", (route) => false);
                        // await Navigator.of(context).pushReplacementNamed('/explore');
                        Navigator.pop(context);
                        Navigator.of(context, rootNavigator: true).pop();
                        await Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => Explorar()));
                        Navigator.of(context, rootNavigator: true).pop();
                        break;

                      //  case PermissionStatus.undetermined:
                      case PermissionStatus.denied:
                      case PermissionStatus.restricted:
                      case PermissionStatus.permanentlyDenied:
                        openAppSettings();
                        break;
                      case PermissionStatus.limited:
                        // TODO: Handle this case.
                        break;
                    }
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).pop();
                  })
            ],
          ));
}

mostrarAlerta(BuildContext context, String titulo, String subtitulo) {
  if (Platform.isAndroid) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(titulo),
              content: Text(subtitulo),
              actions: <Widget>[
                MaterialButton(
                    child: Text('Ok'),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop())
              ],
            ));
  }

  showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
            title: Text(titulo),
            content: Text(subtitulo),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Ok'),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              )
            ],
          ));
}

mensajeDialog(BuildContext context, String titulo, String subtitulo) {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(subtitulo),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      });
}

Future accesoGPS(PermissionStatus status, BuildContext context) async {
  switch (status) {
    case PermissionStatus.granted:
      Navigator.of(context)
          .pushNamedAndRemoveUntil("/explorar", (route) => false);
      // await Navigator.of(context).pushReplacementNamed('/explore');
      //  await Navigator.push(
      //     context, new MaterialPageRoute(builder: (context) => Explorar()));
      // Navigator.of(context, rootNavigator: true).pop();
      break;

    //  case PermissionStatus.undetermined:
    case PermissionStatus.denied:
    case PermissionStatus.restricted:
    case PermissionStatus.permanentlyDenied:
      openAppSettings();
  }
}

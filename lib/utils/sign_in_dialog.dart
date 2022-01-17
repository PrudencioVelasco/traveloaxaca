import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:traveloaxaca/pages/sign_in.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

openSignInDialog(context) {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text('no sign in title').tr(),
          content: Text('no sign in subtitle').tr(),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  nextScreenPopup(
                      context,
                      SignInPage(
                        tag: 'popup',
                      ));
                },
                child: Text('sign in').tr()),
            TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text('cancel').tr())
          ],
        );
      });
}

mensajeLogin(context) {
  return Alert(
    context: context,
    type: AlertType.success,
    title: 'no sign in title'.tr(),
    desc: 'no sign in subtitle'.tr(),
    buttons: [
      DialogButton(
        child: Text(
          'cancel'.tr(),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      DialogButton(
        child: Text(
          'sign in'.tr(),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          Navigator.pop(context);
          nextScreenPopup(
              context,
              SignInPage(
                tag: 'popup',
              ));
        },
      )
    ],
  ).show();
}

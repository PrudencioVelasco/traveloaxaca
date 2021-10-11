import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetBloc extends ChangeNotifier {
  BuildContext? context;
  Future? init(BuildContext context) async {
    this.context = context;
  }

  bool _hasInternet = false;

  InternetBloc() {
    checkInternet();
  }

  set hasInternet(newVal) {
    _hasInternet = newVal;
  }

  bool get hasInternet => _hasInternet;

  checkInternet() async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    //var result = await (Connectivity().checkConnectivity());
    if (isConnected) {
      _hasInternet = true;
    } else {
      _hasInternet = false;
    }

    notifyListeners();
  }
}

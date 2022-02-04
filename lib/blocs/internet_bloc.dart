import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class InternetBloc extends ChangeNotifier {
  bool _hasInternet = false;

  InternetBloc() {
    checkInternet();
  }

  set hasInternet(newVal) {
    _hasInternet = newVal;
  }

  bool get hasInternet => _hasInternet;

  checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _hasInternet = true;
      }
    } on SocketException catch (_) {
      _hasInternet = false;
    }

    notifyListeners();
  }

  Future<bool?> checarInternar() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    // return false;
  }
}

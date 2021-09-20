import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//sort length
void openToast(context, message) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}

//long length
void openToast1(context, message) {
  Fluttertoast.showToast(
      msg: message, textColor: Colors.white, toastLength: Toast.LENGTH_LONG);
}

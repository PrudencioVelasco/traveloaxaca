import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/setting/res/constant.dart';
import 'package:sp_util/sp_util.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? get locale {
    final String locale = SpUtil.getString(Constant.locale) ?? '';
    switch (locale) {
      case 'es':
        return const Locale('es', 'es_MX');
      case 'en':
        return const Locale('en', 'US');
      default:
        return null;
    }
  }

  void setLocale(String locale) {
    SpUtil.putString(Constant.locale, locale);
    notifyListeners();
  }
}

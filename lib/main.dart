import 'dart:io';

import 'package:flutter/material.dart';
import 'package:traveloaxaca/pages/home.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(EasyLocalization(
    supportedLocales: [Locale('en'), Locale('es')],
    path: 'assets/translations',
    fallbackLocale: Locale('en'),
    startLocale: Locale('en'),
    useOnlyLangCode: true,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        locale: context.locale,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.blueAccent,
            iconTheme: IconThemeData(color: Colors.grey[900]),
            fontFamily: 'Muli',
            scaffoldBackgroundColor: Colors.grey[100],
            appBarTheme: AppBarTheme(
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.grey[800],
              ),
              brightness:
                  Platform.isAndroid ? Brightness.dark : Brightness.light,
              textTheme: TextTheme(
                  headline6: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.grey[900],
                      fontWeight: FontWeight.w500)),
            )),
        title: 'Travel Oaxaca',
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    );
  }
}

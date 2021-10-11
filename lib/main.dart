import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traveloaxaca/blocs/actividad_bloc.dart';
import 'package:traveloaxaca/blocs/atractivo_bloc.dart';
import 'package:traveloaxaca/blocs/buscar_bloc.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/featured_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/blocs/search_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/blocs/sitiosinteres_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/pages/loading_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool english = true;
  final String defaultLocale = Platform.localeName;
  if (defaultLocale.isNotEmpty) {
    String languageCode = Platform.localeName.split('_')[0];
    String countryCode = Platform.localeName.split('_')[1];
    if (languageCode.isNotEmpty && countryCode.isNotEmpty) {
      if (languageCode == 'es') {
        english = false;
      }
    }
  }
  runApp(EasyLocalization(
    supportedLocales: [Locale('en'), Locale('es')],
    path: 'assets/translations',
    fallbackLocale: (english) ? Locale('en') : Locale('es'),
    startLocale: (english) ? Locale('en') : Locale('es'),
    useOnlyLangCode: true,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ActividadBloc(),
        ),
        ChangeNotifierProvider<AtractivoBloc>(
          create: (context) => new AtractivoBloc(),
        ),
        ChangeNotifierProvider<BuscarBloc>(
          create: (context) => BuscarBloc(),
        ),
        ChangeNotifierProvider<CategoriaBloc>(
          create: (context) => CategoriaBloc(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentsBloc(),
        ),
        ChangeNotifierProvider<FeaturedBloc>(
          create: (context) => FeaturedBloc(),
        ),
        ChangeNotifierProvider(
          create: (_) => LoveBloc(),
        ),
        ChangeNotifierProvider(
          create: (_) => SignInBloc(),
        ),
        ChangeNotifierProvider(
          create: (_) => InternetBloc(),
        ),
        ChangeNotifierProvider<PopularPlacesBloc>(
          create: (context) => PopularPlacesBloc(),
        ),
        ChangeNotifierProvider<RutasBloc>(
          create: (context) => RutasBloc(),
        ),
        ChangeNotifierProvider<SearchBloc>(create: (context) => SearchBloc()),
        ChangeNotifierProvider<SitiosInteresBloc>(
            create: (context) => SitiosInteresBloc()),
      ],
      child: GestureDetector(
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
                systemOverlayStyle: SystemUiOverlayStyle.dark, // 2
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
          home: LoadingPage(),
        ),
      ),
    );
  }
}

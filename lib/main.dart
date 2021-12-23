import 'dart:io';

import 'package:flutter/material.dart';
import 'package:traveloaxaca/blocs/actividad_bloc.dart';
import 'package:traveloaxaca/blocs/atractivo_bloc.dart';
import 'package:traveloaxaca/blocs/buscar_bloc.dart';
import 'package:traveloaxaca/blocs/busqueda_next_bloc.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/blocs/featured_bloc.dart';
import 'package:traveloaxaca/blocs/imagen_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/blocs/search_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/blocs/sitiosinteres_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/tour_bloc.dart';
import 'package:traveloaxaca/pages/buscar.dart';
import 'package:traveloaxaca/pages/buscar/buscar_lugar_categoria.dart';
import 'package:traveloaxaca/pages/loading_page.dart';
import 'package:traveloaxaca/pages/perfil.dart';
import 'package:traveloaxaca/setting/provider/locale_provider.dart';
import 'package:traveloaxaca/setting/provider/theme_provider.dart';
import 'package:traveloaxaca/utils/acceso_gps_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sp_util/sp_util.dart';
import 'package:traveloaxaca/setting/res/device_utils.dart';
import 'package:traveloaxaca/setting/res/theme_utils.dart';

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

Widget? home;
ThemeData? theme;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget app = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
        ChangeNotifierProvider(
          create: (_) => TourBloc(),
        ),
        ChangeNotifierProvider<SearchBloc>(create: (context) => SearchBloc()),
        ChangeNotifierProvider<SitiosInteresBloc>(
            create: (context) => SitiosInteresBloc()),
        ChangeNotifierProvider<BusquedaNextBloc>(
            create: (context) => BusquedaNextBloc()),
        ChangeNotifierProvider<CompaniaBloc>(
            create: (context) => CompaniaBloc()),
        ChangeNotifierProvider<LugarBloc>(create: (context) => LugarBloc()),
        ChangeNotifierProvider<ImagenBloc>(create: (context) => ImagenBloc()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder:
            (_, ThemeProvider provider, LocaleProvider localeProvider, __) {
          return _buildMaterialApp(provider, localeProvider, context);
        },
      ),
    );

    /// Toast 配置
    return OKToast(
        backgroundColor: Colors.black54,
        textPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        radius: 20.0,
        position: ToastPosition.bottom,
        child: app);
  }

  Widget _buildMaterialApp(ThemeProvider provider,
      LocaleProvider localeProvider, BuildContext context) {
    return MaterialApp(
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      theme: theme ?? provider.getTheme(),
      darkTheme: provider.getTheme(isDarkMode: true),
      themeMode: provider.getThemeMode(),
      title: 'Travel Oaxaca',
      debugShowCheckedModeBanner: false,
      home: LoadingPage(),
      routes: {
        'perfil': (_) => PerfilPage(),
        //  'principal_buscar': (context) => BuscarLugarCategoriaPage(),
        // 'acceso_gps': (_) => AccesoGpsPage(),
      },
      builder: (BuildContext context, Widget? child) {
        if (Device.isAndroid) {
          ThemeUtils.setSystemNavigationBar(provider.getThemeMode());
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }

  /*@override
  Widget build(BuildContext context) {
    // final tema = Provider.of<ThemeProvider>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
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
        ChangeNotifierProvider(
          create: (_) => TourBloc(),
        ),
        ChangeNotifierProvider<SearchBloc>(create: (context) => SearchBloc()),
        ChangeNotifierProvider<SitiosInteresBloc>(
            create: (context) => SitiosInteresBloc()),
        ChangeNotifierProvider<BusquedaNextBloc>(
            create: (context) => BusquedaNextBloc()),
        ChangeNotifierProvider<CompaniaBloc>(
            create: (context) => CompaniaBloc()),
        ChangeNotifierProvider<LugarBloc>(create: (context) => LugarBloc()),
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
          theme: theme ?? context.watch<ThemeProvider>().getTheme(),
          darkTheme: context.watch<ThemeProvider>().getTheme(isDarkMode: true),
          themeMode: context.watch<ThemeProvider>().getThemeMode(),
          title: 'Travel Oaxaca',
          debugShowCheckedModeBanner: false,
          home: LoadingPage(),
          routes: {
            'perfil': (_) => PerfilPage(),
            'principal_buscar': (_) => BuscarPage(),
            'acceso_gps': (_) => AccesoGpsPage(),
          },
        ),
      ),
    );
  }*/
}

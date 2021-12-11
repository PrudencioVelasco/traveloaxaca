import 'package:flutter/material.dart';
import 'package:traveloaxaca/pages/buscar.dart';
import 'package:traveloaxaca/pages/explorar.dart';
import 'package:traveloaxaca/pages/informacion.dart';
import 'package:traveloaxaca/pages/perfil.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  PageController _pageController = PageController();
  List<IconData> iconList = [
    Icons.home,
    Icons.list,
    Icons.bookmark,
    Icons.verified_user,
  ];
  List _screens = [Explorar(), BuscarPage(), InformacionPage(), PerfilPage()];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index,
        curve: Curves.easeIn, duration: Duration(milliseconds: 400));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      //await context.read<AdsBloc>().initAdmob();
      //await context.read<AdsBloc>().initFbAd();
      // await context.read<NotificationBloc>().initFirebasePushNotification(context);

      //await context.read<AdsBloc>().checkAdsEnable();
      //context.read<AdsBloc>().enableAds();
    });
    refresh();
  }

  @override
  void dispose() {
    _pageController.dispose();
    //context.read<AdsBloc>().dispose();
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  int _currentIndex2 = 0;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,

        backgroundColor: colorScheme.surface,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: colorScheme.onSurface.withOpacity(.60),
        selectedLabelStyle: textTheme.caption,
        unselectedLabelStyle: textTheme.caption,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            label: 'explorer'.tr(),
            icon: Icon(Icons.apps),
          ),
          BottomNavigationBarItem(
            label: 'search'.tr(),
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            label: 'information'.tr(),
            icon: Icon(Icons.info),
          ),
          BottomNavigationBarItem(
            label: 'profile'.tr(),
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _shrineColorScheme,
    textTheme: _buildShrineTextTheme(base.textTheme),
  );
}

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base
      .copyWith(
    caption: base.caption!.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      letterSpacing: defaultLetterSpacing,
    ),
    button: base.button!.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: defaultLetterSpacing,
    ),
  )
      .apply(
    fontFamily: 'Rubik',
    displayColor: shrineBrown900,
    bodyColor: shrineBrown900,
  );
}

const ColorScheme _shrineColorScheme = ColorScheme(
  primary: shrinePink100,
  primaryVariant: shrineBrown900,
  secondary: shrinePink50,
  secondaryVariant: shrineBrown900,
  surface: shrineSurfaceWhite,
  background: shrineBackgroundWhite,
  error: shrineErrorRed,
  onPrimary: shrineBrown900,
  onSecondary: shrineBrown900,
  onSurface: shrineBrown900,
  onBackground: shrineBrown900,
  onError: shrineSurfaceWhite,
  brightness: Brightness.light,
);
const Color shrinePink50 = Color(0xFFFEEAE6);
const Color shrinePink100 = Color(0xFFFEDBD0);
const Color shrinePink300 = Color(0xFFFBB8AC);
const Color shrinePink400 = Color(0xFFEAA4A4);

const Color shrineBrown900 = Color(0xFF442B2D);
const Color shrineBrown600 = Color(0xFF7D4F52);

const Color shrineErrorRed = Color(0xFFC5032B);

const Color shrineSurfaceWhite = Color(0xFFFFFBFA);
const Color shrineBackgroundWhite = Colors.white;

const defaultLetterSpacing = 0.03;

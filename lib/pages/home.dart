import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/pages/buscar.dart';
import 'package:traveloaxaca/pages/explorar.dart';
import 'package:traveloaxaca/pages/perfil.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:easy_localization/easy_localization.dart';

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
  List _screens = [Explorar(), BuscarPage(), Explorar(), PerfilPage()];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(Icons.apps),
            title: Text('explorer').tr(),
            activeColor: Colors.red,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.search),
            title: Text('search').tr(),
            activeColor: Colors.purpleAccent,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.event),
            title: Text(
              'events',
            ).tr(),
            activeColor: Colors.pink,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.person),
            title: Text('profile').tr(),
            activeColor: Colors.blue,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

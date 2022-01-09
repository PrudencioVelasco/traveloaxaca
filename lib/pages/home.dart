import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:traveloaxaca/pages/buscar.dart';
import 'package:traveloaxaca/pages/explorar.dart';
import 'package:traveloaxaca/pages/informacion.dart';
import 'package:traveloaxaca/pages/perfil.dart';
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
  PersistentTabController? _controller =
      PersistentTabController(initialIndex: 0);
  List _screens = [Explorar(), BuscarPage(), InformacionPage(), PerfilPage()];
  List<Widget> _buildScreens() {
    return [Explorar(), BuscarPage(), InformacionPage(), PerfilPage()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.apps),
        title: ("explorer".tr()),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.search),
        title: ("search".tr()),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.info),
        title: ("information".tr()),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.settings),
        title: ("profile".tr()),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

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
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.style3, // Choose the nav bar style with this property.
    );
  }
  /* final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,

        // backgroundColor: colorScheme.surface,
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
    );*/

}

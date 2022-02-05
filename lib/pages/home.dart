import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:traveloaxaca/pages/buscar.dart';
import 'package:traveloaxaca/pages/explorar.dart';
import 'package:traveloaxaca/pages/informacion.dart';
import 'package:traveloaxaca/pages/perfil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:bottom_nav_layout/bottom_nav_layout.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PersistentTabController? _controller;
  bool? _hideNavBar;
  PageController controller = PageController(initialPage: 0);
  var selected = 0;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _hideNavBar = false;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Widget> _buildScreens() {
    return [
      Explore(),
      BuscarPage(),
      //InformacionPage(),
      PerfilPage()
    ];
  }

  int selectedIndex = 0;

  //list of widgets to call ontap
  final widgetOptions = [
    Explore(),
    BuscarPage(),
    //InformacionPage(),
    PerfilPage()
  ];
  Widget build(BuildContext context) {
    return BottomNavLayout(
      pages: [
        (_) => Explore(),
        (_) => BuscarPage(),
        (_) => PerfilPage(),
      ],
      bottomNavigationBar: (currentIndex, onTap) => BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => onTap(index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(LineIcons.home), label: 'explorer'.tr()),
          BottomNavigationBarItem(
              icon: Icon(LineIcons.search), label: 'search'.tr()),
          BottomNavigationBarItem(
              icon: Icon(LineIcons.user), label: 'profile'.tr()),
        ],
      ),
      savePageState: true,
      lazyLoadPages: true,
      // StandardPageStack, ReorderToFrontExceptFirstPageStack, NoPageStack, FirstAndLastPageStack
      pageStack: ReorderToFrontPageStack(initialPage: 0),
      extendBody: false,
      resizeToAvoidBottomInset: true,
      pageTransitionData: null,
    );
  }
}

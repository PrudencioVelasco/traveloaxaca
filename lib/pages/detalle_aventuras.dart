import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/ruta.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/list_card.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

class DetalleAventurasPage extends StatefulWidget {
  final Ruta? ruta;
  DetalleAventurasPage({Key? key, required this.ruta}) : super(key: key);

  @override
  _DetalleAventurasPageState createState() => _DetalleAventurasPageState();
}

class _DetalleAventurasPageState extends State<DetalleAventurasPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollViewController = ScrollController();
  bool isScrollingDown = false;
  bool _showAppbar = true;
  bool? _isConnected;
  bool cargando = true;
  bool sinresultado = false;
  List<Lugar?> _listaLugar = [];
  RutasBloc _rutasBloc = new RutasBloc();
  final BannerAd myBanner = BannerAd(
    adUnitId: BannerAd.testAdUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  @override
  void initState() {
    myBanner.load();
    super.initState();
    _checkInternetConnection();
    obtenerLugares();
  }

  Future obtenerLugares() async {
    _listaLugar = await _rutasBloc.getLugaresRuta(widget.ruta!.idruta!);
    if (_listaLugar.length > 0) {
      if (mounted) {
        setState(() {
          cargando = false;
          sinresultado = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          cargando = false;
          sinresultado = true;
        });
      }
    }
  }

  Future<void> _checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    } on SocketException catch (err) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget adWidget = AdWidget(ad: myBanner);
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            title: Text(
              widget.ruta!.nombre.toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
          ),
        ];
      },
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: adWidget,
                  width: myBanner.size.width.toDouble(),
                  height: myBanner.size.height.toDouble(),
                ),
              ],
            ),
            Expanded(
                child: (cargando)
                    ? ListView.separated(
                        padding: EdgeInsets.all(15),
                        itemCount: 5,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(
                          height: 10,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return LoadingCard(height: 120);
                        },
                      )
                    : (sinresultado)
                        ? EmptyPage(
                            icon: FeatherIcons.clipboard,
                            message: 'no places found'.tr(),
                            message1: "try again".tr(),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.only(
                                bottom: 18, left: 10, right: 10),
                            itemCount: _listaLugar.length,
                            separatorBuilder: (context, index) => SizedBox(
                              height: 0,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return ListCardAventuras(
                                d: _listaLugar[index],
                                tag: "search$index",
                                color: Colors.white,
                              );
                            },
                          )),
          ],
        ),
      ),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/models/ruta.dart';
import 'package:traveloaxaca/pages/lugares_ruta.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class RutaPage extends StatefulWidget {
  RutaPage({Key? key}) : super(key: key);

  @override
  _RutaPageState createState() => _RutaPageState();
}

class _RutaPageState extends State<RutaPage> {
  RutasBloc _rutasBloc = new RutasBloc();
  List<Ruta?> _ruta = [];
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) async {
      _rutasBloc.init(context, refresh);
      getAllRutas();
    });
    refresh();
  }

  void getAllRutas() async {
    _ruta = (await _rutasBloc.getData())!;
    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            left: 15,
            top: 20,
          ),
          child: Row(
            children: <Widget>[
              Text(
                'turistics routers',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800]),
              ).tr(),
              Spacer(),
            ],
          ),
        ),
        Container(
          child: CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
              autoPlayInterval: Duration(seconds: 4),
            ),
            items: _ruta
                .map((item) => Container(
                      child: InkWell(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    child: Container(),
                                  ),
                                  Image.network(item!.imagen!,
                                      fit: BoxFit.cover, width: 1000.0),
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      // color: Colors.black.withOpacity(0.5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromARGB(200, 0, 0, 0),
                                            Color.fromARGB(0, 0, 0, 0)
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Text(
                                        '${item.nombre}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        onTap: () => nextScreen(
                            context,
                            LugaresRuta(
                                ruta: item, tag: item.idruta.toString())),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
/*
class ItemList extends StatelessWidget {
  final Ruta? d;
  const ItemList({Key? key, @required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
        width: MediaQuery.of(context).size.width * 0.36,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Hero(
              tag: 'popular timespan',
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomCacheImage(imageUrl: d!.imagen!)),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 0, right: 0),
                child: Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(d!.nombre!,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () => {},
    );
  }
}
*/
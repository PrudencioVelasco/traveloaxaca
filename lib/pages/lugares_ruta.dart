import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/ruta.dart';
import 'package:traveloaxaca/pages/maparutas.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';

class LugaresRuta extends StatefulWidget {
  final Ruta ruta;
  final String tag;
  LugaresRuta({Key? key, required this.ruta, required this.tag})
      : super(key: key);

  @override
  _LugaresRutaState createState() => _LugaresRutaState();
}

class _LugaresRutaState extends State<LugaresRuta> {
  RutasBloc _rutasBloc = new RutasBloc();
  List<Lugar?> _lugares = [];
  bool? _lastVisible;
  bool? _isLoading;
  ScrollController? controller;
  @override
  void initState() {
    _isLoading = true;
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      // _con.init(context);
      _rutasBloc.init(context, refresh);
      getData();
    });

    refresh();
  }

  getData() async {
    _lugares = (await _rutasBloc.getLugaresRuta(widget.ruta.idruta!))!;
    if (_lugares.length > 0) {
      _isLoading = false;
      _lastVisible = true;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void refresh() {
    setState(() {});
  }

  void onrefresh() {
    setState(() {
      _lugares.clear();
      _isLoading = true;
      _lastVisible = false;
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              backgroundColor: Colors.red,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                background: Container(
                  color: Colors.blue,
                  height: 120,
                  width: double.infinity,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        //color: Colors.green,
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '${widget.ruta.nombre}',
                          style: GoogleFonts.montserrat(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    InkWell(
                      child: Expanded(
                        child: Container(
                          //padding: EdgeInsets.only(right: 10),
                          alignment: Alignment.bottomRight,
                          margin: EdgeInsets.only(right: 10),

                          child: Text(
                            'Ver mapa',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 12,

                              //  backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      onTap: () => nextScreen(
                        context,
                        MapaRutasPage(data: widget.ruta),
                      ),
                    ),
                  ],
                ),
                titlePadding: EdgeInsets.only(left: 20, bottom: 15),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(15),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _lugares.length) {
                      return _ListItem(
                        d: _lugares[index],
                        tag: '${widget.ruta.nombre}$index',
                      );
                    }
                    return Opacity(
                      opacity: _isLoading! ? 1.0 : 0.0,
                      child: _lastVisible == false
                          ? Column(
                              children: [
                                LoadingCard(
                                  height: 180,
                                ),
                                SizedBox(
                                  height: 15,
                                )
                              ],
                            )
                          : Center(
                              child: SizedBox(
                                  width: 32.0,
                                  height: 32.0,
                                  child: new CupertinoActivityIndicator()),
                            ),
                    );
                  },
                  childCount: _lugares.length == 0 ? 5 : _lugares.length + 1,
                ),
              ),
            )
          ],
        ),
        onRefresh: () async => onrefresh(),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final Lugar? d;
  final tag;
  const _ListItem({Key? key, @required this.d, required this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 10),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey, blurRadius: 10, offset: Offset(0, 3))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Hero(
                        tag: tag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5)),
                          child: (d!.primeraimagen!.isNotEmpty)
                              ? CustomCacheImage(imageUrl: d!.primeraimagen!)
                              : Image.asset(
                                  "assets/images/no-image.png",
                                ),
                        ))),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d!.nombre!,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            FontAwesomeIcons.mapMarked,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Text(
                              d!.direccion!,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.number,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            d!.numero.toString(),
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                          Spacer(),
                          Icon(
                            LineIcons.heart,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            d!.love.toString(),
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            LineIcons.comment,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            d!.comentario.toString(),
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
      onTap: () => nextScreen(context, PlaceDetails(data: d!, tag: tag)),
    );
  }
}

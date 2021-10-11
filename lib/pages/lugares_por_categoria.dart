import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:another_flushbar/flushbar.dart';

class LugaresPorCategoriaPage extends StatefulWidget {
  final Categoria categoria;
  LugaresPorCategoriaPage({Key? key, required this.categoria})
      : super(key: key);

  @override
  _LugaresPorCategoriaPageState createState() =>
      _LugaresPorCategoriaPageState();
}

class _LugaresPorCategoriaPageState extends State<LugaresPorCategoriaPage> {
  ScrollController? _controller;
  bool _isLoading = true;
  int _lastVisible = 0;
  int _idlugarultimo = 0;
  CategoriaBloc _categoriaBloc = new CategoriaBloc();
  List<Lugar?> _lugares = [];
  List<Lugar?> _data = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
      _getData();
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _categoriaBloc.init(context, refresh);
    });
    refresh();
  }

  Future _getData() async {
    //QuerySnapshot data;
    if (_lastVisible == 0) {
//_listComentarios
      _lugares = (await _categoriaBloc
          .obtenerLugaresPorCategoria(widget.categoria.idclasificacion!))!;
    } else {
      // data = await firestore
      _data = (await _categoriaBloc
          .obtenerLugaresPorCategoria(widget.categoria.idclasificacion!))!;
      _lugares = _data;
      _lugares.where((element) => element!.idlugar! > _idlugarultimo);
    }
    if (_lugares.isNotEmpty && _lugares.length > 0) {
      if (_lugares.length > 7) {
        _idlugarultimo = _lugares[_lugares.length - 1]!.idlugar!;
        _lastVisible = 1;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          //_snap.addAll(data.docs);
          //_data = _snap.map((e) => Comment.fromFirestore(e)).toList();
          //print('blog reviews : ${_data.length}');
        });
      }
    } else {
      if (_lastVisible == 0) {
        setState(() {
          _isLoading = false;
          print('no items');
        });
      } else {
        setState(() {
          _isLoading = false;
          print('no more items');
        });
      }
    }
    return null;
  }

  @override
  void dispose() {
    _controller?.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_isLoading) {
      if (_controller?.position.pixels ==
          _controller?.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  onRefreshData() {
    setState(() {
      _isLoading = true;
      // _snap.clear();
      _lugares.clear();
      _lastVisible = 0;
    });
    _getData();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.purple,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: CustomScrollView(
          controller: _controller,
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
                  color: Colors.green,
                  height: 120,
                  width: double.infinity,
                ),
                title: Text(
                  '${widget.categoria.nombreclasificacion} places',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ).tr(),
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
                        d: _lugares[index]!,
                        tag: '${widget.categoria.nombreclasificacion}$index',
                      );
                    }
                    /*else if (_lugares.length == 0) {
                      return Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                          ),
                          EmptyPage(
                              icon: LineIcons.search,
                              message: 'no places found'.tr(),
                              message1: 'search others places'.tr()),
                        ],
                      );
                    } else {*/
                    return Opacity(
                      opacity: _isLoading ? 1.0 : 0.0,
                      child: _lastVisible == 0
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
                    //   }
                  },
                  childCount: _lugares.length == 0 ? 5 : _lugares.length + 1,
                ),
              ),
            ),
          ],
        ),
        onRefresh: () async => onRefreshData(),
      ),
    );
  }
}

class _ListItem extends StatefulWidget {
  final Lugar d;
  final tag;
  const _ListItem({Key? key, required this.d, @required this.tag})
      : super(key: key);

  @override
  __ListItemState createState() => __ListItemState();
}

class __ListItemState extends State<_ListItem> {
  String? currentLocation;
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<String> _getCurrentLocation(
      double latitudDestino, double longitudDestino) async {
    String distancia = "";
    double totalDistance = 0.0;
    LocationPermission permission;
    if (latitudDestino != 0.0 && longitudDestino != 0.0) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            currentLocation = "Permission Denied";
            Flushbar(
              title: 'Hey Ninja',
              message:
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
              duration: Duration(seconds: 3),
            ).show(context);
          });
        } else {
          var position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          // setState(() {
          totalDistance = _coordinateDistance(
            position.latitude,
            position.longitude,
            latitudDestino,
            longitudDestino,
          );
          //});
        }
      } else {
        var position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        //setState(() {
        totalDistance = _coordinateDistance(
          position.latitude,
          position.longitude,
          latitudDestino,
          longitudDestino,
        );
        //});
      }
      distancia = totalDistance.toStringAsFixed(2) + ' km';
      return distancia;
    } else {
      return "not found".tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _loveBlocProvider = Provider.of<LoveBloc>(context, listen: true);
    final _comentarioBlocProvider =
        Provider.of<CommentsBloc>(context, listen: true);
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
                      tag: widget.tag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5)),
                        child: (widget.d.primeraimagen!.isNotEmpty)
                            ? CustomCacheImage(
                                imageUrl: widget.d.primeraimagen!)
                            : Image.asset(
                                "assets/images/no-image.png",
                              ),
                      ),
                    )),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.d.nombre!,
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
                            FontAwesomeIcons.mapPin,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Text(
                              widget.d.direccion!,
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
                            CupertinoIcons.car,
                            size: 16,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          FutureBuilder(
                              future: _getCurrentLocation(
                                  widget.d.latitud!, widget.d.longitud!),
                              builder: (ctv, snapshot) {
                                return Text(
                                  '${snapshot.data}',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[700]),
                                );
                              }),
                          Spacer(),
                          Icon(
                            LineIcons.heart,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            widget.d.love!.toString(),
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            LineIcons.comment,
                            size: 16,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            widget.d.comentario!.toString(),
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
      onTap: () =>
          nextScreen(context, PlaceDetails(data: widget.d, tag: widget.tag)),
    );
  }
}

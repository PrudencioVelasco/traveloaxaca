import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/src/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/blocs/imagen_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/models/comentario_compania.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/models/horario.dart';
import 'package:traveloaxaca/models/imagen_compania.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/telefono.dart';
import 'package:traveloaxaca/pages/compania/agregar_comentario.dart';
import 'package:traveloaxaca/pages/compania/agregar_reporte.dart';
import 'package:traveloaxaca/pages/compania/comentarios.dart';
import 'package:traveloaxaca/pages/compania/compania_comentario.dart';
import 'package:traveloaxaca/pages/compania/galeria_compania.dart';
import 'package:traveloaxaca/pages/compania/horario.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class DetalleCompaniaPage extends StatefulWidget {
  final Compania? compania;
  DetalleCompaniaPage({Key? key, required this.compania}) : super(key: key);

  @override
  _DetalleCompaniaPageState createState() => _DetalleCompaniaPageState();
}

class _DetalleCompaniaPageState extends State<DetalleCompaniaPage> {
  bool _showAppbar = true;
  bool isScrollingDown = false;
  ScrollController? _scrollViewController;
  List<Horario?> _listaHorario = [];
  List<Horario?> _listaHorarioDia = [];
  CompaniaBloc _companiaBloc = new CompaniaBloc();
  CommentsBloc _commentsBloc = new CommentsBloc();
  List<ComentarioCompania?> _listComentarios = [];
  int _totalComentarios = 0;
  bool? _hasData;
  int _lastVisible = 0;
  bool? _isLoading;
  String _textVer = "view".tr();
  String _textReviews = "comments".tr();
  bool? _isConnected;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _isLoading = true;
    _scrollViewController = new ScrollController();
    _scrollViewController!.addListener(() {
      if (_scrollViewController!.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          setState(() {});
        }
      }
      if (_scrollViewController!.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          setState(() {});
        }
      }
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {});

    refresh();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty)
        setState(() {
          _isConnected = true;
        });
    } on SocketException catch (err) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  onRefreshData() {
    setState(() {
      _isLoading = true;
      // _snap.clear();
      _listComentarios.clear();
      _lastVisible = 0;
    });
  }

  handleDelete(context, ComentarioCompania d) {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    final ib = Provider.of<InternetBloc>(context, listen: false);
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('message').tr(),
            content: Text('delete from database?',
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        fontWeight: FontWeight.w700))
                .tr(),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await ib.checkInternet();
                  if (ib.hasInternet == true) {
                    Navigator.pop(context);
                    mensajeDialog(context, 'message'.tr(), 'no internet'.tr());
                  } else {
                    if (sb.idusuario != d.idusuario) {
                      Navigator.pop(context);
                      mensajeDialog(context, 'message'.tr(),
                          'You can not delete others comment'.tr());
                    } else {
                      final _commentsBloc =
                          Provider.of<CommentsBloc>(context, listen: false);
                      ResponseApi? resultado =
                          await _commentsBloc.eliminarCommentarioCompania(
                              d.idcomentario!, widget.compania!.idcompania!);
                      if (resultado!.success!) {
                        //  mostrarAlerta(
                        //      context, 'Eliminado', resultado.message!);
                        Navigator.pop(context);
                        mensajeDialog(context, 'message'.tr(), 'success'.tr());
                        onRefreshData();
                        // Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        // openToast(context, resultado.message!);
                        mensajeDialog(
                            context, 'message'.tr(), resultado.message!);
                      }
                    }
                  }
                },
                child: Text(
                  'yes',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ).tr(),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'no',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ).tr(),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final _signInBloc = Provider.of<SignInBloc>(context, listen: true);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AnimatedContainer(
              height: _showAppbar ? 56.0 : 00,
              duration: Duration(milliseconds: 200),
              child: AppBar(
                title: Text(widget.compania!.nombre.toString(),
                    style: Theme.of(context).textTheme.headline6),
                actions: [],
              ),
            ),
            (_isConnected == null)
                ? Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      height: 50.0,
                      width: 50.0,
                    ),
                  )
                : (!_isConnected!)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    left: 25, right: 25, top: 10),
                                child: Text(
                                  'are you offline?'.tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 25, right: 25, top: 10),
                              child: Text(
                                'please check your internet connection and reload the page'
                                    .tr(),
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 25, right: 25, top: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      child: Text('reload').tr(),
                                      // icon: Icon(Icons.add_comment_rounded),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.white,
                                        onPrimary: Colors.black,
                                        onSurface: Colors.black,
                                        //shadowColor: Colors.grey,
                                        padding: EdgeInsets.all(10.0),
                                        elevation: 6,

                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                      ),
                                      onPressed: () => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    : Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollViewController,
                          child: Container(
                            child: Column(children: [
                              Container(
                                child:
                                    (widget.compania!.imagenescompania!.length >
                                            0)
                                        ? _sliderImages(context, height)
                                        : _vacioListaImagen(),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    top: 10, right: 10, left: 10),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.compania!.nombre.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                    ],
                                  ),
                                  if (widget.compania!.direccion != "")
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                            child: Text(
                                          widget.compania!.direccion.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                      ],
                                    ),
                                  Row(children: [
                                    // Expanded(
                                    Container(
                                      // width: width,
                                      height: 30,
                                      //color: Colors.red,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: RatingBar.builder(
                                          // ignoreGestures: true,
                                          itemSize: 28,
                                          initialRating:
                                              widget.compania!.rating!,
                                          ignoreGestures: true,
                                          direction: Axis.horizontal,
                                          allowHalfRating: false,
                                          itemCount: 5,
                                          itemPadding: EdgeInsets.symmetric(
                                              horizontal: 0.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star_border_outlined,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {
                                            //_rating = rating;
                                            //print(rating);
                                          },
                                        ),
                                      ),
                                    ),

                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text("(" +
                                          widget.compania!.comentario
                                              .toString() +
                                          ")"),
                                    )
                                  ]),
                                  Row(
                                    children: [
                                      if (widget.compania!.paginaweb != "")
                                        Expanded(
                                            child: Container(
                                          alignment:
                                              AlignmentDirectional.centerStart,
                                          child: TextButton.icon(
                                              onPressed: () async {
                                                String url =
                                                    widget.compania!.paginaweb!;
                                                if (await canLaunch(url))
                                                  await launch(url);
                                                else
                                                  // can't launch url, there is some error
                                                  throw "Could not launch $url";
                                              },
                                              icon: Icon(
                                                FontAwesomeIcons.globe,
                                              ),
                                              label: Text("Visitar Pagina")),
                                        )),
                                      FutureBuilder(
                                        future: context
                                            .watch<CompaniaBloc>()
                                            .obtenerTelefonosCompania(
                                                widget.compania!.idcompania!),
                                        builder: (context,
                                            AsyncSnapshot<List<Telefono?>>
                                                snapshot) {
                                          /* if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else {*/
                                          if (snapshot.hasData) {
                                            if (snapshot.data!.length > 0) {
                                              return Expanded(
                                                  child: Container(
                                                alignment: AlignmentDirectional
                                                    .centerEnd,
                                                child: TextButton.icon(
                                                    onPressed: () async {
                                                      String numero = "+52" +
                                                          snapshot.data!.first!
                                                              .numerotelefono
                                                              .toString();
                                                      launch('tel://$numero');
                                                    },
                                                    icon: Icon(Icons.call),
                                                    label: Text("call".tr())),
                                              ));
                                            } else {
                                              return Container();
                                            }
                                          } else if (snapshot.hasError) {
                                            return Container();
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                          // }
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        child: FutureBuilder(
                                          future: context
                                              .watch<CompaniaBloc>()
                                              .obtenerHorarioCompaniaFiltrado(
                                                  widget.compania!.idcompania!),
                                          builder: (context,
                                              AsyncSnapshot<List<Horario?>>
                                                  snapshot) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data!.length > 0) {
                                                return Container(
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      color: Colors.green,
                                                    ),
                                                    title: Text(
                                                      "open now".tr(),
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    subtitle: Text(snapshot
                                                            .data!
                                                            .first!
                                                            .horainicial! +
                                                        " - " +
                                                        snapshot.data!.first!
                                                            .horafinal!),
                                                    trailing: IconButton(
                                                      icon: Icon(
                                                          FontAwesomeIcons
                                                              .chevronRight),
                                                      onPressed: () {
                                                        nextScreen(
                                                            context,
                                                            HorarioPage(
                                                                compania: widget
                                                                    .compania!));
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      color: Colors.red,
                                                    ),
                                                    title: Text(
                                                      "closed".tr(),
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    subtitle:
                                                        Text("schedule".tr()),
                                                    trailing: IconButton(
                                                      icon: Icon(
                                                          FontAwesomeIcons
                                                              .chevronRight),
                                                      onPressed: () {
                                                        nextScreen(
                                                            context,
                                                            HorarioPage(
                                                                compania: widget
                                                                    .compania!));
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (snapshot.hasError) {
                                                return Container();
                                              } else {
                                                return Text("loading...".tr());
                                              }
                                            }
                                          },
                                        ),
                                      ))
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 8, bottom: 8),
                                    height: 2,
                                    width: width,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                  ),
                                  if (widget.compania!.actividad != "")
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              left: 0,
                                              //top: 10,
                                            ),
                                            child: Text(
                                              'about us',
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ).tr(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (widget.compania!.actividad != "")
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Html(
                                              data:
                                                  '''${widget.compania!.actividad}''',
                                              shrinkWrap: true,
                                              style: {
                                                "body": Style(
                                                  maxLines: 3,
                                                  textAlign: TextAlign.justify,
                                                  fontSize: FontSize(16.0),
                                                  // fontWeight: FontWeight.w500,
                                                  //  color: Colors.black,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  if ((widget.compania!.actividad != "") &&
                                      widget.compania!.actividad!.length > 50)
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: ElevatedButton(
                                            child: Text('read more').tr(),
                                            // icon: Icon(Icons.add_comment_rounded),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              onPrimary: Colors.black,
                                              onSurface: Colors.black,
                                              //shadowColor: Colors.grey,
                                              padding: EdgeInsets.all(10.0),
                                              elevation: 4,

                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                            onPressed: () {},
                                          ),
                                        )
                                      ],
                                    ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: 0,
                                            //top: 10,
                                          ),
                                          child: Text(
                                            'contribute',
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ).tr(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 8, bottom: 8),
                                        height: 3,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(40)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          label: Text('write a comment').tr(),
                                          icon: Icon(Icons.add_comment_rounded),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            onPrimary: Colors.black,
                                            onSurface: Colors.black,
                                            //shadowColor: Colors.grey,
                                            padding: EdgeInsets.all(10.0),
                                            elevation: 4,

                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                          ),
                                          onPressed: () {
                                            nextScreen(
                                                context,
                                                AgregarComentarioCompaniaPage(
                                                    compania: widget.compania));
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  CompaniaComentarioPage(
                                    compania: widget.compania!,
                                  ),
                                  if (_totalComentarios >= 5)
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: ElevatedButton(
                                            child: Text(_textVer +
                                                " " +
                                                _totalComentarios.toString() +
                                                " " +
                                                _textReviews),
                                            // icon: Icon(Icons.add_comment_rounded),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              onPrimary: Colors.black,
                                              onSurface: Colors.black,
                                              //shadowColor: Colors.grey,
                                              padding: EdgeInsets.all(10.0),
                                              elevation: 4,

                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                            onPressed: () {
                                              nextScreen(
                                                  context,
                                                  ComentariosCompaniaPage(
                                                      compania:
                                                          widget.compania!,
                                                      collectionName:
                                                          'places'));
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                ]),
                              )
                            ]),
                          ),
                        ),
                      )
          ],
        ),
      ),
    );
  }

  Widget _vacioListaImagen() {
    return Hero(
      tag: 'Slider2',
      child: Container(
        color: Colors.white,
        child: Container(
          height: 250,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/no-image.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "you can upload photos of this places".tr(),
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Hero _sliderImages(BuildContext context, double height) {
    return Hero(
      tag: 'Slider',
      child: Container(
        color: Colors.white,
        child: Container(
          height: 250,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          child: CarouselSlider(
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
            ),
            items: widget.compania!.imagenescompania!
                .toList()
                .map((item) => Container(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => nextScreen(context,
                              GaleriaCompaniaPage(compania: widget.compania!)),
                          child: CachedNetworkImage(
                            imageUrl: item.url!,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                                height: 50.0,
                                width: 50.0,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            height: height,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

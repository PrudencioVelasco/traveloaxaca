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
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/blocs/tour_bloc.dart';
import 'package:traveloaxaca/models/comentario_tour.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/telefono.dart';
import 'package:traveloaxaca/models/tour.dart';
import 'package:traveloaxaca/pages/compania/detalle_compania.dart';
import 'package:traveloaxaca/pages/tour/agregar_comentario.dart';
import 'package:traveloaxaca/pages/tour/comentarios.dart';
import 'package:traveloaxaca/pages/tour/galeria_fotos.dart';
import 'package:traveloaxaca/pages/tour/mas_informacion.dart';
import 'package:traveloaxaca/pages/tour/subir_foto.dart';
import 'package:traveloaxaca/pages/tour/tour_comentario.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/sign_in_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleTourPage extends StatefulWidget {
  final Tour? tour;
  DetalleTourPage({Key? key, required this.tour}) : super(key: key);

  @override
  _DetalleTourPageState createState() => _DetalleTourPageState();
}

class _DetalleTourPageState extends State<DetalleTourPage> {
  ScrollController? _scrollViewController;
  ScrollController? _scrollComentarios;
  TourBloc _tourBloc = new TourBloc();
  CompaniaBloc _companiaBloc = new CompaniaBloc();
  bool _showAppbar = true;
  bool isScrollingDown = false;
  bool? _isLoading;
  int _lastVisible = 0;
  int _totalComentarios = 0;
  String _textlove = "love".tr();
  String _textcomentario = "comments".tr();
  String _textVer = "view".tr();
  String _textReviews = "comments".tr();
  Compania? _compania = new Compania();
  List<Telefono?> _telefono = [];
  bool? _hasData;
  List<ComentarioTour?> _listComentarios = [];
  ScrollController? controller;
  CommentsBloc _commentsBloc = new CommentsBloc();
  bool _marcarCorazon = false;
  int _totalLoves = 0;
  bool? _isConnected;
  final BannerAd myBanner = BannerAd(
    adUnitId: BannerAd.testAdUnitId,
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  @override
  void initState() {
    myBanner.load();
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
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _tourBloc.init(context, refresh);
      _companiaBloc.init(context, refresh);
      _tourBloc.iniciarValor();
      //_tourBloc.guardarRecientesTour(widget.tour!);
    });
    getDetalleCompania();
    getTelefonosCompania();
    marcarCorazonInicial();
    numerosIniciales();
    obtenerRecientesTour();
    guardarRecientesTour();
    refresh();
  }

  Future guardarRecientesTour() async {
    await _tourBloc.guardarRecientesTour(widget.tour!.idtour!);
  }

  Future obtenerRecientesTour() async {
    await _tourBloc.obtenerRecientesTour();
  }

  Future getDetalleCompania() async {
    _compania = await _companiaBloc.detalleCompania(widget.tour!.idcompania!);
    refresh();
  }

  Future numerosIniciales() async {
    int totalL = (await _tourBloc.lovesLovesTours(widget.tour!.idtour!)).length;
    int totalC = (await _tourBloc.commentsTours(widget.tour!.idtour!)).length;
    if (mounted) {
      setState(() {
        _totalLoves = totalL;
        _totalComentarios = totalC;
      });
    }
  }

  Future marcarCorazonInicial() async {
    int total = await _tourBloc.obtenerLoveTourUsuario(widget.tour!.idtour!);

    if (total > 0) {
      setState(() {
        _marcarCorazon = true;
      });
    }
  }

  Future getTelefonosCompania() async {
    _telefono =
        await _companiaBloc.obtenerTelefonosCompania(widget.tour!.idcompania!);
    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  handleLoveClick() async {
    // final ib = Provider.of<InternetBloc>(context, listen: false);
    final _signInBlocProvider = Provider.of<SignInBloc>(context, listen: false);
    final _signLoveBloc = Provider.of<TourBloc>(context, listen: false);
    final autenticado = await _signInBlocProvider.isLoggedIn();
    if (autenticado == true) {
      ResponseApi? value =
          await _signLoveBloc.agregarLoveTour(widget.tour!.idtour!);
      if (value!.success!) {
        int totalL =
            (await _tourBloc.lovesLovesTours(widget.tour!.idtour!)).length;
        int totalC =
            (await _tourBloc.commentsTours(widget.tour!.idtour!)).length;
        setState(() {
          //  _marcarCorazon = true;
          if (_marcarCorazon) {
            _marcarCorazon = false;
          } else {
            _marcarCorazon = true;
          }
          _totalLoves = totalL;
          _totalComentarios = totalC;
        });
      }
    } else {
      openSignInDialog(context);
    }
  }

  agregarComentarioClick() async {
    final _signInBlocProvider = Provider.of<SignInBloc>(context, listen: false);
    //  final ib = Provider.of<InternetBloc>(context, listen: false);
    final autenticado = await _signInBlocProvider.isLoggedIn();
    if (autenticado == true) {
      // await ib.checkInternet();
      // if (ib.hasInternet == false) {
      //   openToast(context, 'no internet'.tr());
      // } else {
      nextScreen(context, AgregarComentarioTourPage(tour: widget.tour));
      // }
    } else {
      openSignInDialog(context);
    }
  }

  subirFotoClick() async {
    final _signInBlocProvider = Provider.of<SignInBloc>(context, listen: false);
    //  final ib = Provider.of<InternetBloc>(context, listen: false);
    final autenticado = await _signInBlocProvider.isLoggedIn();
    if (autenticado == true) {
      // await ib.checkInternet();
      // if (ib.hasInternet == false) {
      //   openToast(context, 'no internet'.tr());
      // } else {
      nextScreen(context, SubirFotoComentarioTour(tour: widget.tour));
      // }
    } else {
      openSignInDialog(context);
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final _tourBlocProvider = Provider.of<TourBloc>(context, listen: true);
    final _loveBlocProvider = Provider.of<LoveBloc>(context, listen: true);
    final _signInBloc = Provider.of<SignInBloc>(context, listen: true);
    //  final _tourBlocProvider = context.watch<TourBloc>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AnimatedContainer(
              height: _showAppbar ? 56.0 : 00,
              duration: Duration(milliseconds: 200),
              child: AppBar(
                title: Text(widget.tour!.nombre!.toString(),
                    style: Theme.of(context).textTheme.headline6),
                actions: [
                  IconButton(
                      onPressed: () {
                        handleLoveClick();
                      },
                      icon: (_marcarCorazon)
                          ? Icon(
                              FontAwesomeIcons.solidHeart,
                              color: Colors.red,
                              size: 20,
                            )
                          : Icon(
                              FontAwesomeIcons.solidHeart,
                              color: Colors.grey,
                              size: 20,
                            ))
                ],
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
                          child: Column(
                            children: [
                              Container(
                                child: (widget.tour!.imagenestour!.length > 0)
                                    ? _sliderImages(context, height)
                                    : _vacioListaImagen(),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    top: 10, right: 10, left: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        TextButton.icon(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.favorite,
                                              color: Colors.grey[600],
                                            ),
                                            label: Text(
                                              _totalLoves.toString() +
                                                  " " +
                                                  _textlove,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[600]),
                                            )),
                                        TextButton.icon(
                                            onPressed: () {
                                              nextScreen(
                                                  context,
                                                  ComentariosTourPage(
                                                      tour: widget.tour!,
                                                      collectionName:
                                                          'places'));
                                            },
                                            icon: Icon(
                                              FontAwesomeIcons.comments,
                                              color: Colors.grey[600],
                                            ),
                                            label: Text(
                                              _totalComentarios.toString() +
                                                  " " +
                                                  _textcomentario,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[600]),
                                            )),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                            child: Text(
                                          widget.tour!.nombre.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline1,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                      ],
                                    ),
                                    Row(children: [
                                      Expanded(
                                        child: Container(
                                          width: width,
                                          height: 30,
                                          //color: Colors.red,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: RatingBar.builder(
                                              // ignoreGestures: true,
                                              itemSize: 28,
                                              initialRating:
                                                  widget.tour!.rating!,
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
                                      ),
                                      if (widget.tour!.precioxpersona! > 0)
                                        Expanded(
                                          child: Container(
                                            alignment:
                                                AlignmentDirectional.centerEnd,
                                            //color: Colors.green,
                                            child: Text(
                                              'from',
                                              style: TextStyle(
                                                  //color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15),
                                            ).tr(),
                                          ),
                                        )
                                    ]),
                                    if (widget.tour!.precioxpersona! > 0)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              //  padding: EdgeInsets.only(right: 10),
                                              alignment: AlignmentDirectional
                                                  .centerEnd,
                                              // color: Colors.red,
                                              child: Text(
                                                NumberFormat.currency(
                                                        locale: 'es_419')
                                                    .format(widget
                                                        .tour!.precioxpersona!),
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    if (widget.tour!.precioxpersona! > 0)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              //  padding: EdgeInsets.only(right: 10),
                                              alignment: AlignmentDirectional
                                                  .centerEnd,
                                              // color: Colors.red,
                                              child: Text(
                                                'per person',
                                                style: TextStyle(
                                                    //   color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15),
                                              ).tr(),
                                            ),
                                          )
                                        ],
                                      ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    /* Container(
                            margin: EdgeInsets.only(top: 8, bottom: 8),
                            height: 2,
                            width: width,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(40)),
                          ),*/
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            //  padding: EdgeInsets.only(right: 10),
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            // color: Colors.red,
                                            child: ReadMoreText(
                                              widget.tour!.descripcion!,
                                              trimLines: 4,
                                              colorClickableText: Colors.blue,
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText:
                                                  'read more'.tr(),
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(fontSize: 18),
                                              trimExpandedText:
                                                  'read less'.tr(),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30,
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
                                              'information',
                                              style: TextStyle(
                                                fontSize: 22,
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
                                          margin: EdgeInsets.only(
                                              top: 8, bottom: 8),
                                          height: 3,
                                          width: 150,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(40)),
                                        ),
                                      ],
                                    ),
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
                                                  '''${widget.tour!.informacion}''',
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
                                    if (widget.tour!.informacion!.isNotEmpty &&
                                        widget.tour!.informacion!.length > 50)
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
                                                            Radius.circular(
                                                                20))),
                                              ),
                                              onPressed: () {
                                                nextScreen(
                                                    context,
                                                    MasInformacionPage(
                                                      nombre: widget
                                                          .tour!.nombre
                                                          .toString(),
                                                      descripcion: widget
                                                          .tour!.informacion!,
                                                    ));
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    SizedBox(
                                      height: 30,
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
                                              'activity',
                                              style: TextStyle(
                                                fontSize: 22,
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
                                          margin: EdgeInsets.only(
                                              top: 8, bottom: 8),
                                          height: 3,
                                          width: 150,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(40)),
                                        ),
                                      ],
                                    ),
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
                                                  '''${widget.tour!.actividad}''',
                                              shrinkWrap: true,
                                              style: {
                                                "body": Style(
                                                  maxLines: 3,
                                                  textAlign: TextAlign.justify,
                                                  fontSize: FontSize(16.0),
                                                  // fontWeight: FontWeight.w500,
                                                  // color: Colors.black,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    if (widget.tour!.actividad!.isNotEmpty &&
                                        widget.tour!.actividad!.length > 50)
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
                                                            Radius.circular(
                                                                20))),
                                              ),
                                              onPressed: () {
                                                nextScreen(
                                                    context,
                                                    MasInformacionPage(
                                                      nombre: widget
                                                          .tour!.nombre
                                                          .toString(),
                                                      descripcion: widget
                                                          .tour!.actividad!,
                                                    ));
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    FutureBuilder(
                                      future: _companiaBloc.detalleCompania(
                                          widget.tour!.idcompania!),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<Compania?> snapshot) {
                                        if (snapshot.hasData) {
                                          return GestureDetector(
                                            onTap: () => nextScreen(
                                                context,
                                                DetalleCompaniaPage(
                                                    compania: snapshot.data)),
                                            child: Card(
                                              child: Container(
                                                height: 100,
                                                // color: Colors.white,
                                                child: Row(
                                                  children: [
                                                    Center(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Expanded(
                                                          child: (snapshot.data!
                                                                      .logotipo ==
                                                                  "")
                                                              ? Image.asset(
                                                                  "assets/images/no-imagen-company.jpg")
                                                              : Image.network(
                                                                  snapshot.data!
                                                                      .logotipo!,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  loadingBuilder: (BuildContext
                                                                          context,
                                                                      Widget
                                                                          child,
                                                                      ImageChunkEvent?
                                                                          loadingProgress) {
                                                                    if (loadingProgress ==
                                                                        null)
                                                                      return child;
                                                                    return Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        value: loadingProgress.expectedTotalBytes !=
                                                                                null
                                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                                                loadingProgress.expectedTotalBytes!
                                                                            : null,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                          flex: 2,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 5),
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Column(
                                                          children: [
                                                            Expanded(
                                                              flex: 5,
                                                              child: ListTile(
                                                                title: Text(
                                                                  (snapshot.data !=
                                                                          null)
                                                                      ? snapshot
                                                                          .data!
                                                                          .nombre
                                                                          .toString()
                                                                      : '',
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                subtitle: Text(
                                                                  (snapshot.data !=
                                                                          null)
                                                                      ? snapshot
                                                                          .data!
                                                                          .direccion
                                                                          .toString()
                                                                      : '',
                                                                  maxLines: 3,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 5,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  if (snapshot
                                                                          .data !=
                                                                      null)
                                                                    if (snapshot
                                                                            .data!
                                                                            .paginaweb !=
                                                                        null)
                                                                      TextButton
                                                                          .icon(
                                                                        icon:
                                                                            Icon(
                                                                          FontAwesomeIcons
                                                                              .globe,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          String
                                                                              url =
                                                                              snapshot.data!.paginaweb.toString();
                                                                          if (await canLaunch(
                                                                              url))
                                                                            await launch(url);
                                                                          else
                                                                            // can't launch url, there is some error
                                                                            throw "Could not launch $url";
                                                                        },
                                                                        label: Text(
                                                                            "Web"),
                                                                      ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  if (_telefono
                                                                          .length >
                                                                      0)
                                                                    TextButton
                                                                        .icon(
                                                                      icon: Icon(
                                                                          Icons
                                                                              .call),
                                                                      onPressed:
                                                                          () {
                                                                        String
                                                                            numero =
                                                                            "+52" +
                                                                                _telefono.first!.numerotelefono.toString();
                                                                        launch(
                                                                            'tel://$numero');
                                                                      },
                                                                      label: Text(
                                                                              "call")
                                                                          .tr(),
                                                                    ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      flex: 8,
                                                    ),
                                                  ],
                                                ),
                                                //padding: EdgeInsets.all(10),
                                              ),
                                              elevation: 4,
                                              margin: EdgeInsets.all(10),
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text("Error");
                                        } else {
                                          return CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          child: adWidget,
                                          width: myBanner.size.width.toDouble(),
                                          height:
                                              myBanner.size.height.toDouble(),
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
                                          margin: EdgeInsets.only(
                                              top: 8, bottom: 8),
                                          height: 3,
                                          width: 150,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(40)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            label: Text("upload a photo").tr(),
                                            icon:
                                                Icon(Icons.add_a_photo_rounded),
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
                                              subirFotoClick();
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            label: Text('write a comment'.tr()),
                                            icon:
                                                Icon(Icons.add_comment_rounded),
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
                                              agregarComentarioClick();
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    TourComentarioPage(tour: widget.tour!),
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
                                                            Radius.circular(
                                                                20))),
                                              ),
                                              onPressed: () {
                                                nextScreen(
                                                    context,
                                                    ComentariosTourPage(
                                                        tour: widget.tour!,
                                                        collectionName:
                                                            'places'));
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    SizedBox(
                                      height: 25,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
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
            items: widget.tour!.imagenestour!
                .toList()
                .map((item) => Container(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => nextScreen(
                              context, GaleriaFotoTourPage(tour: widget.tour!)),
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

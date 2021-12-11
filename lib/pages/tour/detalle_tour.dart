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
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/blocs/tour_bloc.dart';
import 'package:traveloaxaca/models/comentario_tour.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/telefono.dart';
import 'package:traveloaxaca/models/tour.dart';
import 'package:traveloaxaca/pages/tour/agregar_comentario.dart';
import 'package:traveloaxaca/pages/tour/agregar_reporte.dart';
import 'package:traveloaxaca/pages/tour/comentarios.dart';
import 'package:traveloaxaca/pages/tour/mas_informacion.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/sign_in_dialog.dart';
import 'package:traveloaxaca/widgets/comment_count_nuevo.dart';
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
  String _textcomentario = "view reviews".tr();
  String _textVer = "view".tr();
  String _textReviews = "reviews".tr();
  Compania? _compania = new Compania();
  List<Telefono>? _telefono = [];
  bool? _hasData;
  List<ComentarioTour?> _listComentarios = [];
  ScrollController? controller;
  CommentsBloc _commentsBloc = new CommentsBloc();
  bool _marcarCorazon = false;
  int _totalLoves = 0;
  @override
  void initState() {
    super.initState();
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
    _getData();
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
    setState(() {
      _totalLoves = totalL;
      _totalComentarios = totalC;
    });
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

  Future _getData() async {
    setState(() => _hasData = true);
    if (_lastVisible == 0) {
      _listComentarios = (await _commentsBloc.obtenerComentariosTour(
          widget.tour!.idtour!, 0, 10));
    }
    if (_listComentarios.isNotEmpty && _listComentarios.length > 0) {
      int total = (await _commentsBloc.obtenerComentariosTour(
              widget.tour!.idtour!, 0, 0))
          .length;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _totalComentarios = total;
        });
      }
    } else {
      if (_lastVisible == 0) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasData = false;
            print('no items');
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasData = true;
          print('no more items');
        });
      }
    }
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

  handleDelete(context, ComentarioTour d) {
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
                          await _commentsBloc.eliminarCommentario(
                              d.idcomentario!, widget.tour!.idtour!);
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

  onRefreshData() {
    setState(() {
      _isLoading = true;
      // _snap.clear();
      _listComentarios.clear();
      _lastVisible = 0;
    });
    _getData();
  }

  @override
  Widget build(BuildContext context) {
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
                title: Text(
                  widget.tour!.nombre!.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
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
            Expanded(
                child: SingleChildScrollView(
              controller: _scrollViewController,
              child: Container(
                color: Colors.white,

                // padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      child: _sliderImages(context, height),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton.icon(
                                  onPressed: () {
                                    nextScreen(
                                        context,
                                        ComentariosTourPage(
                                            tour: widget.tour!,
                                            collectionName: 'places'));
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.comment,
                                    color: Colors.grey[600],
                                  ),
                                  label: Text(
                                    _totalComentarios.toString() +
                                        " " +
                                        _textcomentario,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600]),
                                  )),
                              TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.favorite,
                                    color: Colors.grey[600],
                                  ),
                                  label: Text(
                                    _totalLoves.toString() + " " + _textlove,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600]),
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                  child: Text(
                                widget.tour!.nombre.toString(),
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey[800]),
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
                                  padding: const EdgeInsets.only(top: 5),
                                  child: RatingBar.builder(
                                    // ignoreGestures: true,
                                    itemSize: 28,
                                    initialRating: widget.tour!.rating!,
                                    ignoreGestures: true,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 0.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
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
                            Expanded(
                              child: Container(
                                alignment: AlignmentDirectional.centerEnd,
                                //color: Colors.green,
                                child: Text(
                                  'from',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15),
                                ).tr(),
                              ),
                            )
                          ]),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  //  padding: EdgeInsets.only(right: 10),
                                  alignment: AlignmentDirectional.centerEnd,
                                  // color: Colors.red,
                                  child: Text(
                                    NumberFormat.currency(locale: 'es_419')
                                        .format(widget.tour!.precioxpersona!),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  //  padding: EdgeInsets.only(right: 10),
                                  alignment: AlignmentDirectional.centerEnd,
                                  // color: Colors.red,
                                  child: Text(
                                    'per person',
                                    style: TextStyle(
                                        color: Colors.black,
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
                          Container(
                            margin: EdgeInsets.only(top: 8, bottom: 8),
                            height: 2,
                            width: width,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(40)),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(top: 10),
                                  //  padding: EdgeInsets.only(right: 10),
                                  alignment: AlignmentDirectional.centerStart,
                                  // color: Colors.red,
                                  child: ReadMoreText(
                                    widget.tour!.descripcion!,
                                    trimLines: 4,
                                    colorClickableText: Colors.blue,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'read more'.tr(),
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(fontSize: 18),
                                    trimExpandedText: 'read less'.tr(),
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
                                margin: EdgeInsets.only(top: 8, bottom: 8),
                                height: 3,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(40)),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Html(
                                    data: '''${widget.tour!.informacion}''',
                                    shrinkWrap: true,
                                    style: {
                                      "body": Style(
                                        maxLines: 3,
                                        textAlign: TextAlign.justify,
                                        fontSize: FontSize(16.0),
                                        // fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        textOverflow: TextOverflow.ellipsis,
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
                                    onPressed: () {
                                      nextScreen(
                                          context,
                                          MasInformacionPage(
                                            nombre:
                                                widget.tour!.nombre.toString(),
                                            descripcion:
                                                widget.tour!.informacion!,
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
                                margin: EdgeInsets.only(top: 8, bottom: 8),
                                height: 3,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(40)),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Html(
                                    data: '''${widget.tour!.actividad}''',
                                    shrinkWrap: true,
                                    style: {
                                      "body": Style(
                                        maxLines: 3,
                                        textAlign: TextAlign.justify,
                                        fontSize: FontSize(16.0),
                                        // fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        textOverflow: TextOverflow.ellipsis,
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
                                    onPressed: () {
                                      nextScreen(
                                          context,
                                          MasInformacionPage(
                                            nombre:
                                                widget.tour!.nombre.toString(),
                                            descripcion:
                                                widget.tour!.actividad!,
                                          ));
                                    },
                                  ),
                                )
                              ],
                            ),
                          SizedBox(
                            height: 30,
                          ),
                          Card(
                            child: Container(
                              height: 100,
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Expanded(
                                        child: Image.asset(
                                            "assets/images/hotel.png"),
                                        flex: 2,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(top: 5),
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: ListTile(
                                              title: Text(
                                                (_compania != null)
                                                    ? _compania!.nombre
                                                        .toString()
                                                    : '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                (_compania != null)
                                                    ? _compania!.direccion
                                                        .toString()
                                                    : '',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                if (_compania != null)
                                                  if (_compania!.paginaweb !=
                                                      null)
                                                    TextButton.icon(
                                                      icon: Icon(
                                                        FontAwesomeIcons.globe,
                                                      ),
                                                      onPressed: () async {
                                                        String url = _compania!
                                                            .paginaweb
                                                            .toString();
                                                        if (await canLaunch(
                                                            url))
                                                          await launch(url);
                                                        else
                                                          // can't launch url, there is some error
                                                          throw "Could not launch $url";
                                                      },
                                                      label: Text("Web"),
                                                    ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                if (_telefono != null)
                                                  TextButton.icon(
                                                    icon: Icon(Icons.call),
                                                    onPressed: () {
                                                      String numero = "+52" +
                                                          _telefono!.first
                                                              .numerotelefono
                                                              .toString();
                                                      launch('tel://$numero');
                                                    },
                                                    label: Text("call").tr(),
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
                                    BorderRadius.all(Radius.circular(10))),
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
                                margin: EdgeInsets.only(top: 8, bottom: 8),
                                height: 3,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(40)),
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
                                  icon: Icon(Icons.add_a_photo_rounded),
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
                                  onPressed: () {},
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: ElevatedButton.icon(
                                  label: Text('write a review').tr(),
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
                                        AgregarComentarioTourPage(
                                            tour: widget.tour));
                                  },
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
                                child: _hasData == false
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 30),
                                        child: ListView(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          children: [
                                            EmptyPage(
                                                icon: LineIcons.comments,
                                                message:
                                                    'no comments found'.tr(),
                                                message1:
                                                    'be the first to comment'
                                                        .tr()),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        // color: Colors.red,
                                        margin: EdgeInsets.only(top: 15),
                                        child: ListView.separated(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          primary: false,
                                          padding: EdgeInsets.all(5),
                                          // controller: _scrollViewController,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: _listComentarios.length,
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int index) =>
                                                  SizedBox(
                                            height: 0,
                                          ),
                                          itemBuilder: (_, int index) {
                                            if (index <
                                                _listComentarios.length) {
                                              //return reviewList(_listComentarios[index]!, context,_signInBloc);
                                              return Container(
                                                  //  padding: EdgeInsets.only(
                                                  //      top: 5, bottom: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          width: 1,
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                    //  borderRadius: BorderRadius.circular(5)),
                                                  ),
                                                  child: ListTile(
                                                      leading: (_listComentarios[
                                                                  index]!
                                                              .imageUrl!
                                                              .isEmpty)
                                                          ? Container(
                                                              height: 50,
                                                              width: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                  Icons.person,
                                                                  size: 28),
                                                            )
                                                          : CircleAvatar(
                                                              radius: 25,
                                                              backgroundColor:
                                                                  Colors.grey[
                                                                      200],
                                                              backgroundImage:
                                                                  CachedNetworkImageProvider(
                                                                      _listComentarios[
                                                                              index]!
                                                                          .imageUrl!)),
                                                      title: Column(
                                                        children: <Widget>[
                                                          Container(
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  _listComentarios[
                                                                          index]!
                                                                      .userName!,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    _listComentarios[
                                                                            index]!
                                                                        .fecha
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        color: Colors.grey[
                                                                            500],
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.w500)),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                //alignment: MainAxisAlignment.start,
                                                                //color: Colors.red,
                                                                child: RatingBar
                                                                    .builder(
                                                                  // ignoreGestures: true,
                                                                  itemSize: 20,
                                                                  initialRating:
                                                                      _listComentarios[
                                                                              index]!
                                                                          .rating!,
                                                                  minRating: _listComentarios[
                                                                          index]!
                                                                      .rating!,
                                                                  maxRating: _listComentarios[
                                                                          index]!
                                                                      .rating!,
                                                                  ignoreGestures:
                                                                      true,
                                                                  direction: Axis
                                                                      .horizontal,
                                                                  allowHalfRating:
                                                                      false,
                                                                  itemCount: 5,
                                                                  itemPadding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              4.0),
                                                                  itemBuilder:
                                                                      (context,
                                                                              _) =>
                                                                          Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .amber,
                                                                  ),
                                                                  onRatingUpdate:
                                                                      (rating) {
                                                                    //_rating = rating;
                                                                    //print(rating);
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    ReadMoreText(
                                                                  _listComentarios[
                                                                          index]!
                                                                      .comentario!,
                                                                  trimLines: 4,
                                                                  colorClickableText:
                                                                      Colors
                                                                          .blue,
                                                                  trimMode:
                                                                      TrimMode
                                                                          .Line,
                                                                  trimCollapsedText:
                                                                      'read more'
                                                                          .tr(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                  trimExpandedText:
                                                                      'read less'
                                                                          .tr(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          PopupMenuButton(
                                                              // key: _menuKey,
                                                              itemBuilder: (_) =>
                                                                  <
                                                                      PopupMenuItem<
                                                                          String>>[
                                                                    if (_listComentarios[index]!
                                                                            .idusuario ==
                                                                        _signInBloc
                                                                            .idusuario)
                                                                      PopupMenuItem<String>(
                                                                          child: Text(
                                                                              'Eliminar'),
                                                                          value:
                                                                              'eliminar'),
                                                                    PopupMenuItem<String>(
                                                                        child: Text(
                                                                            'Reportar'),
                                                                        value:
                                                                            'reportar'),
                                                                  ],
                                                              onSelected:
                                                                  (valor) {
                                                                print(valor);
                                                                if (valor ==
                                                                    "reportar") {
                                                                  nextScreen(
                                                                      context,
                                                                      ReportarComentarioTourPage(
                                                                          comentario:
                                                                              _listComentarios[index]!));
                                                                }
                                                                if (valor ==
                                                                    "eliminar") {
                                                                  handleDelete(
                                                                      context,
                                                                      _listComentarios[
                                                                          index]!);
                                                                }
                                                              }),
                                                        ],
                                                      )));
                                            }
                                            return Opacity(
                                              opacity: _isLoading! ? 1.0 : 0.0,
                                              child: _lastVisible == 0
                                                  ? LoadingCard(height: 100)
                                                  : Center(
                                                      child: SizedBox(
                                                          width: 32.0,
                                                          height: 32.0,
                                                          child:
                                                              new CupertinoActivityIndicator()),
                                                    ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          if (_totalComentarios >= 10)
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
                                    onPressed: () {
                                      nextScreen(
                                          context,
                                          ComentariosTourPage(
                                              tour: widget.tour!,
                                              collectionName: 'places'));
                                    },
                                  ),
                                )
                              ],
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
                          child: Image.network(
                        item.url!,
                        fit: BoxFit.cover,
                        height: height,
                      )),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

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
import 'package:traveloaxaca/models/imagen_compani.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/telefono.dart';
import 'package:traveloaxaca/pages/compania/agregar_comentario.dart';
import 'package:traveloaxaca/pages/compania/agregar_reporte.dart';
import 'package:traveloaxaca/pages/compania/comentarios.dart';
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
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {});
    _getData();
    refresh();
  }

  Future _getData() async {
    setState(() => _hasData = true);
    if (_lastVisible == 0) {
      _listComentarios = (await _commentsBloc.obtenerComentariosCompania(
          widget.compania!.idcompania!, 0, 5));
    }
    if (_listComentarios.isNotEmpty && _listComentarios.length > 0) {
      int total = (await _commentsBloc.obtenerComentariosCompania(
              widget.compania!.idcompania!, 0, 0))
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

  onRefreshData() {
    setState(() {
      _isLoading = true;
      // _snap.clear();
      _listComentarios.clear();
      _lastVisible = 0;
    });
    _getData();
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
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollViewController,
                child: Container(
                  child: Column(children: [
                    Container(
                      child: _sliderImages(context, height, width),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: Text(
                              widget.compania!.nombre.toString(),
                              style: Theme.of(context).textTheme.headline1,
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
                                initialRating: widget.compania!.rating!,
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

                          Container(
                            padding: EdgeInsets.only(top: 10),
                            child: Text("(" +
                                widget.compania!.comentario.toString() +
                                ")"),
                          )
                        ]),
                        Row(
                          children: [
                            if (widget.compania!.paginaweb != "")
                              Expanded(
                                  child: Container(
                                alignment: AlignmentDirectional.centerStart,
                                child: TextButton.icon(
                                    onPressed: () async {
                                      String url = widget.compania!.paginaweb!;
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
                                  AsyncSnapshot<List<Telefono?>> snapshot) {
                                /* if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else {*/
                                if (snapshot.hasData) {
                                  if (snapshot.data!.length > 0) {
                                    return Expanded(
                                        child: Container(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: TextButton.icon(
                                          onPressed: () async {
                                            String numero = "+52" +
                                                snapshot
                                                    .data!.first!.numerotelefono
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
                                    AsyncSnapshot<List<Horario?>> snapshot) {
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
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          subtitle: Text(snapshot
                                                  .data!.first!.horainicial! +
                                              " - " +
                                              snapshot.data!.first!.horafinal!),
                                          trailing: IconButton(
                                            icon: Icon(
                                                FontAwesomeIcons.chevronRight),
                                            onPressed: () {
                                              nextScreen(
                                                  context,
                                                  HorarioPage(
                                                      compania:
                                                          widget.compania!));
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
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          subtitle: Text("schedule".tr()),
                                          trailing: IconButton(
                                            icon: Icon(
                                                FontAwesomeIcons.chevronRight),
                                            onPressed: () {
                                              nextScreen(
                                                  context,
                                                  HorarioPage(
                                                      compania:
                                                          widget.compania!));
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
                              borderRadius: BorderRadius.circular(40)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Html(
                                    data: '''${widget.compania!.actividad}''',
                                    shrinkWrap: true,
                                    style: {
                                      "body": Style(
                                        maxLines: 3,
                                        textAlign: TextAlign.justify,
                                        fontSize: FontSize(16.0),
                                        // fontWeight: FontWeight.w500,
                                        //  color: Colors.black,
                                        textOverflow: TextOverflow.ellipsis,
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
                                        borderRadius: BorderRadius.all(
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
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              height: 3,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(40)),
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
                        Row(
                          children: [
                            Expanded(
                              child: _hasData == false
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: 10, bottom: 30),
                                      child: ListView(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        children: [
                                          EmptyPage(
                                              icon: LineIcons.comments,
                                              message: 'no comments found'.tr(),
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
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: _listComentarios.length,
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                SizedBox(
                                          height: 0,
                                        ),
                                        itemBuilder: (_, int index) {
                                          if (index < _listComentarios.length) {
                                            //return reviewList(_listComentarios[index]!, context,_signInBloc);
                                            return Container(
                                                //  padding: EdgeInsets.only(
                                                //      top: 5, bottom: 5),
                                                decoration: BoxDecoration(
                                                  //color: Colors.white,
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
                                                                Colors
                                                                    .grey[200],
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
                                                                      color: Colors
                                                                              .grey[
                                                                          500],
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
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
                                                                minRating:
                                                                    _listComentarios[
                                                                            index]!
                                                                        .rating!,
                                                                maxRating:
                                                                    _listComentarios[
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
                                                                    Colors.blue,
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
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        PopupMenuButton(
                                                            // key: _menuKey,
                                                            itemBuilder: (_) =>
                                                                <
                                                                    PopupMenuItem<
                                                                        String>>[
                                                                  if (_listComentarios[
                                                                              index]!
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
                                                                    ReportarComentarioCompaniaPage(
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                  ),
                                  onPressed: () {
                                    nextScreen(
                                        context,
                                        ComentariosCompaniaPage(
                                            compania: widget.compania!,
                                            collectionName: 'places'));
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

  Hero _sliderImages(BuildContext context, double height, double width) {
    return Hero(
      tag: 'Slider',
      child: Container(
        // color: Colors.white,
        child: Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                // color: Colors.black,
                ),
            child: FutureBuilder(
              future: context
                  .watch<ImagenBloc>()
                  .obtenerImagenesCompania(widget.compania!.idcompania!),
              builder: (context, AsyncSnapshot<List<ImagenCompany?>> snapshot) {
                /*  if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {*/
                if (snapshot.hasData) {
                  if (snapshot.data!.length > 0) {
                    return CarouselSlider.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) =>
                          Container(
                        child: Center(
                            child: Image.network(
                          snapshot.data![itemIndex]!.url!,
                          fit: BoxFit.cover,
                          height: height,
                        )),
                      ),
                      options: CarouselOptions(
                        height: height,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        autoPlay: true,
                      ),
                    );
                  } else {
                    return Image.asset(
                      'assets/images/noimage.jpg',
                      height: height,
                      width: width,
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text("fetch error");
                } else {
                  return CircularProgressIndicator();
                }
                //}
              },
            )),
      ),
    );
  }
}

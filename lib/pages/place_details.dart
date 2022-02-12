import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:translator/translator.dart';
import 'package:traveloaxaca/blocs/actividad_bloc.dart';
import 'package:traveloaxaca/blocs/atractivo_bloc.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/blocs/sitiosinteres_bloc.dart';
import 'package:traveloaxaca/comentario/agregar_comentario.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/pages/lugar/galeria_fotos_lugar.dart';
import 'package:traveloaxaca/comentario/subir_foto.dart';
import 'package:traveloaxaca/models/actividad.dart';
import 'package:traveloaxaca/models/atractivo.dart';
import 'package:traveloaxaca/models/comment.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/sitiosinteres.dart';
import 'package:traveloaxaca/pages/comments.dart';
import 'package:traveloaxaca/pages/guide.dart';
import 'package:traveloaxaca/pages/hotel.dart';
import 'package:traveloaxaca/pages/lugar/comentario.dart';
import 'package:traveloaxaca/pages/restaurant.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/sign_in_dialog.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:readmore/readmore.dart';
import 'package:traveloaxaca/widgets/mas_informacion_lugar.dart';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PlaceDetails extends StatefulWidget {
  final Lugar? data;
  final String? tag;
  const PlaceDetails({Key? key, required this.data, required this.tag})
      : super(key: key);

  @override
  _PlaceDetailsState createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {
  final translator = GoogleTranslator();
  // List<Imagen?> lista = [];
  List<Lugar?> _listalugares = [];
  // List<Categoria?> _listaCategoria = [];
  List<Actividad?> _listaActividad = [];
  List<Atractivo?> _listaAtractivo = [];

  PopularPlacesBloc _con = new PopularPlacesBloc();
  CategoriaBloc _categoriaBloc = new CategoriaBloc();
  ActividadBloc _actividadBloc = new ActividadBloc();
  AtractivoBloc _atractivoBloc = new AtractivoBloc();
  CommentsBloc _commentBloc = new CommentsBloc();
  LoveBloc _loveBloc = new LoveBloc();
  SitiosInteresBloc _sitiosInteresBloc = new SitiosInteresBloc();
  List<SitiosInteres> _sitiosInteres = [];
  int _totalLove = 0;
  bool _marcadoCorazon = false;
  bool isReadmore = false;

  int _totalLoves = 0;
  int _totalComentarios = 0;
  String _textcomentario = "comments".tr();
  String _textVer = "view".tr();
  String _textReviews = "comments".tr();
  bool _marcarCorazon = false;

  bool? _isLoading;
  int _lastVisible = 0;
  bool? _hasData;
  List<Comentario?> _listComentarios = [];
  CommentsBloc _commentsBloc = new CommentsBloc();
  List<Comentario?> _data = [];
  int _idComentarioUltimo = 0;
  bool? _isConnected;
  final BannerAd myBanner = BannerAd(
    adUnitId: Config().idGoogleAds,
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  @override
  void initState() {
    myBanner.load();
    _checkInternetConnection();
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      context.read<LugarBloc>().saerchInitialize();
      obtenerLugaresDentroLugar(widget.data!.idlugar!);
      Provider.of<CommentsBloc>(context, listen: false)
          .totalComentariosLugar(widget.data!.idlugar!);
      Provider.of<LoveBloc>(context, listen: false)
          .principalTotalLoves(widget.data!.idlugar!);
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _categoriaBloc.init(context, refresh);
      _sitiosInteresBloc.init(context, refresh);
      _actividadBloc.init(context, refresh);
      _atractivoBloc.init(context, refresh);
      _loveBloc.init(context, refresh);
    });
    getData();
    getActividadLugar();
    getActractivoLugar();
    marcarCorazonInicial();
    numerosIniciales();
    refresh();
    context.read<LugarBloc>().addToSearchList(widget.data!.idlugar.toString());
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

  Future numerosIniciales() async {
    int totalL = await _loveBloc.obtenerTotalLove(widget.data!.idlugar!);
    int totalC = await _commentBloc
        .obtenerTotalComentariosPorLugar(widget.data!.idlugar!);
    if (mounted) {
      setState(() {
        _totalLoves = totalL;
        _totalComentarios = totalC;
      });
    }
  }

  Future marcarCorazonInicial() async {
    int total = await _loveBloc.obtenerLovePorUsuario(widget.data!.idlugar!);
    if (total > 0) {
      setState(() {
        _marcarCorazon = true;
      });
    }
  }

  void getData() async {
    _sitiosInteres =
        (await _sitiosInteresBloc.getSitiosInteresv2(widget.data!.idlugar!))!;
  }

  void getActividadLugar() async {
    _listaActividad =
        (await _actividadBloc.obtenerActividadLugar(widget.data!.idlugar!));
  }

  void getActractivoLugar() async {
    _listaAtractivo =
        (await _atractivoBloc.obtenerAtractivoLugar(widget.data!.idlugar!));
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void obtenerLugaresDentroLugar(int idlugar) async {
    _listalugares = await _con.obtenerLugaresDentroLugar(idlugar);
    refresh();
  }

  handleDelete(context, Comentario d) {
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
                          await _commentsBloc.eliminarCommentarioLugar(
                              d.idcomentario!, widget.data!.idlugar!);
                      if (resultado!.success!) {
                        //  mostrarAlerta(
                        //      context, 'Eliminado', resultado.message!);
                        Navigator.pop(context);
                        mensajeDialog(context, 'message'.tr(), 'success'.tr());
                        // onRefreshData();
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

  handleLoveClick(BuildContext context) async {
    // final ib = Provider.of<InternetBloc>(context, listen: false);
    final _signInBlocProvider = Provider.of<SignInBloc>(context, listen: false);
    final _signLoveBloc = Provider.of<LoveBloc>(context, listen: false);
    final autenticado = await _signInBlocProvider.isLoggedIn();
    if (autenticado == true) {
      ResponseApi? value = await _loveBloc.agregarLove(widget.data!.idlugar!);
      if (value!.success!) {
        int totalL = await _loveBloc.obtenerTotalLove(widget.data!.idlugar!);
        int totalC = await _commentBloc
            .obtenerTotalComentariosPorLugar(widget.data!.idlugar!);
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
      nextScreen(context, AgregarComentarioPage(lugar: widget.data));
      // }
    } else {
      openSignInDialog(context);
    }
  }

  subirFotosClick() async {
    final _signInBlocProvider = Provider.of<SignInBloc>(context, listen: false);
    //  final ib = Provider.of<InternetBloc>(context, listen: false);
    final autenticado = await _signInBlocProvider.isLoggedIn();
    if (autenticado == true) {
      // await ib.checkInternet();
      // if (ib.hasInternet == false) {
      //   openToast(context, 'no internet'.tr());
      // } else {
      nextScreen(context, SubirFotoComentarioLugar(lugar: widget.data));
      // }
    } else {
      openSignInDialog(context);
    }
  }

  Future<String> someFutureStringFunction(String texto) async {
    var translation = await translator.translate(texto, from: 'es', to: 'en');
    return translation.toString();
  }

  @override
  void dispose() {
    super.dispose();
    myBanner.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final SignInBloc sb = context.watch<SignInBloc>();
    final AdWidget adWidget = AdWidget(ad: myBanner);

    final _loveBlocProvider = Provider.of<LoveBloc>(context, listen: true);
    final _commentBlocProvider =
        Provider.of<CommentsBloc>(context, listen: true);
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final _signInBloc = Provider.of<SignInBloc>(context, listen: true);
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.data!.nombre.toString(),
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [
          IconButton(
            onPressed: () {
              handleLoveClick(context);
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
                  ),
          )
        ],
      ),
      body: (_isConnected == null)
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
                          margin: EdgeInsets.only(left: 25, right: 25, top: 10),
                          child: Text(
                            'are you offline?'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(left: 25, right: 25, top: 10),
                        child: Text(
                          'please check your internet connection and reload the page'
                              .tr(),
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 25, right: 25, top: 10),
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
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          (widget.data!.imagenes!.length > 0)
                              ? _sliderImages(context, height)
                              : _vacioListaImagen(),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20, left: 15, right: 15, bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                    child: Text(
                                  widget.data!.direccion!,
                                  style: Theme.of(context).textTheme.subtitle1,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ],
                            ),
                            Text(
                              widget.data!.nombre!,
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              height: 3,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(40)),
                            ),
                            Row(
                              children: <Widget>[
                                RatingBar.builder(
                                  // ignoreGestures: true,
                                  itemSize: 28,
                                  initialRating: widget.data!.rating!,
                                  ignoreGestures: true,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,

                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 0.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star_border_outlined,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    //_rating = rating;
                                    //print(rating);
                                  },
                                ),
                                Text(
                                  "(" + _totalComentarios.toString() + ")",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  FontAwesomeIcons.heart,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  _totalLoves.toString(),
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            ReadMoreText(
                              widget.data!.descripcion!,
                              trimLines: 4,
                              colorClickableText: Colors.blue,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'read more'.tr(),
                              textAlign: TextAlign.justify,
                              style: TextStyle(fontSize: 16),
                              trimExpandedText: 'read less'.tr(),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('todo',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    )).tr(),
                                Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  margin: EdgeInsets.only(top: 5, bottom: 10),
                                  height: 3,
                                  width: 150,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(40)),
                                ),
                                listaOpciones(lugar: widget.data!),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            if (_listaActividad.length > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 0,
                                      //top: 10,
                                    ),
                                    child: Text(
                                      'activity',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ).tr(),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 8, bottom: 8),
                                    height: 3,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                  ),
                                  Container(
                                    height: 80,
                                    //color: Colors.green,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      itemCount: _listaActividad.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return _chois(_listaActividad[index]);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            if (_listaAtractivo.length > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 0,
                                      // top: 10,
                                    ),
                                    child: Text(
                                      'divertion',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ).tr(),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 8, bottom: 8),
                                    height: 3,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                  ),
                                  Container(
                                    height: 80,
                                    //color: Colors.green,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      itemCount: _listaAtractivo.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return _choisAtractivos(
                                            _listaAtractivo[index]);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            if (_sitiosInteres.length > 0)
                              //Text(_sitiosInteres[0].descripcion.toString())
                              Container(
                                //margin: EdgeInsets.only(right: 100),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 0,
                                        //top: 10,
                                      ),
                                      child: Text(
                                        'attractive turistic',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ).tr(),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 8, bottom: 8),
                                      height: 3,
                                      width: 150,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                    ),
                                    Container(
                                      //height: 260,
                                      //  margin: EdgeInsets.only(right: 55),
                                      // color: Colors.green,

                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                          _sitiosInteres[0]
                                              .descripcion
                                              .toString(),
                                          maxLines: 8,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            fontSize: 16,
                                          )),
                                    ),
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
                                              elevation: 6,

                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                            onPressed: () {
                                              nextScreen(
                                                  context,
                                                  MasInformacionLugarPage(
                                                    lugar: widget.data,
                                                    sitiosinteres:
                                                        _sitiosInteres[0],
                                                  ));
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  child: adWidget,
                                  width: myBanner.size.width.toDouble(),
                                  height: myBanner.size.height.toDouble(),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              height: 3,
                              width: width,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(40)),
                            ),
                            Text('contribute',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                )).tr(),
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
                                    onPressed: () {
                                      subirFotosClick();
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
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
                                      agregarComentarioClick();
                                    },
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            ComentarioDetalleLugarPage(lugar: widget.data!),
                            SizedBox(
                              height: 15,
                            ),
                            if (_totalComentarios >= 7)
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
                                            CommentsPage(
                                              lugar: widget.data!,
                                              collectionName: "places",
                                            ));
                                      },
                                    ),
                                  )
                                ],
                              ),
                            SizedBox(
                              height: 15,
                            ),
                            if (_listalugares.length > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 0,
                                      top: 10,
                                    ),
                                    child: Text(
                                      'you may also like',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ).tr(),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 8, bottom: 8),
                                    height: 3,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                  ),
                                  Container(
                                    height: 220,
                                    //color: Colors.green,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      padding:
                                          EdgeInsets.only(right: 15, top: 5),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _listalugares.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (_listalugares.isEmpty)
                                          return LoadingPopularPlacesCard();
                                        return ItemList(
                                          d: _listalugares[index],
                                        );
                                        //return LoadingCard1();
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
            items: widget.data!.imagenes!
                .toList()
                .map((item) => Container(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => nextScreen(context,
                              GaleriaFotosLugarPage(lugar: widget.data!)),
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

class listaOpciones extends StatelessWidget {
  const listaOpciones({
    Key? key,
    required this.lugar,
  }) : super(key: key);

  final Lugar lugar;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GridView.count(
      padding: EdgeInsets.all(0),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        InkWell(
          child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.blueAccent,
                                offset: Offset(5, 5),
                                blurRadius: 2)
                          ]),
                      child: Icon(
                        LineIcons.mapMarked,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    Text(
                      'ubication',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ).tr(),
                  ])),
          onTap: () => nextScreen(context, GuiaPage(data: lugar)),
        ),
        InkWell(
          child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.orangeAccent,
                                offset: Offset(5, 5),
                                blurRadius: 2)
                          ]),
                      child: Icon(
                        LineIcons.hotel,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    Text(
                      'nearby hotels',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ).tr(),
                  ])),
          onTap: () => nextScreen(
              context,
              HotelPage(
                placeData: lugar,
              )),
        ),
        InkWell(
          child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.pinkAccent,
                                offset: Offset(5, 5),
                                blurRadius: 2)
                          ]),
                      child: Icon(
                        Icons.restaurant_menu,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    Text(
                      'nearby restaurants',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ).tr(),
                  ])),
          onTap: () => nextScreen(
              context,
              RestaurantPage(
                placeData: lugar,
              )),
        ),
        InkWell(
          child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.indigoAccent,
                                offset: Offset(5, 5),
                                blurRadius: 2)
                          ]),
                      child: Icon(
                        LineIcons.comments,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    Text(
                      'user reviews',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ).tr(),
                  ])),
          onTap: () => nextScreen(
              context,
              CommentsPage(
                lugar: lugar,
                collectionName: "places",
              )),
        ),
      ],
    )
        /* child: GridView.builder(
          padding: EdgeInsets.all(5),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            crossAxisCount: 2,
            childAspectRatio: 3.0,
          ),
          physics: NeverScrollableScrollPhysics(),
          itemCount: _listaCategoria.length,
          itemBuilder: (BuildContext ctx, index) {
            if (_listaCategoria.isEmpty) return LoadingPopularPlacesCard();
            //return tarjetas(_listaCategoria[index], context);
            return InkWell(
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 5), // changes position of shadow
                      ),
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.blueAccent,
                                offset: Offset(5, 5),
                                blurRadius: 2)
                          ]),
                      child: Icon(
                        LineIcons.handPointingLeft,
                        size: 30,
                      ),
                    ),
                    Text(
                      _listaCategoria[index]!
                          .nombreclasificacion!
                          .toLowerCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).tr(),
                  ],
                ),
              ),
              onTap: () => nextScreen(
                  context,
                  (_listaCategoria[index]!.nombreclasificacion! == "ubication")
                      ? GuiaPage(data: lugar)
                      : ((_listaCategoria[index]!.nombreclasificacion! ==
                              "hotel"))
                          ? HotelPage(placeData: lugar)
                          : ((_listaCategoria[index]!.nombreclasificacion! ==
                                  "restaurant"))
                              ? RestaurantePage(placeData: lugar)
                              : OtrasOpcionesPage(d: lugar)),
            );
          }),*/
        );
  }
}

Widget _chois(Actividad? item) {
  return InkWell(
    child: Container(
      padding: EdgeInsets.all(5),
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 0),
      child: ChoiceChip(
        elevation: 4,
        pressElevation: 5,
        label: Text(
          item!.nombreactividad!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: false,
        padding: EdgeInsets.all(13),
        labelStyle: TextStyle(color: Colors.white),
        backgroundColor: Colors.blue,
        onSelected: (bool value) {},
      ),
    ),
  );
}

Widget _choisAtractivos(Atractivo? item) {
  return InkWell(
    child: Container(
      padding: EdgeInsets.all(5),
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 0),
      child: ChoiceChip(
        elevation: 5,
        pressElevation: 5,
        label: Text(
          item!.nombreatractivo!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: false,
        padding: EdgeInsets.all(13),
        labelStyle: TextStyle(color: Colors.white),
        backgroundColor: Colors.blue,
        onSelected: (bool value) {},
      ),
    ),
  );
}

Widget _buildPlayerModelList(SitiosInteres items) {
  return Card(
    //margin: EdgeInsets.all(10),
    child: ExpansionTile(
      /* leading: Icon(
        Icons.verified_user,
        color: Colors.grey,
      ),*/
      title: Text(
        items.nombre!,
        style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
      ),
      children: <Widget>[
        ListTile(
          title: Text(
            items.descripcion!,
            textAlign: TextAlign.justify,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        )
      ],
    ),
  );
}

class ItemList extends StatelessWidget {
  final Lugar? d;
  const ItemList({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
        width: MediaQuery.of(context).size.width * 0.35,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Hero(
              tag: d!.idlugar.toString(),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (d!.primeraimagen != null)
                      ? CustomCacheImage(imageUrl: d!.primeraimagen!)
                      : Image.asset(
                          "assets/images/no-image.jpg",
                        )),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                child: Text(
                  d!.nombre!,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    right: 15,
                  ),
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LineIcons.heart, size: 16, color: Colors.white),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          d!.love.toString(),
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
      onTap: () => nextScreen(context, PlaceDetails(data: d, tag: 'others')),
    );
  }
}

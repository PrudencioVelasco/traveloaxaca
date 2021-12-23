import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:line_icons/line_icons.dart';
import 'package:translator/translator.dart';
import 'package:traveloaxaca/blocs/actividad_bloc.dart';
import 'package:traveloaxaca/blocs/atractivo_bloc.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/blocs/sitiosinteres_bloc.dart';
import 'package:traveloaxaca/comentario/agregar_comentario.dart';
import 'package:traveloaxaca/models/actividad.dart';
import 'package:traveloaxaca/models/atractivo.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:traveloaxaca/models/imagen.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/sitiosinteres.dart';
import 'package:traveloaxaca/pages/comments.dart';
import 'package:traveloaxaca/pages/guide.dart';
import 'package:traveloaxaca/pages/hotel.dart';
import 'package:traveloaxaca/pages/restaurante.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/sign_in_dialog.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:readmore/readmore.dart';
import 'package:traveloaxaca/widgets/mas_informacion_lugar.dart';

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
  List<Imagen?> lista = [];
  List<Lugar?> _listalugares = [];
  List<Categoria?> _listaCategoria = [];
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
  String _textlove = "love".tr();
  String _textcomentario = "comments".tr();
  String _textVer = "view".tr();
  String _textReviews = "comments".tr();
  bool _marcarCorazon = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
      context.read<LugarBloc>().saerchInitialize();
      getAllImages(widget.data!.idlugar!);
      getAllCategorias(widget.data!.idlugar!);
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
    //totalLove();
    //totalComment();
    marcarCorazonInicial();
    numerosIniciales();
    refresh();
    context.read<LugarBloc>().addToSearchList(widget.data!.idlugar.toString());
  }

  void totalLove() async {
    await _loveBloc.principalTotalLoves(widget.data!.idlugar!);
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

  void totalComment() async {
    await _commentBloc.totalComentariosLugar(widget.data!.idlugar!);
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

  void getAllImages(int idlugar) async {
    lista = await _con.obtenerImagenesLugar(idlugar);
    refresh();
  }

  void obtenerLugaresDentroLugar(int idlugar) async {
    _listalugares = await _con.obtenerLugaresDentroLugar(idlugar);
    refresh();
  }

  void getAllCategorias(int idlugar) async {
    _listaCategoria = (await _categoriaBloc.obtenercategoriasPorLugar(idlugar));
    refresh();
  }

  handleLoveClick() async {
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
      nextScreen(
          context,
          CommentsPage(
            lugar: widget.data!,
            collectionName: "places",
          ));
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
  Widget build(BuildContext context) {
    // final SignInBloc sb = context.watch<SignInBloc>();
    final _loveBlocProvider = Provider.of<LoveBloc>(context, listen: true);
    final _commentBlocProvider =
        Provider.of<CommentsBloc>(context, listen: true);
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      //backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                _sliderImages(context, height),
                Positioned(
                  top: 20,
                  left: 15,
                  child: SafeArea(
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.9),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_left,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton.icon(
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
                              ),
                        label: (_marcarCorazon)
                            ? Text(
                                "like",
                                style: TextStyle(color: Colors.red),
                              ).tr()
                            : Text(
                                "like",
                                style: Theme.of(context).textTheme.subtitle1,
                              ).tr(),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          nextScreen(
                              context,
                              CommentsPage(
                                lugar: widget.data!,
                                collectionName: "places",
                              ));
                        },
                        icon: Icon(
                          FontAwesomeIcons.comment,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        label: Text(
                            _totalComentarios.toString() +
                                " " +
                                _textcomentario,
                            style: Theme.of(context).textTheme.subtitle1),
                      ),
                    ],
                  ),
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
                      Text(
                        _totalLoves.toString(),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        FontAwesomeIcons.heart,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        _totalComentarios.toString(),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        FontAwesomeIcons.comments,
                        color: Colors.blue[300],
                        size: 20,
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
                      listaOpciones(
                          listaCategoria: _listaCategoria, lugar: widget.data!),
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
                              borderRadius: BorderRadius.circular(40)),
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
                            itemBuilder: (BuildContext context, int index) {
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
                              borderRadius: BorderRadius.circular(40)),
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
                            itemBuilder: (BuildContext context, int index) {
                              return _choisAtractivos(_listaAtractivo[index]);
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            margin: EdgeInsets.only(top: 8, bottom: 8),
                            height: 3,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(40)),
                          ),
                          Container(
                            //height: 260,
                            //  margin: EdgeInsets.only(right: 55),
                            // color: Colors.green,

                            width: MediaQuery.of(context).size.width,
                            child: Html(
                              data: '''${_sitiosInteres[0].descripcion}''',
                              shrinkWrap: true,
                              style: {
                                "body": Style(
                                  maxLines: 4,
                                  textAlign: TextAlign.justify,
                                  fontSize: FontSize(16.0),
                                  // fontWeight: FontWeight.w500,
                                  // color: Colors.black,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                              },
                            ),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                  ),
                                  onPressed: () {
                                    nextScreen(
                                        context,
                                        MasInformacionLugarPage(
                                          lugar: widget.data,
                                          sitiosinteres: _sitiosInteres[0],
                                        ));
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                  /*(_sitiosInteres.length > 0)
                      ? Container(
                          //margin: EdgeInsets.only(right: 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    fontSize: 17,
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
                                    borderRadius: BorderRadius.circular(40)),
                              ),
                              Container(
                                //height: 260,
                                //  margin: EdgeInsets.only(right: 55),
                                // color: Colors.green,

                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  // padding: EdgeInsets.only(right: 15, top: 5),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: _sitiosInteres.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _buildPlayerModelList(
                                        _sitiosInteres[index]);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(''),*/

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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                          onPressed: () {},
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                          onPressed: () {
                            nextScreen(context,
                                AgregarComentarioPage(lugar: widget.data));
                          },
                        ),
                      )
                    ],
                  ),
                  /* Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            label: Text("Subir foto"),
                            icon: Icon(Icons.add_a_photo_rounded),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.teal,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                              shadowColor: Colors.grey,
                              padding: EdgeInsets.all(10.0),
                              elevation: 8,
                              shape: BeveledRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            onPressed: () {},
                          ),
                          ElevatedButton.icon(
                            label: Text('Escriba una opinion'),
                            icon: Icon(Icons.add_comment_rounded),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.teal,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                              shadowColor: Colors.grey,
                              padding: EdgeInsets.all(10.0),
                              elevation: 8,
                              shape: BeveledRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            onPressed: () {
                              nextScreen(context,
                                  AgregarComentarioPage(lugar: widget.data));
                            },
                          ),
                        ],
                      )
                    ],
                  ),*/
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
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        Container(
                          height: 220,
                          //color: Colors.green,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            padding: EdgeInsets.only(right: 15, top: 5),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: _listalugares.length,
                            itemBuilder: (BuildContext context, int index) {
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

  /*Widget buildText(String text) {
    // if read more is false then show only 3 lines from text
    // else show full text
    final lines = isReadmore ? null : 8;
    return Text(
      text,
      style: TextStyle(fontSize: 16),
      maxLines: lines,
      textAlign: TextAlign.justify,
      // overflow properties is used to show 3 dot in text widget
      // so that user can understand there are few more line to read.
      overflow: isReadmore ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }*/

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
            items: lista
                .map((item) => Container(
                      child: Center(
                          child: Image.network(
                        item!.nombre!,
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

class listaOpciones extends StatelessWidget {
  const listaOpciones({
    Key? key,
    required List<Categoria?> listaCategoria,
    required this.lugar,
  })  : _listaCategoria = listaCategoria,
        super(key: key);

  final List<Categoria?> _listaCategoria;
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
                      'travel guide',
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
              RestaurantePage(
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

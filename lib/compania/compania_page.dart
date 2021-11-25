import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:line_icons/line_icons.dart';
import 'package:translator/translator.dart';
import 'package:traveloaxaca/blocs/actividad_bloc.dart';
import 'package:traveloaxaca/blocs/atractivo_bloc.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/blocs/sitiosinteres_bloc.dart';
import 'package:traveloaxaca/comentario/agregar_comentario.dart';
import 'package:traveloaxaca/models/actividad.dart';
import 'package:traveloaxaca/models/atractivo.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/models/icon_data.dart';
import 'package:traveloaxaca/models/imagen.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:traveloaxaca/models/sitiosinteres.dart';
import 'package:traveloaxaca/pages/comments.dart';
import 'package:traveloaxaca/pages/guide.dart';
import 'package:traveloaxaca/pages/hotel.dart';
import 'package:traveloaxaca/pages/otras_opciones.dart';
import 'package:traveloaxaca/pages/restaurante.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/sign_in_dialog.dart';
import 'package:traveloaxaca/widgets/comment_count.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';
import 'package:traveloaxaca/widgets/love_count.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:readmore/readmore.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:html/parser.dart';
import 'package:traveloaxaca/widgets/mas_informacion_lugar.dart';
import 'package:flutter_translate/flutter_translate.dart';

class CompanyPage extends StatefulWidget {
  final int? idcategoria;
  const CompanyPage({Key? key, required this.idcategoria}) : super(key: key);

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final translator = GoogleTranslator();
  List<Imagen?> lista = [];
  List<Categoria?> _listaCategoria = [];
  Compania? _companias;
  PopularPlacesBloc _con = new PopularPlacesBloc();
  CategoriaBloc _categoriaBloc = new CategoriaBloc();
  ActividadBloc _actividadBloc = new ActividadBloc();
  AtractivoBloc _atractivoBloc = new AtractivoBloc();
  CommentsBloc _commentBloc = new CommentsBloc();
  CompaniaBloc _companiaBloc = new CompaniaBloc();
  LoveBloc _loveBloc = new LoveBloc();
  SitiosInteresBloc _sitiosInteresBloc = new SitiosInteresBloc();
  List<SitiosInteres> _sitiosInteres = [];
  int _totalLove = 0;
  bool _marcadoCorazon = false;
  bool isReadmore = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
      getAllCompanias();
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _categoriaBloc.init(context, refresh);
      _sitiosInteresBloc.init(context, refresh);
      _actividadBloc.init(context, refresh);
      _atractivoBloc.init(context, refresh);
      _loveBloc.init(context, refresh);
      _commentBloc.init(context, refresh);
    });
    validarMarcadoCorazon();
    refresh();
  }

  void validarMarcadoCorazon() async {
    int lovePorUsuario = 0;
    if (lovePorUsuario > 0) {
      _marcadoCorazon = true;
    } else {
      _marcadoCorazon = false;
    }
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void getAllCompanias() async {
    _companias =
        (await _companiaBloc.obtenerCompaniaClasificacion(widget.idcategoria!));
    refresh();
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
      backgroundColor: Colors.white,
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
                          //handleLoveClick();
                        },
                        icon: (_loveBlocProvider.mostrarMarcadoCorazon)
                            ? LoveIcon().bold
                            : LoveIcon().normal,
                        label: (_loveBlocProvider.mostrarMarcadoCorazon)
                            ? Text(
                                "like",
                                style: TextStyle(color: Colors.red),
                              ).tr()
                            : Text(
                                "like",
                                style: TextStyle(color: Colors.grey[600]),
                              ).tr(),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // agregarComentarioClick();
                        },
                        icon: Icon(
                          FontAwesomeIcons.comment,
                          color: Colors.grey[600],
                        ),
                        label: CommentCount(
                          idLugar: widget.idcategoria!,
                          parametro: 1,
                        ),
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
                        'test',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                  Text('nombre',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[800])),
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
                      CommentCount(
                        idLugar: 3,
                        parametro: 0,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        FontAwesomeIcons.comments,
                        color: Colors.blue[300],
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      LoveCount(idlugar: 11),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        FontAwesomeIcons.heart,
                        color: Colors.red,
                        size: 20,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  ReadMoreText(
                    'test',
                    // convertir(widget.data!.descripcion!),
                    // widget.data!.descripcion!,
                    trimLines: 4,
                    colorClickableText: Colors.blue,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'read more'.tr(),
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16),
                    trimExpandedText: 'read less'.tr(),
                  ),
                  SizedBox(
                    height: 15,
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
                                  color: Colors.black,
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
                                    /*nextScreen(
                                        context,
                                        MasInformacionLugarPage(
                                          lugar: widget.data,
                                          sitiosinteres: _sitiosInteres[0],
                                        ));*/
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    height: 3,
                    width: width,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
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
                            elevation: 6,

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
                          label: Text('write a review').tr(),
                          icon: Icon(Icons.add_comment_rounded),
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
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                          onPressed: () {
                            /*  nextScreen(context,
                                AgregarComentarioPage(lugar: widget.data));*/
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

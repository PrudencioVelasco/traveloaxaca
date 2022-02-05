import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_collapse/gallery_item.dart';
import 'package:image_collapse/gallery_view_wrapper.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/models/comentario_tour.dart';
import 'package:traveloaxaca/models/comment.dart';
import 'package:traveloaxaca/models/imagen_comentario_tour.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/tour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/pages/tour/agregar_reporte.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class TourComentarioPage extends StatefulWidget {
  final Tour tour;
  TourComentarioPage({Key? key, required this.tour}) : super(key: key);

  @override
  _TourComentarioPageState createState() => _TourComentarioPageState();
}

class _TourComentarioPageState extends State<TourComentarioPage> {
  bool? _hasData;
  List<ComentarioTour?> _listComentarios = [];
  CommentsBloc _commentsBloc = new CommentsBloc();
  bool? _isLoading;
  int _lastVisible = 0;
  int _totalComentarios = 0;
  static final List<GalleryItem> _galleryItems = <GalleryItem>[];
  String? titleGallery;
  Color? appBarColor;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _getData();
    refresh();
  }

  Future _getData() async {
    setState(() => _hasData = true);
    if (_lastVisible == 0) {
      _listComentarios = (await _commentsBloc.obtenerComentariosTour(
          widget.tour.idtour!, 0, 5));
    }
    if (_listComentarios.isNotEmpty && _listComentarios.length > 0) {
      int total = (await _commentsBloc.obtenerComentariosTour(
              widget.tour.idtour!, 0, 0))
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
                  var verificarConeccion = await ib.checarInternar();
                  if (verificarConeccion == false) {
                    Navigator.of(context, rootNavigator: true).pop();
                    mensajeDialog(context, 'message'.tr(), 'no internet'.tr());
                  } else {
                    if (sb.idusuario != d.idusuario) {
                      Navigator.of(context, rootNavigator: true).pop();
                      mensajeDialog(context, 'message'.tr(),
                          'You can not delete others comment'.tr());
                    } else {
                      final _commentsBloc =
                          Provider.of<CommentsBloc>(context, listen: false);
                      ResponseApi? resultado = await _commentsBloc
                          .eliminarCommentarioTour(d.idcomentario!);
                      if (resultado!.success!) {
                        onRefreshData();
                        Navigator.of(context, rootNavigator: true).pop();
                        mensajeDialog(context, 'message'.tr(), 'success'.tr());
                      } else {
                        Navigator.of(context, rootNavigator: true).pop();
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
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
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
    final _signInBloc = Provider.of<SignInBloc>(context, listen: true);
    return Row(
      children: [
        Expanded(
          child: _hasData == false
              ? Container(
                  margin: EdgeInsets.only(top: 10, bottom: 30),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      EmptyPage(
                          icon: LineIcons.comments,
                          message: 'no comments found'.tr(),
                          message1: 'be the first to comment'.tr()),
                    ],
                  ),
                )
              : Container(
                  child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      padding: EdgeInsets.all(5),
                      // controller: _scrollViewController,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _listComentarios.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(
                            height: 0,
                          ),
                      itemBuilder: (_, int index) {
                        return Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              // color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                    width: 1, color: Colors.grey.shade300),
                              ),
                              //  borderRadius: BorderRadius.circular(5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: (_listComentarios[index]!
                                          .imageUrl!
                                          .isEmpty)
                                      ? Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.person, size: 28),
                                        )
                                      : CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  _listComentarios[index]!
                                                      .imageUrl!),
                                        ),
                                  title: Text(
                                    _listComentarios[index]!.userName!,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                      _listComentarios[index]!.fecha.toString(),
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      PopupMenuButton(
                                          // key: _menuKey,
                                          itemBuilder: (_) =>
                                              <PopupMenuItem<String>>[
                                                PopupMenuItem<String>(
                                                    child: Text('report?'.tr()),
                                                    value: 'reportar'),
                                                if (_listComentarios[index]!
                                                        .idusuario ==
                                                    _signInBloc.idusuario)
                                                  PopupMenuItem<String>(
                                                      child:
                                                          Text('delete?'.tr()),
                                                      value: 'eliminar'),
                                              ],
                                          onSelected: (valor) {
                                            print(valor);
                                            if (valor == "reportar") {
                                              nextScreen(
                                                  context,
                                                  ReportarComentarioTourPage(
                                                      comentario:
                                                          _listComentarios[
                                                              index]!));
                                            }
                                            if (valor == "eliminar") {
                                              handleDelete(context,
                                                  _listComentarios[index]!);
                                            }
                                          }),
                                    ],
                                  ),
                                ),
                                Container(
                                  //alignment: MainAxisAlignment.start,
                                  //color: Colors.red,
                                  child: RatingBar.builder(
                                    // ignoreGestures: true,
                                    itemSize: 28,
                                    initialRating:
                                        _listComentarios[index]!.rating!,
                                    minRating: _listComentarios[index]!.rating!,
                                    maxRating: _listComentarios[index]!.rating!,
                                    ignoreGestures: true,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    //itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
                                ReadMoreText(
                                  _listComentarios[index]!.comentario!,
                                  trimLines: 4,
                                  colorClickableText: Colors.blue,
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: 'read more'.tr(),
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(fontSize: 16),
                                  trimExpandedText: 'read less'.tr(),
                                ),
                                if (_listComentarios[index]!.imagenes!.length >
                                    0)
                                  GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 2,
                                        crossAxisCount: 3,
                                      ),
                                      scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _listComentarios[index]!
                                          .imagenes!
                                          .length,
                                      itemBuilder: (context, index2) {
                                        return GestureDetector(
                                          onTap: () => openImageFullScreen(
                                              context, index, index2),
                                          child: Container(
                                            child: CachedNetworkImage(
                                              imageUrl: (_listComentarios[
                                                              index]!
                                                          .imagenes![index2]
                                                          .imagenurl! !=
                                                      '')
                                                  ? _listComentarios[index]!
                                                      .imagenes![index2]
                                                      .imagenurl!
                                                  : "https://misicebucket.s3.us-east-2.amazonaws.com/no-image-verical.jpg",
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Center(
                                                child: SizedBox(
                                                  child:
                                                      CircularProgressIndicator(),
                                                  height: 50.0,
                                                  width: 50.0,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        );
                                      }),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
        ),
      ],
    );
  }

  void openImageFullScreen(context, int index, int indeximagen) {
    List<ImagenComentarioTour>? gallery = _listComentarios[index]!.imagenes;
    _galleryItems.clear();
    gallery!.forEach((imageUrl) {
      _galleryItems.add(
        GalleryItem(
          id: imageUrl.idimagencomentariotour.toString(),
          imageUrl: imageUrl.imagenurl.toString(),
        ),
      );
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return GalleryViewWrapper(
          appBarColor: appBarColor,
          titleGallery: "photos".tr(),
          galleryItem: _galleryItems,
          backgroundDecoration: BoxDecoration(color: Color(0xff374056)),
          initialIndex: indeximagen,
          scrollDirection: Axis.horizontal,
        );
      }),
    );
  }
}
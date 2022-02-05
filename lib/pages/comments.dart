import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_collapse/gallery_item.dart';
import 'package:image_collapse/gallery_view_wrapper.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/comentario/agregar_comentario.dart';
import 'package:traveloaxaca/comentario/reportar_comentario_lugar.dart';
import 'package:traveloaxaca/models/comment.dart';
import 'package:traveloaxaca/models/imagen_comentario_lugar.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/sign_in_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class CommentsPage extends StatefulWidget {
  final Lugar lugar;
  final String collectionName;
  const CommentsPage(
      {Key? key, required this.lugar, required this.collectionName})
      : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  ScrollController? controller;
  ScrollController? _scrollComentarios;
  CommentsBloc _commentsBloc = new CommentsBloc();
  int _lastVisible = 0;
  int _idComentarioUltimo = 0;
  bool? _isLoading;
  List<Comentario?> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var textCtrl = TextEditingController();
  bool? _hasData;
  List<Comentario?> _listComentarios = [];
  final GlobalKey _menuKey = GlobalKey();
  InternetBloc _internetBloc = new InternetBloc();
  static final List<GalleryItem> _galleryItems = <GalleryItem>[];
  String? titleGallery;
  Color? appBarColor;
  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _commentsBloc.init(context, refresh);
    });
    _isLoading = true;
    _getData();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future _getData() async {
    setState(() => _hasData = true);
    //QuerySnapshot data;
    if (_lastVisible == 0) {
//_listComentarios
      _listComentarios = (await _commentsBloc.obtenerComentariosLugar(
          widget.lugar.idlugar!, 0, 15));
    } else {
      // data = await firestore
      _data = (await _commentsBloc.obtenerComentariosLugar(
          widget.lugar.idlugar!, _idComentarioUltimo, 15));
      //_listComentarios.add(_data);
      _data.forEach((element) {
        _listComentarios.add(element);
      });
    }
    if (_listComentarios.isNotEmpty && _listComentarios.length > 0) {
      if (_listComentarios.length >= 15) {
        _idComentarioUltimo = _listComentarios.last!.idcomentario!;
        _lastVisible = 1;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (_lastVisible == 0) {
        setState(() {
          _isLoading = false;
          _hasData = false;
          print('no items');
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasData = true;
          print('no more items');
        });
      }
    }
    return null;
  }

  @override
  void dispose() {
    controller?.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading!) {
      if (controller?.position.pixels == controller?.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
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
                      ResponseApi? resultado =
                          await _commentsBloc.eliminarCommentarioLugar(
                              d.idcomentario!, widget.lugar.idlugar!);
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
    final double width = MediaQuery.of(context).size.width;
    final _signInBloc = Provider.of<SignInBloc>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.lugar.nombre.toString(),
          style: Theme.of(context).textTheme.headline6,
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
              icon: Icon(
                Icons.refresh,
                size: 22,
              ),
              onPressed: () => onRefreshData())
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              child: _hasData == false
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                        ),
                        EmptyPage(
                            icon: LineIcons.comments,
                            message: 'no comments found'.tr(),
                            message1: 'be the first to comment'.tr()),
                      ],
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(5),
                      controller: controller,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _listComentarios.length != 0
                          ? _listComentarios.length + 1
                          : 10,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(
                        height: 0,
                      ),
                      itemBuilder: (_, int index) {
                        if (index < _listComentarios.length) {
                          //return reviewList(_listComentarios[index]!, context,_signInBloc);
                          return Container(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Colors.grey.shade300),
                                ),
                                //  borderRadius: BorderRadius.circular(5)),
                              ),
                              child: ListTile(
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
                                                      .imageUrl!)),
                                  title: Column(
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: [
                                            Text(
                                              _listComentarios[index]!
                                                  .userName!,
                                              style: TextStyle(
                                                  //color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                                _listComentarios[index]!
                                                    .fecha
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            //alignment: MainAxisAlignment.start,
                                            //color: Colors.red,
                                            child: RatingBar.builder(
                                              // ignoreGestures: true,
                                              itemSize: 20,
                                              initialRating:
                                                  _listComentarios[index]!
                                                      .rating!,
                                              minRating:
                                                  _listComentarios[index]!
                                                      .rating!,
                                              maxRating:
                                                  _listComentarios[index]!
                                                      .rating!,
                                              ignoreGestures: true,
                                              direction: Axis.horizontal,
                                              allowHalfRating: false,
                                              itemCount: 5,
                                              //itemPadding: EdgeInsets.symmetric(
                                              //    horizontal: 4.0),
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
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ReadMoreText(
                                              _listComentarios[index]!
                                                  .comentario!,
                                              trimLines: 4,
                                              colorClickableText: Colors.blue,
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText:
                                                  'read more'.tr(),
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(fontSize: 16),
                                              trimExpandedText:
                                                  'read less'.tr(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_listComentarios[index]!
                                              .imagenes!
                                              .length >
                                          0)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GridView.builder(
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisSpacing: 5,
                                                    mainAxisSpacing: 2,
                                                    crossAxisCount: 3,
                                                  ),
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      _listComentarios[index]!
                                                          .imagenes!
                                                          .length,
                                                  itemBuilder:
                                                      (context, index2) {
                                                    return GestureDetector(
                                                      onTap: () =>
                                                          openImageFullScreen(
                                                              context,
                                                              index,
                                                              index2),
                                                      child: Container(
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: (_listComentarios[
                                                                          index]!
                                                                      .imagenes![
                                                                          index2]
                                                                      .imagenurl! !=
                                                                  '')
                                                              ? _listComentarios[
                                                                      index]!
                                                                  .imagenes![
                                                                      index2]
                                                                  .imagenurl!
                                                              : "https://misicebucket.s3.us-east-2.amazonaws.com/no-image-verical.jpg",
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          placeholder:
                                                              (context, url) =>
                                                                  Center(
                                                            child: SizedBox(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                              height: 50.0,
                                                              width: 50.0,
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                                  ReportarComentarioLugarPage(
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
                                      child: new CupertinoActivityIndicator()),
                                ),
                        );
                      },
                    ),
              onRefresh: () async {
                onRefreshData();
              },
            ),
          ),
          Divider(
            height: 1,
            color: Colors.black26,
          ),
          SafeArea(
            child: Container(
              height: 65,
              padding: EdgeInsets.only(top: 8, bottom: 10, right: 20, left: 20),
              margin: EdgeInsets.only(bottom: 10),
              width: double.infinity,
              // color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25)),
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
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                  onPressed: () async {
                    final _signInBlocProvider =
                        Provider.of<SignInBloc>(context, listen: false);
                    final autenticado = await _signInBlocProvider.isLoggedIn();
                    if (autenticado == true) {
                      nextScreen(
                          context, AgregarComentarioPage(lugar: widget.lugar));
                    } else {
                      openSignInDialog(context);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void openImageFullScreen(context, int index, int indeximagen) {
    List<ImagenComentarioLugar>? gallery = _listComentarios[index]!.imagenes;
    _galleryItems.clear();
    gallery!.forEach((imageUrl) {
      _galleryItems.add(
        GalleryItem(
          id: imageUrl.idimagencomentariolugar.toString(),
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
// (_signInBloc.idusuario == d.idusuario) ??

}

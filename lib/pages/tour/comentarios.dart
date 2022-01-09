import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/models/comentario_tour.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/tour.dart';
import 'package:traveloaxaca/pages/tour/agregar_comentario.dart';
import 'package:traveloaxaca/pages/tour/agregar_reporte.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/sign_in_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class ComentariosTourPage extends StatefulWidget {
  final Tour tour;
  final String collectionName;
  const ComentariosTourPage(
      {Key? key, required this.tour, required this.collectionName})
      : super(key: key);

  @override
  _ComentariosTourPageState createState() => _ComentariosTourPageState();
}

class _ComentariosTourPageState extends State<ComentariosTourPage> {
  //final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController? controller;
  CommentsBloc _commentsBloc = new CommentsBloc();
  //DocumentSnapshot? _lastVisible;
  int _lastVisible = 0;
  int _idComentarioUltimo = 0;
  bool? _isLoading;
  List<ComentarioTour?> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var textCtrl = TextEditingController();
  bool? _hasData;
  List<ComentarioTour?> _listComentarios = [];
  final GlobalKey _menuKey = GlobalKey();
  InternetBloc _internetBloc = new InternetBloc();
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
      _listComentarios = (await _commentsBloc.obtenerComentariosTour(
          widget.tour.idtour!, 0, 7));
    } else {
      // data = await firestore
      _data = (await _commentsBloc.obtenerComentariosTour(
          widget.tour.idtour!, _idComentarioUltimo, 7));
      //_listComentarios.add(_data);
      _data.forEach((element) {
        _listComentarios.add(element);
      });
    }
    if (_listComentarios.isNotEmpty && _listComentarios.length > 0) {
      if (_listComentarios.length >= 7) {
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
                      ResponseApi? resultado = await _commentsBloc
                          .eliminarCommentarioTour(d.idcomentario!);
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

  Future handleSubmit() async {
    final ib = Provider.of<InternetBloc>(context, listen: false);
    final _commentBloc = Provider.of<CommentsBloc>(context, listen: false);
    final SignInBloc sb = context.read<SignInBloc>();
    if (!sb.autenticando) {
      openSignInDialog(context);
    } else {
      await ib.checkInternet();
      if (textCtrl.text == '' || textCtrl.text.isEmpty) {
        print('Comment is empty');
      } else {
        if (ib.hasInternet == false) {
          mostrarAlerta(context, 'Internet', 'No tiene conexion a Internet.');
        } else {
          ResponseApi? resultado = await _commentBloc.agregarCommentario(
              widget.tour.idtour!, textCtrl.text);
          if (resultado!.success! == true) {
            onRefreshData();
            textCtrl.clear();
            FocusScope.of(context).requestFocus(new FocusNode());
          } else {
            mostrarAlerta(context, 'Registro incorrecto', resultado.message!);
          }
        }
      }
    }
  }
  // }

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
                widget.collectionName == 'places' ? 'user reviews' : 'comments',
                style: Theme.of(context).textTheme.headline6)
            .tr(),
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
                                                  //   color: Colors.black,
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
                                                    fontSize: 10,
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
                                              itemPadding: EdgeInsets.symmetric(
                                                  horizontal: 4.0),
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
                                            /*  Text(
                                                _listComentarios[index]!
                                                    .comentario!,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500),
                                              ),*/
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
                                                child: GridView.count(
                                              crossAxisCount: 3,
                                              shrinkWrap: true,
                                              children: List.generate(
                                                  _listComentarios[index]!
                                                      .imagenes!
                                                      .length, (index2) {
                                                return CachedNetworkImage(
                                                  imageUrl:
                                                      _listComentarios[index]!
                                                          .imagenes![index2]
                                                          .imagenurl!,
                                                  imageBuilder: (context,
                                                          imageProvider) =>
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
                                                  width: 300,
                                                  height: 300,
                                                );
                                              }),
                                            )),
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
                                                if (_listComentarios[index]!
                                                        .idusuario ==
                                                    _signInBloc.idusuario)
                                                  PopupMenuItem<String>(
                                                      child:
                                                          Text('delete?'.tr()),
                                                      value: 'eliminar'),
                                                PopupMenuItem<String>(
                                                    child: Text('report?'.tr()),
                                                    value: 'reportar'),
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
              width: double.infinity,
              //  color: Colors.white,
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
                      nextScreen(context,
                          AgregarComentarioTourPage(tour: widget.tour));
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

// (_signInBloc.idusuario == d.idusuario) ??

}

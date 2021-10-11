import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/models/comment.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:traveloaxaca/utils/sign_in_dialog.dart';
import 'package:traveloaxaca/utils/toast.dart';
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
  //final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController? controller;
  CommentsBloc _commentsBloc = new CommentsBloc();
  //DocumentSnapshot? _lastVisible;
  int _lastVisible = 0;
  int _idComentarioUltimo = 0;
  bool? _isLoading;
  List<Comentario?> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var textCtrl = TextEditingController();
  bool? _hasData;
  List<Comentario?> _listComentarios = [];
  InternetBloc _internetBloc = new InternetBloc();
  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _commentsBloc.init(context, refresh);
      _internetBloc.init(context);
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
      _listComentarios = (await _commentsBloc.obtenerComentariosPorLugar(
          widget.lugar.idlugar!, 0, 7));
    } else {
      // data = await firestore
      _data = (await _commentsBloc.obtenerComentariosPorLugar(
          widget.lugar.idlugar!, _idComentarioUltimo, 7));
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
          //_snap.addAll(data.docs);
          //_data = _snap.map((e) => Comment.fromFirestore(e)).toList();
          //print('blog reviews : ${_data.length}');
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
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              Text('delete?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w900))
                  .tr(),
              SizedBox(
                height: 10,
              ),
              Text('delete from database?',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w700))
                  .tr(),
              SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'yes',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ).tr(),
                      onPressed: () async {
                        await ib.checkInternet();
                        if (ib.hasInternet == false) {
                          Navigator.pop(context);
                          mostrarAlerta(context, 'Internet',
                              'No tienes conexion a internet.');
                        } else {
                          if (sb.idusuario != d.idusuario) {
                            Navigator.pop(context);
                            openToast(
                                context, 'You can not delete others comment');
                          } else {
                            final _commentsBloc = Provider.of<CommentsBloc>(
                                context,
                                listen: false);
                            ResponseApi? resultado =
                                await _commentsBloc.eliminarCommentario(
                                    d.idcomentario!, widget.lugar.idlugar!);
                            if (resultado!.success!) {
                              mostrarAlerta(
                                  context, 'Eliminado', resultado.message!);
                              onRefreshData();
                              Navigator.pop(context);
                            } else {
                              mostrarAlerta(context, 'Registro incorrecto',
                                  resultado.message!);
                            }
                          }
                        }
                      }),
                  SizedBox(width: 10),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'no',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ).tr(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ))
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
              widget.lugar.idlugar!, textCtrl.text);
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
                widget.collectionName == 'places' ? 'user reviews' : 'comments')
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
                        height: 10,
                      ),
                      itemBuilder: (_, int index) {
                        if (index < _listComentarios.length) {
                          return reviewList(_listComentarios[index]!, context);
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
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25)),
                child: TextFormField(
                  decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: 0),
                      contentPadding:
                          EdgeInsets.only(left: 15, top: 10, right: 5),
                      border: InputBorder.none,
                      hintText: widget.collectionName == 'places'
                          ? 'write a review'.tr()
                          : 'write a comment'.tr(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        onPressed: () {
                          handleSubmit();
                        },
                      )),
                  controller: textCtrl,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget reviewList(Comentario d, BuildContext context) {
    final _signInBloc = Provider.of<SignInBloc>(context, listen: true);
    return Container(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          leading: (d.imageUrl!.isEmpty)
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
                  backgroundImage: CachedNetworkImageProvider(d.imageUrl!)),
          title: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: [
                    Text(
                      d.userName!,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(d.fecha.toString(),
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Text(
                d.comentario!,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_signInBloc.idusuario == d.idusuario)
                IconButton(
                  onPressed: () {
                    handleDelete(context, d);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                )
            ],
          ),
          /* onTap: () {
            print('object');
            handleDelete(context, d);
          },
          onLongPress: () {
            print('Eliminando');
            handleDelete(context, d);
          },*/
        ));
  }
}

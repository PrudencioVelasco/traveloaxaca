import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:traveloaxaca/utils/snacbar.dart';

class SubirFotoComentarioLugar extends StatefulWidget {
  final Lugar? lugar;
  SubirFotoComentarioLugar({Key? key, required this.lugar}) : super(key: key);

  @override
  _SubirFotoComentarioLugarState createState() =>
      _SubirFotoComentarioLugarState();
}

class _SubirFotoComentarioLugarState extends State<SubirFotoComentarioLugar> {
  List<Asset> images = [];
  String _error = 'Seleccione una foto';
  bool _deshabilitar = false;
  CommentsBloc _commentsBloc = new CommentsBloc();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      refresh();
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _commentsBloc.init(context, refresh);
    });
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = [];
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 6,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "Fatto",
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: widget.lugar!.nombre.toString(),
          allViewTitle: "all photos".tr(),
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );

      for (Asset i in resultList) {
        print(i.name! + " " + i.getByteData().toString());
      }
    } on Exception catch (e) {
      error = e.toString();
    }
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  Future btnSubirFotos() async {
    setState(() {
      _deshabilitar = true;
    });
    bool dato =
        await _commentsBloc.subirFotosLugar(widget.lugar!.idlugar!, images);

    if (dato) {
      //return _onAlertButtonPressed(context) {
      setState(() {
        _deshabilitar = false;
      });
      Alert(
        context: context,
        type: AlertType.success,
        title: "message".tr(),
        desc: "success".tr(),
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => {
              if (Navigator.canPop(context))
                {
                  Navigator.pop(context),
                  clearText(),
                }
              else
                {
                  SystemNavigator.pop(),
                  clearText(),
                }
            },
            width: 120,
          )
        ],
      ).show();
    } else {
      mostrarAlerta(context, 'message'.tr(),
          'something is wrong. please try again.'.tr());
      setState(() {
        _deshabilitar = false;
      });
    }
  }

  void clearText() {
    setState(() {
      images = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(5.0),
                child: TextButton(
                  onPressed: () async {
                    if (images.length > 0) {
                      openSnacbar(scaffoldKey, 'select images'.tr());
                    } else {
                      (!_deshabilitar) ? btnSubirFotos() : null;
                    }
                  },
                  child: Text(
                    'post',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ).tr(),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.teal,
                    onSurface: Colors.grey,
                  ),
                ),
              ),
            ],
            // backgroundColor: Colors.white,
            title: Text(
              widget.lugar!.nombre.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          body: SingleChildScrollView(
              child: Container(
            margin: EdgeInsets.all(20),
            child: Column(children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.photo_camera),
                      label: Text("add photos").tr(),
                      onPressed: loadAssets,
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
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 200.0,
                      child: GridView.count(
                        crossAxisCount: 3,
                        children: List.generate(images.length, (index) {
                          Asset asset = images[index];
                          return Stack(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 5.0),
                                child: AssetThumb(
                                  asset: asset,
                                  width: 300,
                                  height: 300,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                        //color: Colors.indigo[900],
                                        shape: BoxShape.circle),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(0.0),
                                      onTap: () => setState(() {
                                        images.removeAt(index);
                                      }),
                                      child: Container(
                                        child: Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ]),
          ))),
    );
  }
}

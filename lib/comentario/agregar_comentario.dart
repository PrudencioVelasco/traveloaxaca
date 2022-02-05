import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/conquien_visito_bloc.dart';
import 'package:traveloaxaca/blocs/internet_bloc.dart';
import 'package:traveloaxaca/models/conquien_visitaste.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

class AgregarComentarioPage extends StatefulWidget {
  final Lugar? lugar;
  AgregarComentarioPage({Key? key, required this.lugar}) : super(key: key);

  @override
  _AgregarComentarioPageState createState() => _AgregarComentarioPageState();
}

class _AgregarComentarioPageState extends State<AgregarComentarioPage> {
  List<Asset> images = [];
  String _error = 'Selectionner une image';
  TextEditingController ctrlComentario = TextEditingController();
  List<ConquienVisito?> _listaconquienvisito = [];
  int _selectedIndex = 0;
  double _rating = 3;
  bool _deshabilitar = false;
  ConQuienVisitoBloc _conQuienVisitoBloc = new ConQuienVisitoBloc();
  CommentsBloc _commentsBloc = new CommentsBloc();
  String _errorExperiencia = "";
  String _errorClaseVisita = "";
  bool _isAlwaysShown = true;
  bool _showTrackOnHover = false;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
      getAllConQuienVisito();
      refresh();
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _conQuienVisitoBloc.init(context, refresh);
      _commentsBloc.init(context, refresh);
    });
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  getAllConQuienVisito() async {
    _listaconquienvisito = await _conQuienVisitoBloc.obtenerConQuienVisito();
    refresh();
  }

  Future<String> someFutureStringFunction(
      BuildContext context, String texto) async {
    Locale myLocale = Localizations.localeOf(context);
    if (myLocale.languageCode == "en") {
      var translation = await translator.translate(texto, from: 'es', to: 'en');
      return translation.toString();
    } else {
      return texto.toString();
    }
  }
  /*@override
  void dispose() {
    _scrollViewController.dispose();
    _scrollViewController.removeListener(() {});
    super.dispose();
  }*/

  DateTime selectedDate = DateTime.now();
  _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }

  /// This builds material date picker in Android
  buildMaterialDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: selectedDate,

      // locale: const Locale("es"),
      // fieldHintText: 'Month/Date/Year',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  /// This builds cupertion date picker in iOS
  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                if (picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
              initialDateTime: selectedDate,
              minimumYear: 2000,
              maximumYear: 2025,
            ),
          );
        });
  }

  void clearText() {
    setState(() {
      ctrlComentario.clear();
      _selectedIndex = 0;
      _rating = 3;
      selectedDate = DateTime.now();
      images = [];
    });
  }

  Future agregarComentario() async {
    final ib = Provider.of<InternetBloc>(context, listen: false);
    var verificarConeccion = await ib.checarInternar();
    if (verificarConeccion == false) {
      Navigator.of(context, rootNavigator: true).pop();
      mensajeDialog(context, 'message'.tr(), 'no internet'.tr());
    } else {
      setState(() {
        _deshabilitar = true;
      });
      bool dato = await _commentsBloc.agregarComentarioLugar(
          widget.lugar!.idlugar!,
          _rating,
          ctrlComentario.text,
          _selectedIndex,
          selectedDate,
          images);
      if (dato) {
        setState(() {
          _deshabilitar = false;
        });
        // Navigator.of(context, rootNavigator: true).pop();
        mostrarAlerta(context, 'message'.tr(), 'success'.tr());
        clearText();
      } else {
        mostrarAlerta(context, 'message'.tr(),
            'something is wrong. please try again.'.tr());
        setState(() {
          _deshabilitar = false;
        });
      }
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
            icon: Icon(Icons.arrow_back),
          ),
          actions: [
            Container(
              margin: EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  if (ctrlComentario.text.isNotEmpty) {
                    setState(() {
                      _errorExperiencia = "";
                    });
                    if (_selectedIndex != 0) {
                      setState(() {
                        _errorClaseVisita = "";
                      });
                      (!_deshabilitar) ? agregarComentario() : null;
                    } else {
                      setState(() {
                        _errorClaseVisita = "select a option".tr();
                      });
                    }
                  } else {
                    setState(() {
                      _errorExperiencia = "don not empty".tr();
                    });
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
            /* IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.save_alt_rounded),
                ),*/
          ],
          // backgroundColor: Colors.white,
          title: Text(widget.lugar!.nombre.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                //color: Colors.black,
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('how would you rate your experience',
                        style: TextStyle(
                          // color: Colors.black,
                          fontSize: 16,
                        )).tr(),
                    Container(
                      child: RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star_border_outlined,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          _rating = rating;
                          print(rating);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'write your experience',
                      style: TextStyle(
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ).tr(),
                    _comentarioInput(),
                    if (_errorExperiencia.isNotEmpty)
                      Text(
                        _errorExperiencia,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'what kind of visit was this',
                      style: TextStyle(
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ).tr(),
                    SizedBox(
                      height: 10,
                    ),
                    FutureBuilder(
                        future: _conQuienVisitoBloc.obtenerConQuienVisito(),
                        builder: (context,
                            AsyncSnapshot<List<ConquienVisito?>> snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              height: 60,
                              //color: Colors.white,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return _conQuienVisito(snapshot.data![index]);
                                },
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text("Error");
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                    if (_errorClaseVisita.isNotEmpty)
                      Text(
                        _errorClaseVisita,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'when did you visit',
                      style: TextStyle(
                        //  color: Colors.black,
                        fontSize: 16,
                      ),
                    ).tr(),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        //  color: Colors.white,
                        size: 24.0,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey[500],
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () => _selectDate(context),
                      label: Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          //color: Colors.white
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
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
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                              //color: Colors.indigo[900],
                                              shape: BoxShape.circle),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
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
                    /* Expanded(
                      child: Column(
                    children: [buildGridView()],
                  )),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conQuienVisito(ConquienVisito? item) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 0),
        child: ChoiceChip(
          elevation: 5,
          pressElevation: 5,
          label: FutureBuilder(
              future: someFutureStringFunction(context, item!.nombre!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.toString().toUpperCase());
                } else if (snapshot.hasError) {
                  return Text("error");
                }
                return Text("loading...".tr());
              }),
          selected: _selectedIndex == item.idconquienvisito,
          selectedColor: Colors.green[600],
          padding: EdgeInsets.all(10),
          labelStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          backgroundColor: Colors.grey[500],
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedIndex = item.idconquienvisito!;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _comentarioInput() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: TextField(
        controller: ctrlComentario,
        maxLines: 6,
        minLines: 6,

        keyboardType: TextInputType.multiline,
        //style: TextStyle(color: Colors.red),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          //fillColor: Colors.white,
          filled: true,
          //errorText: _errorTextComentio,
          // icon: Icon(Icons.email),
          hintText: "you rated your experience 2 out of 5 tell us more".tr(),
          //labelText: 'Comparte mas sobre tus experiencias',
        ),
        // validator: (value) => _validatorEmail(value));
      ),
    );
  }
}

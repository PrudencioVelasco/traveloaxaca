import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/conquien_visito_bloc.dart';
import 'package:traveloaxaca/models/conquien_visitaste.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class AgregarComentarioPage extends StatefulWidget {
  final Lugar? lugar;
  AgregarComentarioPage({Key? key, required this.lugar}) : super(key: key);

  @override
  _AgregarComentarioPageState createState() => _AgregarComentarioPageState();
}

class _AgregarComentarioPageState extends State<AgregarComentarioPage> {
  TextEditingController ctrlComentario = TextEditingController();
  List<ConquienVisito?> _listaconquienvisito = [];
  int _selectedIndex = 0;
  double _rating = 3;
  bool _deshabilitar = false;
  ConQuienVisitoBloc _conQuienVisitoBloc = new ConQuienVisitoBloc();
  CommentsBloc _commentsBloc = new CommentsBloc();
  String _errorExperiencia = "";
  String _errorClaseVisita = "";
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
                if (picked != null && picked != selectedDate)
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
    });
  }

  Future agregarComentario() async {
    setState(() {
      _deshabilitar = true;
    });
    ResponseApi? dato = await _commentsBloc.agregarComentarioLugar(
        widget.lugar!.idlugar!,
        _rating,
        ctrlComentario.text,
        _selectedIndex,
        selectedDate);
    if (dato!.success!) {
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
      mostrarAlerta(context, 'message'.tr(), dato.message!);
      setState(() {
        _deshabilitar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.black));
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
              margin: EdgeInsets.all(5.0),
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
          backgroundColor: Colors.white,
          title: Text(
            widget.lugar!.nombre.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            //color: Colors.black,
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('how would you rate your experience',
                    style: TextStyle(
                      color: Colors.black,
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
                      Icons.star,
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
                  'how would you rate your experience',
                  style: TextStyle(
                    color: Colors.black,
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
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ).tr(),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 60,
                  //color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: _listaconquienvisito.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _conQuienVisito(_listaconquienvisito[index]);
                    },
                  ),
                ),
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
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ).tr(),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
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
                        color: Colors.white),
                  ),
                ),
                // Container(
                //  child: _comentarioInput,
                //)
              ],
            ),
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
          label: Text(item!.nombre!),
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
          fillColor: Colors.white,
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
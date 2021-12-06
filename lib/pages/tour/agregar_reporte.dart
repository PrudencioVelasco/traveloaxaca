import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:traveloaxaca/blocs/causa_reporte_bloc.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:traveloaxaca/blocs/tour_bloc.dart';
import 'package:traveloaxaca/models/causa_reporte.dart';
import 'package:traveloaxaca/models/comentario_tour.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';

class ReportarComentarioTourPage extends StatefulWidget {
  final ComentarioTour? comentario;
  ReportarComentarioTourPage({Key? key, required this.comentario})
      : super(key: key);

  @override
  _ReportarComentarioTourPageState createState() =>
      _ReportarComentarioTourPageState();
}

class _ReportarComentarioTourPageState
    extends State<ReportarComentarioTourPage> {
  TextEditingController ctrlComentario = TextEditingController();
  int _stackIndex = 0;
  String _radioItem = '';
  int _id = 0;
  String _errorMorivo = "";
  bool _deshabilitar = false;
  CausaReporteBloc _causaReporteBloc = new CausaReporteBloc();
  List<CausaReporte?> _causaReporte = [];
  TourBloc _tourBloc = new TourBloc();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
      getAllCausaReporte();
      refresh();
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _causaReporteBloc.init(context, refresh);
      _tourBloc.init(context, refresh);
    });
  }

  getAllCausaReporte() async {
    _causaReporte = await _causaReporteBloc.causasReportes();
    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  ScrollController? controller;
  int? _groupValue;
  void clearText() {
    setState(() {
      ctrlComentario.clear();
      _id = 0;
    });
  }

  Future agregarReporteComentarioLugar() async {
    setState(() {
      _deshabilitar = true;
    });
    ResponseApi? dato = await _tourBloc.agregarReporteComentarioTour(
        widget.comentario!.idcomentario!, _id, ctrlComentario.text);
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
            icon: Icon(Icons.close),
          ),
          actions: [
            Container(
              margin: EdgeInsets.all(5.0),
              child: TextButton(
                onPressed: () {
                  // agregarComentario();
                  if (_id > 0) {
                    setState(() {
                      _errorMorivo = "";
                    });
                    (!_deshabilitar) ? agregarReporteComentarioLugar() : null;
                  } else {
                    setState(() {
                      _errorMorivo = "select a option".tr();
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
          ],
          backgroundColor: Colors.white,
          title: Text(
            widget.comentario!.userName.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            // padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'motive'.tr(),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // color: Colors.red,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _causaReporte.length,
                            itemBuilder: (ctx, index) {
                              return RadioListTile<String>(
                                  title: Text(
                                    "${_causaReporte[index]!.nombrecausareporte}",
                                    maxLines: 2,
                                  ),
                                  value: _causaReporte[index]!
                                      .idcausareporte!
                                      .toString(),
                                  groupValue: _id.toString(),
                                  onChanged: (val) {
                                    setState(() {
                                      _radioItem = _causaReporte[index]!
                                          .nombrecausareporte!;
                                      _id =
                                          _causaReporte[index]!.idcausareporte!;
                                    });
                                  });
                            })
                      ]),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'add note'.tr(),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _comentarioInput()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _comentarioInput() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: TextField(
        controller: ctrlComentario,
        maxLines: 3,
        minLines: 3,

        keyboardType: TextInputType.multiline,
        //style: TextStyle(color: Colors.red),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
          // icon: Icon(Icons.email),
          hintText: "add note".tr(),
          //labelText: 'Comparte mas sobre tus experiencias',
        ),
        // validator: (value) => _validatorEmail(value));
      ),
    );
  }
}

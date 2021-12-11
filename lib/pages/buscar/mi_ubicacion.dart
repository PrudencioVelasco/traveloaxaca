import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/pages/buscar/mapa.dart';
import 'package:traveloaxaca/pages/tour/todos.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/list_card_compania.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class MiUbicacionPage extends StatefulWidget {
  final int? idclasificacion;
  final String? nombreclasificacion;
  const MiUbicacionPage(
      {Key? key,
      required this.idclasificacion,
      required this.nombreclasificacion})
      : super(key: key);

  @override
  _MiUbicacionPageState createState() => _MiUbicacionPageState();
}

class _MiUbicacionPageState extends State<MiUbicacionPage> {
  String? _sortValue;
  String? _ascValue;
  bool cargando = true;
  bool sinresultado = false;
  List<Map> _listaRating = [
    {"id": 1, "nombre": "1 start".tr()},
    {"id": 2, "nombre": "2 start".tr()},
    {"id": 3, "nombre": "3 start".tr()},
    {"id": 4, "nombre": "4 start".tr()},
    {"id": 5, "nombre": "5 start".tr()},
  ];
  List<Map> _listaComLove = [
    {"id": 1, "nombre": "more reviews".tr()},
    {"id": 2, "nombre": "more loves".tr()},
  ];
  List<Compania?> _listaCompania = [];
  CompaniaBloc _companiaBloc = new CompaniaBloc();
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _companiaBloc.init(context, refresh);
    });
    allCompanias();

    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future allCompanias() async {
    _listaCompania = await _companiaBloc.getData(widget.idclasificacion!);
    if (_listaCompania.length > 0) {
      if (mounted) {
        setState(() {
          cargando = false;
          sinresultado = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          cargando = false;
          sinresultado = true;
        });
      }
    }
  }

  Future<List<Compania?>> obtenerCompanias() async {
    return await _companiaBloc.getData(widget.idclasificacion!);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            title: Text(
              widget.nombreclasificacion.toString().tr(),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
          ),
        ];
      },
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: <Widget>[
                      ToggleSwitch(
                        minWidth: 90.0,
                        initialLabelIndex: 1,
                        cornerRadius: 20.0,
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        totalSwitches: 2,
                        labels: ['list'.tr(), 'map'.tr()],
                        icons: [FontAwesomeIcons.list, FontAwesomeIcons.map],
                        activeBgColors: [
                          [Colors.blue],
                          [Colors.pink]
                        ],
                        onToggle: (index) {
                          print('switched to: $index');
                          if (index == 1) {
                            nextScreen(
                                context,
                                MapaPage(
                                    idclasificacion: widget.idclasificacion,
                                    nombreclasificacion:
                                        widget.nombreclasificacion));
                          }
                          setState(() {});
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8, left: 8),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text("activity".tr()),
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
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8, left: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            modalSortBy();
                          },
                          child: Text("sort by".tr()),
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
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            Expanded(
                child: (cargando)
                    ? ListView.separated(
                        padding: EdgeInsets.all(15),
                        itemCount: 5,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(
                          height: 10,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return LoadingCard(height: 120);
                        },
                      )
                    : (sinresultado)
                        ? EmptyPage(
                            icon: FeatherIcons.clipboard,
                            message: 'no places found'.tr(),
                            message1: "try again".tr(),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.all(10),
                            itemCount: _listaCompania.length,
                            separatorBuilder: (context, index) => SizedBox(
                              height: 5,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return ListCardCompaniaCerca(
                                d: _listaCompania[index],
                                tag: "search$index",
                                color: Colors.white,
                              );
                            },
                          )),
            /* Expanded(
                 child: FutureBuilder(
                  future: context.watch<CompaniaBloc>().getData(widget.idclasificacion!),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length == 0)
                        return EmptyPage(
                          icon: FeatherIcons.clipboard,
                          message: 'no places found'.tr(),
                          message1: "try again".tr(),
                        );
                      else
                        return ListView.separated(
                          padding: EdgeInsets.all(10),
                          itemCount: snapshot.data.length,
                          separatorBuilder: (context, index) => SizedBox(
                            height: 5,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return ListCardCompaniaCerca(
                              d: snapshot.data[index],
                              tag: "search$index",
                              color: Colors.white,
                            );
                          },
                        );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.all(15),
                      itemCount: 5,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return LoadingCard(height: 120);
                      },
                    );
                  },
              ),
               ),*/
          ],
        ),
      ),
    ));
  }

  modalSortBy() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    margin: EdgeInsets.only(top: 5, bottom: 5),
                    height: 5,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 12, right: 10),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.sort,
                            color: Color(0xff808080),
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text("sort by").tr(),
                              isDense: true,
                              items: _listaRating.map((Map value) {
                                return DropdownMenuItem(
                                  value: value["id"].toString(),
                                  child: Text(value["nombre"].toString(),
                                      style: TextStyle(
                                          color: textColor, fontSize: 16)),
                                );
                              }).toList(),
                              value: _sortValue,
                              onChanged: (newValue) {
                                setState(() {
                                  _sortValue = newValue;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 8, right: 10),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.sort_by_alpha,
                            color: Color(0xff808080),
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text("reactions").tr(),
                              items: _listaComLove.map((Map value) {
                                return DropdownMenuItem(
                                  value: value["id"].toString(),
                                  child: Text(value["nombre"].toString(),
                                      style: TextStyle(
                                          color: textColor, fontSize: 16)),
                                );
                              }).toList(),
                              value: _ascValue,
                              onChanged: (newValue) {
                                setState(() {
                                  _ascValue = newValue;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            child: Text("clean").tr(),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              onSurface: Colors.black,
                              //shadowColor: Colors.grey,
                              padding: EdgeInsets.all(10.0),
                              elevation: 2,

                              shape: RoundedRectangleBorder(
                                  side: BorderSide(),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            onPressed: () {
                              Navigator.pop(context, true);
                              //btnCancelar();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            child: Text("filter").tr(),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              onSurface: Colors.black,
                              //shadowColor: Colors.grey,
                              padding: EdgeInsets.all(10.0),
                              elevation: 2,

                              shape: RoundedRectangleBorder(
                                  side: BorderSide(),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            onPressed: () {
                              //btnBuscar();
                              //Navigator.pop(context, true);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

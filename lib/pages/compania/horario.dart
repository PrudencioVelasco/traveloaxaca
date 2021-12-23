import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/models/horario.dart';
import 'package:easy_localization/easy_localization.dart';

class HorarioPage extends StatefulWidget {
  final Compania compania;
  HorarioPage({Key? key, required this.compania}) : super(key: key);

  @override
  _HorarioPageState createState() => _HorarioPageState();
}

class _HorarioPageState extends State<HorarioPage> {
  List numerodias = [1, 2, 3, 4, 5, 6, 7];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "schedule".tr(),
          //  textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Row(
          children: [
            Expanded(
                child: Container(
              child: FutureBuilder(
                future: context
                    .watch<CompaniaBloc>()
                    .obtenerHorarioCompania(widget.compania.idcompania!),
                builder: (context, AsyncSnapshot<List<Horario?>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return Container(
                        child: ListTile(
                          title: Text(
                            "monday".tr(),
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Column(
                            children: [
                              if (snapshot.data!
                                      .where((element) => element!.iddia == 1)
                                      .toList()
                                      .length >
                                  0)
                                for (var d in snapshot.data!
                                    .where((element) => element!.iddia == 1))
                                  Row(
                                    children: [obtener(d, 1)],
                                  )
                              else
                                Row(
                                  children: [Text("closed".tr())],
                                )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return Text("loading...".tr());
                    }
                  }
                },
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              child: FutureBuilder(
                future: context
                    .watch<CompaniaBloc>()
                    .obtenerHorarioCompania(widget.compania.idcompania!),
                builder: (context, AsyncSnapshot<List<Horario?>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return Container(
                        child: ListTile(
                          title: Text(
                            "tuesday".tr(),
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Column(
                            children: [
                              if (snapshot.data!
                                      .where((element) => element!.iddia == 2)
                                      .toList()
                                      .length >
                                  0)
                                for (var d in snapshot.data!
                                    .where((element) => element!.iddia == 2))
                                  Row(
                                    children: [obtener(d, 2)],
                                  )
                              else
                                Row(
                                  children: [Text("closed".tr())],
                                )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return Text("loading...".tr());
                    }
                  }
                },
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              child: FutureBuilder(
                future: context
                    .watch<CompaniaBloc>()
                    .obtenerHorarioCompania(widget.compania.idcompania!),
                builder: (context, AsyncSnapshot<List<Horario?>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return Container(
                        child: ListTile(
                          title: Text(
                            "wednesday".tr(),
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Column(
                            children: [
                              if (snapshot.data!
                                      .where((element) => element!.iddia == 3)
                                      .toList()
                                      .length >
                                  0)
                                for (var d in snapshot.data!
                                    .where((element) => element!.iddia == 3))
                                  Row(
                                    children: [obtener(d, 3)],
                                  )
                              else
                                Row(
                                  children: [Text("closed".tr())],
                                )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return Text("loading...".tr());
                    }
                  }
                },
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              child: FutureBuilder(
                future: context
                    .watch<CompaniaBloc>()
                    .obtenerHorarioCompania(widget.compania.idcompania!),
                builder: (context, AsyncSnapshot<List<Horario?>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return Container(
                        child: ListTile(
                          title: Text(
                            "thursday".tr(),
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Column(
                            children: [
                              if (snapshot.data!
                                      .where((element) => element!.iddia == 4)
                                      .toList()
                                      .length >
                                  0)
                                for (var d in snapshot.data!
                                    .where((element) => element!.iddia == 4))
                                  Row(
                                    children: [obtener(d, 4)],
                                  )
                              else
                                Row(
                                  children: [Text("closed".tr())],
                                )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return Text("loading...".tr());
                    }
                  }
                },
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              child: FutureBuilder(
                future: context
                    .watch<CompaniaBloc>()
                    .obtenerHorarioCompania(widget.compania.idcompania!),
                builder: (context, AsyncSnapshot<List<Horario?>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return Container(
                        child: ListTile(
                          title: Text(
                            "friday".tr(),
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Column(
                            children: [
                              if (snapshot.data!
                                      .where((element) => element!.iddia == 5)
                                      .toList()
                                      .length >
                                  0)
                                for (var d in snapshot.data!
                                    .where((element) => element!.iddia == 5))
                                  Row(
                                    children: [obtener(d, 5)],
                                  )
                              else
                                Row(
                                  children: [Text("closed".tr())],
                                )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return Text("loading...".tr());
                    }
                  }
                },
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              child: FutureBuilder(
                future: context
                    .watch<CompaniaBloc>()
                    .obtenerHorarioCompania(widget.compania.idcompania!),
                builder: (context, AsyncSnapshot<List<Horario?>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return Container(
                        child: ListTile(
                          title: Text(
                            "saturday".tr(),
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Column(
                            children: [
                              if (snapshot.data!
                                      .where((element) => element!.iddia == 6)
                                      .toList()
                                      .length >
                                  0)
                                for (var d in snapshot.data!
                                    .where((element) => element!.iddia == 6))
                                  Row(
                                    children: [obtener(d, 6)],
                                  )
                              else
                                Row(
                                  children: [Text("closed".tr())],
                                )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return Text("loading...".tr());
                    }
                  }
                },
              ),
            ))
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              child: FutureBuilder(
                future: context
                    .watch<CompaniaBloc>()
                    .obtenerHorarioCompania(widget.compania.idcompania!),
                builder: (context, AsyncSnapshot<List<Horario?>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return Container(
                        child: ListTile(
                          title: Text(
                            "sunday".tr(),
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Column(
                            children: [
                              if (snapshot.data!
                                      .where((element) => element!.iddia == 7)
                                      .toList()
                                      .length >
                                  0)
                                for (var d in snapshot.data!
                                    .where((element) => element!.iddia == 7))
                                  Row(
                                    children: [obtener(d, 7)],
                                  )
                              else
                                Row(
                                  children: [Text("closed".tr())],
                                )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return Text("loading...".tr());
                    }
                  }
                },
              ),
            ))
          ],
        ),
      ])),
    );
  }

  Widget obtener(Horario? horario, int dia) {
    //Lunes
    List<Horario?> listaTemporal = [];
    if (horario != null) {
      return Text(horario.horainicial! + " - " + horario.horafinal!);
    } else {
      return Container();
    }
  }
}

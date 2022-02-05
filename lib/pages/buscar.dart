import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:traveloaxaca/blocs/buscar_bloc.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/buscar/buscar_cosas_quehacer.dart';
import 'package:traveloaxaca/pages/buscar/buscar_lugar_categoria.dart';
import 'package:traveloaxaca/pages/buscarNext.dart';
import 'package:traveloaxaca/pages/tour/todos.dart';
import 'package:traveloaxaca/pages/rutas_principales.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:translator/translator.dart';
import 'package:traveloaxaca/utils/connectionStatusSingleton.dart';

class BuscarPage extends StatefulWidget {
  BuscarPage({Key? key}) : super(key: key);

  _BuscarPageState createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final translator = GoogleTranslator();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  BuscarBloc _con = new BuscarBloc();
  List<Categoria?> _listasCategorias = [];
  CategoriaBloc _categoriaBloc = new CategoriaBloc();
  List<Lugar?> _listaLugares = [];
  bool busqueda = false;
  bool encontado = false;
  String? parametro;
  String inputText = "";
  int? _selectIndex;
  bool isOffline = false;
  var isLight = true;
  StreamSubscription? _connectionChangeStream;
  @override
  void initState() {
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    // Future.delayed(Duration()).then((value) => _con.saerchInitialize());
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      // _con.init(context);
      _categoriaBloc.init(context, refresh);
      _con.init(context, refresh);
      // getData();
    });
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {});
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

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    //var brishtness = MediaQuery.of(context).platformBrightness;
    //bool isDarkMode = brishtness == Brightness.dark;
    return (isOffline)
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(left: 25, right: 25, top: 10),
                    child: Text(
                      'are you offline?'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                Container(
                  margin: EdgeInsets.only(left: 25, right: 25, top: 10),
                  child: Text(
                    'please check your internet connection and reload the page'
                        .tr(),
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 25, right: 25, top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: Text('reload').tr(),
                          // icon: Icon(Icons.add_comment_rounded),
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
                          onPressed: () => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        : Scaffold(
            // backgroundColor: Colors.white,
            body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 30, left: 20),
                              child: Text(
                                "search".tr(),
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Header(),
                    FutureBuilder(
                        future:
                            _categoriaBloc.obtenerTodascategoriasPrincipal(),
                        builder: (context,
                            AsyncSnapshot<List<Categoria?>> snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              height: 50,
                              // color: Colors.redAccent,
                              margin:
                                  EdgeInsets.only(left: 15, right: 15, top: 10),
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return _categorias(
                                      snapshot.data![index], context);
                                },
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text("Error");
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 20,
                            left: 25,
                          ),
                          child: Text(
                            'destination travel'.tr(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    RutasPrincipalesPage()
                  ],
                ),
              ),
            ),
          ));
  }

  Widget _categorias(Categoria? item, BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (item!.idclasificacion == 13) {
            nextScreen(context, TodosToursPage());
          } else if (item.idclasificacion == 16) {
            nextScreen(
                context,
                BuscarLugarPage(
                  nombre: item.nombreclasificacion,
                  idclasificacion: item.idclasificacion,
                ));
          } else {
            // nextScreen(context, PermisoGpsPage(
            nextScreen(
                context,
                BuscarLugarCategoriaPage(
                  nombre: item.nombreclasificacion,
                  idclasificacion: item.idclasificacion,
                ));
          }
        },
        child: Container(
          // width: 500.0,
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.only(
            left: 10,
          ),
          // padding: new EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
          //color: Colors.green,
          child: Column(children: [
            FutureBuilder(
                future: someFutureStringFunction(
                    context, item!.nombreclasificacion!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data.toString().toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text("error");
                  }
                  return Text("loading...".tr());
                })
          ]),
        ));
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
        child: Column(
          children: [
            InkWell(
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 5, right: 5),
                padding: EdgeInsets.only(left: 15, right: 15),
                height: 55,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        FeatherIcons.search,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'search places',
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ).tr(),
                    ],
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BuscarNextPage()));
              },
            )
          ],
        ),
      ),
    );
  }
}

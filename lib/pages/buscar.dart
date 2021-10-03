import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/buscar_bloc.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/categoria.dart';
import 'package:traveloaxaca/pages/mapa_busqueda.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/list_card.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/snacbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuscarPage extends StatefulWidget {
  BuscarPage({Key? key}) : super(key: key);

  _BuscarPageState createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  BuscarBloc _con = new BuscarBloc();
  List<Lugar?> _listaLugares = [];
  bool busqueda = false;
  bool encontado = false;
  String? parametro;
  String inputText = "";
  @override
  void initState() {
    // Future.delayed(Duration()).then((value) => _con.saerchInitialize());
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      // _con.init(context);
      _con.init(context, refresh);
      // getData();
    });
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
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
        key: scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            flexibleSpace: Column(
              children: [
                SizedBox(height: 45),
                _textFielSearch(),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      child: TextButton.icon(
                        onPressed: () {
                          if (busqueda == true && encontado == true) {
                            nextScreen(context,
                                MapaBusquedaPage(listalugares: _listaLugares));
                          } else {
                            openSnacbar(
                                scaffoldKey, 'Primero haga la busquerda!');
                          }
                          // agregarComentarioClick();
                        },
                        icon: const Icon(FontAwesomeIcons.mapMarkedAlt),
                        label: Text("map").tr(),
                      ),
                    ),
                  ],
                )*/
              ],
            ),
          ),
        ),
        body: (busqueda == true)
            ? SafeArea(
                child: FutureBuilder(
                  future: _con.getData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length == 0)
                        return EmptyPage(
                          icon: Icons.beach_access,
                          message: 'no places found',
                          message1: "try again",
                        );
                      else
                        encontado = true;
                      _listaLugares = snapshot.data;
                      return ListView.separated(
                        padding: EdgeInsets.all(10),
                        itemCount: snapshot.data.length,
                        separatorBuilder: (context, index) => SizedBox(
                            //height: 5,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          return ListCard(
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
              )
            : _busquedaRapida(),
      ),
    );
  }

  Widget _busquedaRapida() {
    return Container(margin: EdgeInsets.all(0), child: CategoriaPage());
  }

  Widget _textFielSearch() {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        controller: _con.textfieldCtrl,
        onSubmitted: (value) {
          inputText = value;
          if (value == '') {
            openSnacbar(scaffoldKey, 'Type something!');
          } else {
            _con.setSearchText(value);
            busqueda = true;
            refresh();
          }
        },
        decoration: InputDecoration(
          hintText: 'search & explore'.tr(),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 3),
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.grey[800],
              ),
              color: Colors.grey[800],
              onPressed: () {},
            ),
          ),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.grey[800],
                  size: 25,
                ),
                onPressed: () {
                  _con.saerchInitialize();
                  busqueda = false;
                  refresh();
                },
              ),
              Container(
                padding: EdgeInsets.only(right: 2),
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.mapMarkedAlt,
                    color: Colors.blue[400],
                    size: 25,
                  ),
                  onPressed: () {
                    if (busqueda == true && encontado == true) {
                      nextScreen(context,
                          MapaBusquedaPage(listalugares: _listaLugares));
                    } else {
                      openSnacbar(scaffoldKey, 'Primero haga la busquerda!');
                    }
                    busqueda = false;
                    refresh();
                  },
                ),
              ),
            ],
          ),
          hintStyle: TextStyle(fontSize: 17, color: Colors.grey[500]),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey),
          ),
          contentPadding: EdgeInsets.all(15),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget hidingIcon() {
    return IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.red,
        ),
        splashColor: Colors.redAccent,
        onPressed: () {
          setState(() {
            _con.textfieldCtrl.clear();
            inputText = "";
          });
        });
  }
}

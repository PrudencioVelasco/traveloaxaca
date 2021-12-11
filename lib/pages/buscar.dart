import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:traveloaxaca/blocs/buscar_bloc.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/buscar/buscar_lugar_categoria.dart';
import 'package:traveloaxaca/pages/buscarNext.dart';
import 'package:traveloaxaca/pages/tour/todos.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class BuscarPage extends StatefulWidget {
  BuscarPage({Key? key}) : super(key: key);

  _BuscarPageState createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
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
  @override
  void initState() {
    // Future.delayed(Duration()).then((value) => _con.saerchInitialize());
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      // _con.init(context);
      _categoriaBloc.init(context, refresh);
      _con.init(context, refresh);
      // getData();
    });
    super.initState();
    getAllCategorias();
    refresh();
  }

  void getAllCategorias() async {
    _listasCategorias = (await _categoriaBloc.obtenerTodascategoriasPrincipal());
    refresh();
  }
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async{
            },
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10,left: 15),
                            child:  Text("search".tr(),
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800]),
                            ) ,
                          )

                        ],
                      )
                    ],
                  ),
                  Header(),
                  Container(
                    height: 80,
                    margin:  EdgeInsets.only(left: 15, right: 15),
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: _listasCategorias.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _chois(_listasCategorias[index],context);
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
  Widget _chois(Categoria? item, BuildContext context) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 0),
        child: ChoiceChip(
          elevation: 4,
          pressElevation: 5,
          shape: RoundedRectangleBorder(
              side: BorderSide(),
              borderRadius:
              BorderRadius.all(Radius.circular(20))),
          label: Text(
            item!.nombreclasificacion!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: _selectIndex==item.idclasificacion,
          padding: EdgeInsets.all(13),
          labelStyle: TextStyle(color: Colors.black54),
          backgroundColor: Colors.white,
          onSelected: (bool value) {
            setState(() {
              _selectIndex=item.idclasificacion;
              if(item.idclasificacion == 13){
                nextScreen(
                    context,TodosToursPage());
              }else {
               // nextScreen(context, PermisoGpsPage(
                nextScreen(context, BuscarLugarCategoriaPage(
                  nombre: item.nombreclasificacion,
                  idclasificacion: item.idclasificacion,));
              }
              });
          },
        ),
      ),

    );
  }

}




class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
        child: Column(
          children: [

            InkWell(
              child: Container(

                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 5, right: 5),
                padding: EdgeInsets.only(left: 15, right: 15),
                height: 45,
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



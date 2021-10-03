import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveloaxaca/blocs/actividad_bloc.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/pages/lugares_por_categoria.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class MoreActivityPage extends StatefulWidget {
  MoreActivityPage({Key? key}) : super(key: key);

  @override
  _MoreActivityPageState createState() => _MoreActivityPageState();
}

class _MoreActivityPageState extends State<MoreActivityPage> {
  TextEditingController editingController = TextEditingController();
  List<Categoria?> _searchResult = [];

  List<Categoria?> _listaCompleta = [];
  List<Categoria?> _segundaLista = [];
  CategoriaBloc _categoriaBloc = new CategoriaBloc();
  // Get json result and convert it to model. Then add

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      // _con.init(context);
      _categoriaBloc.init(context, refresh);
      getData();
    });

    refresh();
  }

  void getData() async {
    _listaCompleta = await _categoriaBloc.obtenerTodascategorias();
    _segundaLista = await _categoriaBloc.obtenerTodascategorias();
    refresh();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: PlayerSearch(_listaCompleta));
            },
            icon: Icon(Icons.search),
          )
        ],
        centerTitle: true,
        title: Text('category places').tr(),
      ),
      body: ListView.builder(
        itemCount: _listaCompleta.length,
        itemBuilder: (context, position) => ListTile(
          title: Text(_listaCompleta[position]!.nombreclasificacion!),
          onTap: () => nextScreen(context,
              LugaresPorCategoriaPage(categoria: _listaCompleta[position]!)),
        ),
      ),
    );
  }
}

class PlayerSearch extends SearchDelegate {
  final List<Categoria?> soccerPlayers;
  String? selectedResult;

  PlayerSearch(this.soccerPlayers);

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(
        child: Text(selectedResult!),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Categoria?> suggestedSoccerPlayers = [];
    query.isEmpty
        ? suggestedSoccerPlayers = soccerPlayers
        : suggestedSoccerPlayers.addAll(soccerPlayers.where(
            (element) => element!.nombreclasificacion!
                .toLowerCase()
                .contains(query.toLowerCase()),
          ));

    return ListView.builder(
        itemCount: suggestedSoccerPlayers.length,
        itemBuilder: (context, position) => ListTile(
              title:
                  Text(suggestedSoccerPlayers[position]!.nombreclasificacion!),
              onTap: () => nextScreen(
                  context,
                  LugaresPorCategoriaPage(
                      categoria: suggestedSoccerPlayers[position]!)),
            ));
  }
}

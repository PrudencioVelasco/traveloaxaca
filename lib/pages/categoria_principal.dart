import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/blocs/tour_bloc.dart';
import 'package:traveloaxaca/compania/compania_page.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/models/tour.dart';
import 'package:traveloaxaca/pages/test.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class CategoriaPrincipalPage extends StatefulWidget {
  CategoriaPrincipalPage({Key? key}) : super(key: key);

  @override
  _CategoriaPrincipalPageState createState() => _CategoriaPrincipalPageState();
}

class _CategoriaPrincipalPageState extends State<CategoriaPrincipalPage> {
  List<Tour?> _listaTours = [];
  TourBloc _tourBloc = new TourBloc();
  int _selectedIndex = 0;
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _tourBloc.init(context, refresh);
    });
    getAllTours();
  }

  void getAllTours() async {
    _listaTours = (await _tourBloc.todosLosTours());
    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // padding: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 15),
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 5, top: 10, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  left: 10,
                  top: 10,
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      'explorer',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800]),
                    ).tr(),
                  ],
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  height: 150,
                  //color: Colors.green,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: _listaTours.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _chois(_listaTours[index]);
                    },
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ],
    );
  }

  /*Widget _botones(Categoria? item) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ]),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset('assets/images/restaurant.png'),
              ),
            ),
            Container(
              color: Colors.red,
              padding: EdgeInsets.all(16.0),
              child: Text(item!.nombreclasificacion!),
            )
          ],
        ),
      ),
    );
  }*/

  /* Widget _chois(Tour? item) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 0),
        child: ChoiceChip(
          elevation: 5,
          pressElevation: 5,
          label: Text(
            item!.nombre!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          shape: StadiumBorder(side: BorderSide()),
          selected: _selectedIndex == item.idclasificacion,
          padding: EdgeInsets.all(18),
          labelStyle: TextStyle(color: Colors.black),
          backgroundColor: Colors.white,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedIndex = item.idclasificacion!;
              }
            });
          },
        ),
      ),
    );
  }*/
}

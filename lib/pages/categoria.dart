import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/models/categoria.dart';
import 'package:traveloaxaca/pages/lugares_por_categoria.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class CategoriaPage extends StatefulWidget {
  CategoriaPage({Key? key}) : super(key: key);

  @override
  _CategoriaPageState createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  List<Categoria?> _listasCategorias = [];
  CategoriaBloc _categoriaBloc = new CategoriaBloc();
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _categoriaBloc.init(context, refresh);
    });
    getAllCategorias();
  }

  void getAllCategorias() async {
    _listasCategorias = (await _categoriaBloc.obtenerTodascategorias());
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
          margin: EdgeInsets.only(left: 5, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: GridView.builder(
                  itemCount: _listasCategorias.length,
                  padding: EdgeInsets.all(5.0),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    // crossAxisCount: 3,
                    childAspectRatio: 1.8,
                    crossAxisCount: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 4
                        : 3,
                  ),
                  physics: NeverScrollableScrollPhysics(),
                  //itemCount: 6,
                  itemBuilder: (BuildContext ctx, index) {
                    //return tarjetas(_listaCategoria[index], context);
                    if (_listasCategorias.isEmpty)
                      return LoadingCard(
                        height: 180,
                      );
                    return InkWell(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset:
                                  Offset(0, 4), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          // mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _listasCategorias[index]!.nombreclasificacion!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      onTap: () => nextScreen(
                          context,
                          LugaresPorCategoriaPage(
                              categoria: _listasCategorias[index]!)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

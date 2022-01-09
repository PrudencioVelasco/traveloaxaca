import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/models/ruta.dart';
import 'package:traveloaxaca/pages/destino/lista_destino.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class RutasPrincipalesPage extends StatefulWidget {
  RutasPrincipalesPage({Key? key}) : super(key: key);

  @override
  _RutasPrincipalesPageState createState() => _RutasPrincipalesPageState();
}

class _RutasPrincipalesPageState extends State<RutasPrincipalesPage> {
  RutasBloc _rutasBloc = new RutasBloc();
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) async {
      _rutasBloc.init(context, refresh);
    });
    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
      child: Column(
        children: [
          FutureBuilder(
              future: _rutasBloc.getData(),
              builder: (context, AsyncSnapshot<List<Ruta?>> snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                      padding: EdgeInsets.all(5),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 5,
                        mainAxisExtent: 200,
                        crossAxisSpacing: 12.0,
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return _chois(snapshot.data![index]!);
                      });
                } else if (snapshot.hasError) {
                  return Text("Error");
                } else {
                  return GridView.builder(
                      padding: EdgeInsets.all(5),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 5,
                        mainAxisExtent: 200,
                        crossAxisSpacing: 12.0,
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (BuildContext ctx, index) {
                        return LoadingRutaTuristicaCard();
                      });
                }
              }),
        ],
      ),
    );
  }

  Widget _chois(Ruta ruta) {
    return GestureDetector(
      onTap: () => {nextScreen(context, ListaDestinoPage(ruta: ruta))},
      child: Card(
        child: Container(
            // height: 300,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: AssetImage("assets/images/playa.jpg"),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter)),
            //margin: EdgeInsets.all(5),
            //padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width * 0.41,
                  padding: EdgeInsets.only(left: 5, right: 5, top: 3),
                  color: Colors.black.withOpacity(0.2),
                  child: Text(
                    ruta.nombre.toString(),
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            )),
        //margin: EdgeInsets.only(left: 20,r),
      ),
    );
  }
}

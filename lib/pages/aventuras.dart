import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/models/ruta.dart';
import 'package:traveloaxaca/pages/detalle_aventuras.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class AventurasPage extends StatefulWidget {
  AventurasPage({Key? key}) : super(key: key);

  @override
  _AventurasPageState createState() => _AventurasPageState();
}

class _AventurasPageState extends State<AventurasPage> {
  RutasBloc _rutasBloc = new RutasBloc();
  bool _visible = true;
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
      //  margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          FutureBuilder(
              future: _rutasBloc.obtenerRutasPrincipales(),
              builder: (context, AsyncSnapshot<List<Ruta?>> snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                      // padding: EdgeInsets.all(5),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 5,
                        mainAxisExtent: 360,
                        crossAxisSpacing: 12.0,
                        crossAxisCount: 1,
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

                      // padding: EdgeInsets.all(5),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 5,
                        mainAxisExtent: 300,
                        crossAxisSpacing: 12.0,
                        crossAxisCount: 1,
                        childAspectRatio: 1.0,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 2,
                      itemBuilder: (BuildContext ctx, index) {
                        return LoadingRutasPrincipalesTuristicaCard();
                      });
                }
              }),
        ],
      ),
    );
  }

  Widget _chois(Ruta ruta) {
    return Card(
      margin: EdgeInsets.only(bottom: 25, top: 0),
      child: Stack(children: <Widget>[
        Center(
          child: CachedNetworkImage(
            imageUrl: (ruta.imagen != '')
                ? ruta.imagen!
                : "https://misicebucket.s3.us-east-2.amazonaws.com/no-image-verical.jpg",
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 50.0,
                width: 50.0,
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                ruta.slogan.toString(),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Text(
                ruta.subtituloslogan.toString(),
                style: TextStyle(fontSize: 20, color: Colors.white
                    //  fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              margin: EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                child: Text('read the guide').tr(),
                // icon: Icon(Icons.add_comment_rounded),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  onSurface: Colors.black,
                  //shadowColor: Colors.grey,
                  padding: EdgeInsets.all(15.0),
                  elevation: 4,

                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
                onPressed: () =>
                    nextScreen(context, DetalleAventurasPage(ruta: ruta)),
              ),
            )
          ],
        ),
      ]),
      /* child: Container(
          // height: 300,
          // margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: (ruta.imagen != '')
                    ? NetworkImage(ruta.imagen!)
                    : NetworkImage(
                        "https://misicebucket.s3.us-east-2.amazonaws.com/no-image-horizontal.png"),
                fit: BoxFit.cover),
          ),
          //margin: EdgeInsets.all(5),
          //padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  ruta.slogan.toString(),
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Text(
                  ruta.subtituloslogan.toString(),
                  style: TextStyle(fontSize: 20, color: Colors.white
                      //  fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                child: ElevatedButton(
                  child: Text('read the guide').tr(),
                  // icon: Icon(Icons.add_comment_rounded),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    onSurface: Colors.black,
                    //shadowColor: Colors.grey,
                    padding: EdgeInsets.all(15.0),
                    elevation: 4,

                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                  onPressed: () =>
                      nextScreen(context, DetalleAventurasPage(ruta: ruta)),
                ),
              )
              
            ],
          ),
          ),*/
      //margin: EdgeInsets.only(left: 20,r),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/sitiosinteres.dart';

class MasInformacionLugarPage extends StatefulWidget {
  final Lugar? lugar;
  final SitiosInteres? sitiosinteres;
  MasInformacionLugarPage({Key? key, this.lugar, this.sitiosinteres})
      : super(key: key);

  @override
  _MasInformacionLugarPageState createState() =>
      _MasInformacionLugarPageState();
}

class _MasInformacionLugarPageState extends State<MasInformacionLugarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        //  backgroundColor: Colors.white,
        title: Text(widget.lugar!.nombre.toString(),
            //   textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6),
      ),
      body: SingleChildScrollView(
        child: Container(
          //height: 260,
          //  margin: EdgeInsets.only(right: 55),
          // color: Colors.green,
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          child: Text(widget.sitiosinteres!.descripcion.toString(),
              // maxLines: 8,
              // overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
              )),
        ),
      ),
    );
  }
}

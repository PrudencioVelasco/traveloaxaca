import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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
          child: Html(
            data: '''${widget.sitiosinteres!.descripcion}''',
            shrinkWrap: true,
            style: {
              "body": Style(
                // maxLines: 4,
                textAlign: TextAlign.justify,
                fontSize: FontSize(16.0),
                // fontWeight: FontWeight.w500,
                // color: Colors.black,
                // textOverflow: TextOverflow.ellipsis,
              ),
            },
          ),
        ),
      ),
    );
  }
}

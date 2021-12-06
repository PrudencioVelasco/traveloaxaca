import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class MasInformacionPage extends StatefulWidget {
  final String descripcion;
  final String nombre;
  MasInformacionPage(
      {Key? key, required this.nombre, required this.descripcion})
      : super(key: key);

  @override
  _MasInformacionPageState createState() => _MasInformacionPageState();
}

class _MasInformacionPageState extends State<MasInformacionPage> {
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
        backgroundColor: Colors.white,
        title: Text(
          widget.nombre.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              //color: Colors.black,
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Html(
                              data: '''${widget.descripcion}''',
                              shrinkWrap: true,
                              style: {
                                "body": Style(
                                  // maxLines: 4,
                                  textAlign: TextAlign.justify,
                                  fontSize: FontSize(16.0),
                                  // fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  //textOverflow: TextOverflow.ellipsis,
                                ),
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}

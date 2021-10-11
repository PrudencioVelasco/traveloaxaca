import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/models/telefono.dart';
import 'package:url_launcher/url_launcher.dart';

class InformacionPage extends StatefulWidget {
  InformacionPage({Key? key}) : super(key: key);

  @override
  _InformacionPageState createState() => _InformacionPageState();
}

class _InformacionPageState extends State<InformacionPage> {
  List<Telefono> _listaTelefono = [
    Telefono(descripcion: "SOS", telefono: "911", color: Colors.red),
    Telefono(
        descripcion: "Secretaria de Turismo",
        telefono: "+529515021200",
        color: Colors.blue)
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.grey[600],
        title: const Text('information').tr(),
      ),
      body: Container(
        // color: Colors.red,
        child: Row(children: <Widget>[
          Container(
            height: 65,
            //color: Colors.green,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: _listaTelefono.length,
              itemBuilder: (BuildContext context, int index) {
                return _choisTelefonos(_listaTelefono[index]);
              },
            ),
          ),
        ]),
      ),
      // backgroundColor: Colors.blueGrey.shade200,
    );
  }

  Widget _choisTelefonos(Telefono? telefono) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 0),
        child: ChoiceChip(
          padding: EdgeInsets.all(10),
          avatar: Icon(
            Icons.phone,
            color: Colors.white,
          ),
          elevation: 10,
          pressElevation: 5,
          label: Text(telefono!.descripcion),
          selected: false,
          labelStyle: TextStyle(color: Colors.white),
          backgroundColor: telefono.color,
          onSelected: (bool value) {
            //print("Preciono");
            String numeroTelefono = telefono.telefono;
            launch("tel:$numeroTelefono");
            //Do whatever you want when the chip is selected
          },
        ),
      ),
    );
  }
}

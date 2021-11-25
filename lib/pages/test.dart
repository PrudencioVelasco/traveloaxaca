import 'package:flutter/material.dart';

class TestPage2 extends StatefulWidget {
  int? idcategoria;
  TestPage2({Key? key, required this.idcategoria}) : super(key: key);

  @override
  _TestPage2State createState() => _TestPage2State();
}

class _TestPage2State extends State<TestPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test')),
      body: Text("Test"),
    );
  }
}

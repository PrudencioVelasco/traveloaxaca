import 'package:flutter/material.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/pages/home.dart';
import 'package:easy_localization/easy_localization.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            height: 45,
            width: w * 0.70,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              child: Text(
                'get started',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ).tr(),
              onPressed: () {
                nextScreenReplace(context, Home());
              },
            ),
          ),
          SizedBox(
            height: 0.15,
          ),
        ],
      ),
    );
  }
}

class IntroView extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  const IntroView(
      {Key? key,
      required this.title,
      required this.description,
      required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Container(
            alignment: Alignment.center,
            height: h * 0.38,
            child: Image(
              image: AssetImage(image),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[800]),
            ).tr(),
          ),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            height: 3,
            width: 150,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(40)),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800]),
            ).tr(),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class TodoWidget extends StatelessWidget {
  final Lugar placeData;
  const TodoWidget({required Key key, required this.placeData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: GridView.count(
            padding: EdgeInsets.all(0),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              InkWell(
                child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.blueAccent[400],
                                      offset: Offset(5, 5),
                                      blurRadius: 2)
                                ]),
                            child: Icon(
                              LineIcons.hand_o_left,
                              size: 30,
                            ),
                          ),
                          Text(
                            'travel guide',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ).tr(),
                        ])),
                onTap: () => nextScreen(context, GuidePage(d: placeData)),
              ),
            ],
          ),
        )
      ],
    );
  }
}
*/
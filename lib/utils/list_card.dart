import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

String distancia(int minutos) {
  var d = Duration(minutes: minutos);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}

class ListCard extends StatelessWidget {
  final Lugar? d;
  final String? tag;
  final Color? color;
  const ListCard(
      {Key? key, @required this.d, @required this.tag, @required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        children: <Widget>[
          Container(
            // color: Colors.red,
            alignment: Alignment.bottomRight,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(right: 10, left: 10),
            //color: Colors.grey[200],
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              // borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  //  color: Colors.green,

                  margin:
                      EdgeInsets.only(top: 0, left: 5, right: 10, bottom: 0),
                  alignment: Alignment.topLeft,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, left: 135),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          d!.nombre!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.mapMarker,
                              size: 12,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Text(
                                d!.direccion!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8, bottom: 20),
                          height: 2,
                          width: 120,
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.heart,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              d!.love.toString(),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(
                              FontAwesomeIcons.comment,
                              size: 18,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              d!.comentario.toString(),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                            Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: 1.2,
              bottom: 1.2,
              left: 11.2,
              child: Hero(
                tag: tag!,
                child: Container(
                    color: Colors.grey,
                    height: 120,
                    width: 120,
                    child: ClipRRect(
                        // borderRadius: BorderRadius.circular(5),
                        child: (d!.primeraimagen != null)
                            ? CustomCacheImage(imageUrl: d!.primeraimagen!)
                            : Image.asset(
                                "assets/images/no-imagen-company.jpg",
                              ))),
              ))
        ],
      ),
      onTap: () => nextScreen(context, PlaceDetails(data: d, tag: tag!)),
    );
  }

  requireStringNotNull(String? definitelyString) {
    print(definitelyString!.length);
  }
}

class ListCardNearby extends StatelessWidget {
  final Lugar? d;
  final String? tag;
  final Color? color;
  final String? tipo;
  const ListCardNearby(
      {Key? key,
      required this.d,
      required this.tag,
      required this.color,
      required this.tipo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        children: <Widget>[
          Container(
            // color: Colors.red,
            alignment: Alignment.bottomRight,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(right: 10, left: 10),
            //color: Colors.grey[200],
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              // borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  //  color: Colors.green,
                  decoration: BoxDecoration(
                    // color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin:
                      EdgeInsets.only(top: 0, left: 5, right: 10, bottom: 0),
                  alignment: Alignment.topLeft,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, left: 135),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          d!.nombre!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (tipo == "miubicacion")
                          Row(
                            children: [
                              Icon(
                                Icons.drive_eta_outlined,
                                size: 15,
                                color: Colors.grey[400],
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Expanded(
                                child: Text(
                                  '${distancia((d!.duracion! / 60).floor())}' +
                                      " " +
                                      'minutes'.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.mapMarker,
                                size: 12,
                                color: Colors.grey[400],
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Expanded(
                                child: Text(
                                  d!.direccion!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        Container(
                          margin: EdgeInsets.only(top: 8, bottom: 20),
                          height: 2,
                          width: 120,
                          decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.heart,
                              size: 15,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              d!.love.toString(),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(
                              FontAwesomeIcons.comment,
                              size: 15,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              d!.comentario.toString(),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                            Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: 1.2,
              bottom: 1.2,
              left: 11.2,
              child: Hero(
                tag: tag!,
                child: Container(
                    height: 120,
                    width: 120,
                    child: ClipRRect(
                        //  borderRadius: BorderRadius.circular(5),
                        child: (d!.primeraimagen != null)
                            ? CustomCacheImage(imageUrl: d!.primeraimagen!)
                            : Image.asset(
                                "assets/images/no-imagen-company.jpg",
                              ))),
              ))
        ],
      ),
      onTap: () => nextScreen(context, PlaceDetails(data: d, tag: tag!)),
    );
  }

  requireStringNotNull(String? definitelyString) {
    print(definitelyString!.length);
  }
}

class ListCard1 extends StatelessWidget {
  final Lugar? d;
  final String? tag;
  const ListCard1({Key? key, @required this.d, this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.bottomRight,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 5, bottom: 5),
            //color: Colors.grey[200],
            child: Stack(
              children: <Widget>[
                Container(
                  margin:
                      EdgeInsets.only(top: 5, left: 30, right: 10, bottom: 5),
                  alignment: Alignment.topLeft,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, left: 110),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          d!.nombre!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.map,
                              size: 12,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Text(
                                d!.direccion!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8, bottom: 20),
                          height: 2,
                          width: 120,
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              LineIcons.heart,
                              size: 18,
                              color: Colors.orangeAccent,
                            ),
                            Text(
                              '',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(
                              LineIcons.comment,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                            Text(
                              'comment',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                            Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.031,
              left: 10,
              child: Hero(
                tag: tag!,
                child: Container(
                    height: 120,
                    width: 120,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CustomCacheImage(imageUrl: d!.primeraimagen!))),
              ))
        ],
      ),
      onTap: () => nextScreen(context, PlaceDetails(data: d, tag: "yt")),
    );
  }
}

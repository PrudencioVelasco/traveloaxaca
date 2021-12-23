import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:traveloaxaca/models/compania.dart';
import 'package:traveloaxaca/pages/compania/detalle_compania.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListCardCompania extends StatelessWidget {
  final Compania? d;
  final String? tag;
  final Color? color;
  const ListCardCompania(
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
            padding: EdgeInsets.only(top: 15, bottom: 0),
            //color: Colors.grey[200],
            child: Stack(
              children: <Widget>[
                Container(
                  //  color: Colors.green,
                  decoration: BoxDecoration(
                    color: color,
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
              top: 40,
              bottom: 30,
              left: 10,
              child: Hero(
                tag: tag!,
                child: Container(
                    height: 120,
                    width: 120,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: (d!.primeraimagen != null)
                            ? CustomCacheImage(imageUrl: d!.primeraimagen!)
                            : Image.asset(
                                "assets/images/no-image.png",
                              ))),
              ))
        ],
      ),
      //onTap: () => nextScreen(context, PlaceDetails(data: d, tag: tag!)),
    );
  }

  requireStringNotNull(String? definitelyString) {
    print(definitelyString!.length);
  }
}

class ListCardCompaniaCerca extends StatelessWidget {
  final Compania? d;
  final String? tag;
  final Color? color;
  const ListCardCompaniaCerca(
      {Key? key, @required this.d, @required this.tag, @required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            //  color: Colors.red,
            alignment: Alignment.bottomRight,
            width: MediaQuery.of(context).size.width,
            //padding: EdgeInsets.only(top: 15, bottom: 0),
            //color: Colors.grey[200],
            child: Stack(
              children: <Widget>[
                Container(
                  //  color: Colors.green,
                  decoration: BoxDecoration(
                    //color: Colors.red,
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
                        Row(
                          children: [
                            RatingBar.builder(
                              // ignoreGestures: true,
                              itemSize: 20,
                              initialRating: d!.rating!,
                              ignoreGestures: true,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                //_rating = rating;
                                //print(rating);
                              },
                            ),
                            Text("(" + d!.comentario.toString() + ")")
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
              top: 40,
              bottom: 30,
              left: 10,
              child: Hero(
                tag: tag!,
                child: Container(
                    height: 120,
                    width: 120,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: (d!.primeraimagen != null)
                            ? CustomCacheImage(imageUrl: d!.primeraimagen!)
                            : Image.asset(
                                "assets/images/no-image.png",
                              ))),
              ))
        ],
      ),
      onTap: () => nextScreen(context, DetalleCompaniaPage(compania: d)),
    );
  }

  requireStringNotNull(String? definitelyString) {
    print(definitelyString!.length);
  }
}

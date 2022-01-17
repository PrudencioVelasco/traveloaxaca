import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/src/provider.dart';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class RecienVisitadoPage extends StatefulWidget {
  const RecienVisitadoPage({Key? key}) : super(key: key);

  @override
  _RecienVisitadoPageState createState() => _RecienVisitadoPageState();
}

class _RecienVisitadoPageState extends State<RecienVisitadoPage> {
  int _selectedIndex = 0;
  LugarBloc _lugarBloc = new LugarBloc();
  List<Lugar?> _listLugares = [];
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _lugarBloc.init(context, refresh);
      // _tourBloc.init(context, refresh);
    });
  }

  void getAllTours() async {
    _listLugares = await _lugarBloc.obtenerLugaresRecienVisitados();
    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<LugarBloc>();
    return Column(
      // padding: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 15),
      children: <Widget>[
        if (sb.recentSearchDataLugar.length > 0)
          Container(
            margin: EdgeInsets.only(left: 5, top: 10, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: 10,
                    top: 10,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'recently viewed',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ).tr(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    height: 260,
                    //color: Colors.green,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: sb.recentSearchDataLugar.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _botones(sb.recentSearchDataLugar[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _botones(Lugar? item) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, PlaceDetails(data: item, tag: 'recienvisitado'));
      },
      child: Card(
        semanticContainer: true,

        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // if you need this
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(5),
        elevation: 10,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: (item!.primeraimagen != null)
                        ? item.primeraimagen!
                        : 'https://misicebucket.s3.us-east-2.amazonaws.com/no-image-horizontal.png',
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
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 160,
                    height: 50,
                    //color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        item.nombre!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                //color: Colors.blueAccent,
                height: 30,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: RatingBar.builder(
                        // ignoreGestures: true,
                        itemSize: 20,
                        initialRating: item.rating!,
                        ignoreGestures: true,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        //itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star_border_outlined,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          //_rating = rating;
                          //print(rating);
                        },
                      ),
                    ),
                    Text(
                      "(" + item.comentario.toString() + ")",
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}

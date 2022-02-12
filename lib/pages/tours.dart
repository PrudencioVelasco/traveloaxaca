import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:traveloaxaca/blocs/tour_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/models/tour.dart';
import 'package:traveloaxaca/pages/tour/detalle_tour.dart';
import 'package:traveloaxaca/pages/tour/todos.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class ToursPage extends StatefulWidget {
  ToursPage({Key? key}) : super(key: key);

  @override
  _ToursPageState createState() => _ToursPageState();
}

class _ToursPageState extends State<ToursPage> {
  List<Tour?> _listaTours = [];
  TourBloc _tourBloc = new TourBloc();
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _tourBloc.init(context, refresh);
    });
    getAllTours();
  }

  void getAllTours() async {
    _listaTours = (await _tourBloc.todosLosTours(null));
    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_listaTours.length == 0)
        ? Container()
        : Column(
            // padding: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 15),
            children: <Widget>[
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
                            'best tours',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ).tr(),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () =>
                                nextScreen(context, TodosToursPage()),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        height: 292,
                        //color: Colors.green,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount:
                              _listaTours.isEmpty ? 3 : _listaTours.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (_listaTours.isEmpty)
                              return LoadingListaToursPrincipalCard();
                            return _chois(_listaTours[index]);
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

  Widget _chois(Tour? item) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, DetalleTourPage(tour: item));
      },
      child: Card(
        semanticContainer: true,

        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shape: RoundedRectangleBorder(
          //  borderRadius: BorderRadius.circular(10), // if you need this
          side: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),

        margin: EdgeInsets.all(5),
        //elevation: 10,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: (item!.imagenestour!.toList().isNotEmpty)
                        ? item.imagenestour!.toList().first.url.toString()
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
                    height: 42,
                    //color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 4, bottom: 4),
                      child: Text(
                        item.nombre!,
                        style: TextStyle(
                          fontSize: 15,
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
                        // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
                      "(" + item.totalcomentarios.toString() + ")",
                      style: TextStyle(fontSize: 11),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 160,
                    height: 50,
                    //color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 4, bottom: 4),
                      child: Text(
                        "agency".tr() + ": " + item.nombrecompania!,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}

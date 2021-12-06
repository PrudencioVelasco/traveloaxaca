import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:traveloaxaca/blocs/tour_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/models/tour.dart';
import 'package:traveloaxaca/pages/tour/detalle_tour.dart';
import 'package:traveloaxaca/pages/tour/todos.dart';
import 'package:traveloaxaca/utils/next_screen.dart';

class CategoriaPrincipalPage extends StatefulWidget {
  CategoriaPrincipalPage({Key? key}) : super(key: key);

  @override
  _CategoriaPrincipalPageState createState() => _CategoriaPrincipalPageState();
}

class _CategoriaPrincipalPageState extends State<CategoriaPrincipalPage> {
  List<Tour?> _listaTours = [];
  TourBloc _tourBloc = new TourBloc();
  int _selectedIndex = 0;
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
    return Column(

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
                          color: Colors.grey[800]),
                    ).tr(),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () => nextScreen(
                          context,TodosToursPage()),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  height: 220,
                  //color: Colors.green,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: _listaTours.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _botones2(_listaTours[index]);
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

  Widget _botones2(Tour? item) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, DetalleTourPage(tour: item));
      },
      child: Card(
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // if you need this
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(5),
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: (item!.imagenestour!.toList().isNotEmpty)
                    ? item.imagenestour!.toList().first.url.toString()
                    : 'https://img.theculturetrip.com/1440x807/smart/wp-content/uploads/2020/03/mexico1.jpg',
                placeholder: (context, url) => CircularProgressIndicator(),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
              Expanded(
                child: Container(
                  width: 150,
                  // height: 120,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      item.nombre!,
                      style: TextStyle(
                        fontSize: 18,
                        // fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 150,
                  height: 80,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: RatingBar.builder(
                      // ignoreGestures: true,
                      itemSize: 20,
                      initialRating: item.rating!,
                      ignoreGestures: true,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        //_rating = rating;
                        //print(rating);
                      },
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Widget _botones(Tour? item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: EdgeInsets.all(15),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Column(
          children: [
            FadeInImage.assetNetwork(
              placeholder: "assets/images/cargando.gif",
              image: (item!.imagenestour!.toList().isNotEmpty)
                  ? item.imagenestour!.toList().first.nombreimagen.toString()
                  : 'https://img.theculturetrip.com/1440x807/smart/wp-content/uploads/2020/03/mexico1.jpg',
              fit: BoxFit.cover,
              height: 260,
              width: 260,
            ),
            Container(
              color: Colors.red,
              padding: EdgeInsets.all(2.0),
              child: Text(item.nombre!),
            )
          ],
        ),
      ),
    );
  }

  /* Widget _chois(Tour? item) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 0),
        child: ChoiceChip(
          elevation: 5,
          pressElevation: 5,
          label: Text(
            item!.nombre!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          shape: StadiumBorder(side: BorderSide()),
          selected: _selectedIndex == item.idclasificacion,
          padding: EdgeInsets.all(18),
          labelStyle: TextStyle(color: Colors.black),
          backgroundColor: Colors.white,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedIndex = item.idclasificacion!;
              }
            });
          },
        ),
      ),
    );
  }*/
}

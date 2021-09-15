import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:line_icons/line_icons.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/more_places.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

class PopularPlaces extends StatefulWidget {
  PopularPlaces({Key? key}) : super(key: key);

  _PopularPlaces createState() => _PopularPlaces();
}

class _PopularPlaces extends State<PopularPlaces> {
  int listIndex = 2;
  PopularPlacesBloc pb = new PopularPlacesBloc();
  List<Lugar?> lugar = [];
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) async {
      pb.init(context, refresh);
      getAllCategorias();
    });
    refresh();
  }

  void getAllCategorias() async {
    lugar = (await pb.getData())!;
    refresh();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            left: 15,
            top: 10,
          ),
          child: Row(
            children: <Widget>[
              Text(
                'popular places',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800]),
              ).tr(),
              Spacer(),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () => nextScreen(
                    context,
                    MorePlacesPage(
                      title: 'popular',
                      color: Colors.grey,
                    )),
              )
            ],
          ),
        ),
        Container(
          height: 220,
          //color: Colors.green,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 15, right: 15),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: lugar.isEmpty ? 3 : lugar.length,
            itemBuilder: (BuildContext context, int index) {
              if (lugar.isEmpty) return LoadingPopularPlacesCard();
              return ItemList(
                d: lugar[index],
              );
              //return LoadingCard1();
            },
          ),
        )
      ],
    );
  }
}

class ItemList extends StatelessWidget {
  final Lugar? d;
  const ItemList({Key? key, @required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
        width: MediaQuery.of(context).size.width * 0.36,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Hero(
              tag: 'popular timespan',
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomCacheImage(imageUrl: d!.primeraimagen!)),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0, left: 0, right: 0),
                child: Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(d!.nombre!,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    right: 15,
                  ),
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[600],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LineIcons.heart, size: 16, color: Colors.white),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          d!.love!.toString(),
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
      onTap: () => nextScreen(
          context, PlaceDetails(data: d!, tag: 'popular${d!.idlugar!}')),
    );
  }
}

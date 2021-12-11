import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:traveloaxaca/blocs/featured_bloc.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:flutter/scheduler.dart';

class Featured extends StatefulWidget {
  Featured({Key? key}) : super(key: key);

  _FeaturedState createState() => _FeaturedState();
}

class _FeaturedState extends State<Featured> {
  int listIndex = 2;
  FeaturedBloc fb = new FeaturedBloc();
  List<Lugar?> lugar = [];
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      fb.init(context, refresh);
      obtenerLugaresPrincipales();
    });
  }

  void obtenerLugaresPrincipales() async {
    lugar = (await fb.getData())!;
    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 260,
          width: w,
          child: PageView.builder(
            controller: PageController(initialPage: 2),
            scrollDirection: Axis.horizontal,
            itemCount: lugar.isEmpty ? 1 : lugar.length,
            onPageChanged: (index) {
              setState(() {
                listIndex = index;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              if (lugar.isEmpty) return LoadingFeaturedCard();
              return _FeaturedItemList(d: lugar[index]);
            },
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Center(
          child: DotsIndicator(
            dotsCount: 5,
            position: listIndex.toDouble(),
            decorator: DotsDecorator(
              color: Colors.black26,
              activeColor: Colors.black,
              spacing: EdgeInsets.only(left: 6),
              size: const Size.square(5.0),
              activeSize: const Size(20.0, 4.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
          ),
        )
      ],
    );
  }
}

class _FeaturedItemList extends StatelessWidget {
  final Lugar? d;
  const _FeaturedItemList({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      width: w,
      child: InkWell(
        child: Stack(
          children: <Widget>[
            Hero(
              tag: 'featured${d!.idlugar}',
              child: Container(
                //color: Colors.grey[300],
                height: 220,
                width: w,
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (d!.primeraimagen != null)
                      ? CustomCacheImage(imageUrl: d!.primeraimagen)
                      : Image.asset(
                          "assets/images/no-image.png",
                        ),
                ),
              ),
            ),
            Positioned(
              height: 120,
              width: w * 0.70,
              left: w * 0.11,
              bottom: 10,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 2),
                          blurRadius: 2)
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          d!.nombre!,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: Text(
                              d!.direccion!,
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      Divider(
                        color: Colors.grey[300],
                        height: 20,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              LineIcons.heart,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              d!.love!.toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700]),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Icon(
                              LineIcons.comment,
                              size: 18,
                              color: Colors.blue[300],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              d!.comentario!.toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700]),
                            ),
                            Spacer(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          nextScreen(
              context, PlaceDetails(data: d!, tag: 'featured${d!.idlugar}'));
        },
      ),
    );
  }
}

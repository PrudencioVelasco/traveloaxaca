import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:line_icons/line_icons.dart';
import 'package:traveloaxaca/blocs/sitiosinteres_bloc.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/models/sitiosinteres.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'custom_cache_image.dart';
import 'package:easy_localization/easy_localization.dart';

class SitiosInteresPage extends StatefulWidget {
  final int idlugar;
  SitiosInteresPage({Key? key, required this.idlugar}) : super(key: key);

  @override
  _SitiosInteresPageState createState() => _SitiosInteresPageState();
}

class _SitiosInteresPageState extends State<SitiosInteresPage> {
  SitiosInteresBloc _sitiosInteresBloc = new SitiosInteresBloc();
  List<SitiosInteres> _sitiosInteres = [];
  @override
  void initState() async {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      // _con.init(context);
      _sitiosInteresBloc.init(context, refresh);
    });
    getData();
    refresh();
  }

  void getData() async {
    _sitiosInteres =
        (await _sitiosInteresBloc.getSitiosInteres(widget.idlugar))!;
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //  final ob = context.watch<SitiosInteresBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            left: 0,
            top: 10,
          ),
          child: Text(
            'you may also like',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ).tr(),
        ),
        Container(
          margin: EdgeInsets.only(top: 8, bottom: 8),
          height: 3,
          width: 100,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40)),
        ),
        Container(
          height: 220,
          //color: Colors.green,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15, top: 5),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: _sitiosInteres.isEmpty ? 3 : _sitiosInteres.length,
            itemBuilder: (BuildContext context, int index) {
              if (_sitiosInteres.isEmpty) return LoadingPopularPlacesCard();
              return ItemList(
                d: _sitiosInteres[index],
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
  final SitiosInteres d;
  const ItemList({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
        width: MediaQuery.of(context).size.width * 0.35,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                child: Text(
                  d.nombre!,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
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
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LineIcons.heart, size: 16, color: Colors.white),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'ss',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),

      //  onTap: () => nextScreen(context, PlaceDetails(data: d, tag: 'others${d.timestamp}')),
    );
  }
}

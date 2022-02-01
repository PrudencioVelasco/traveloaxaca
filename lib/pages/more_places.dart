import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/place_details.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/custom_cache_image.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

class MorePlacesPage extends StatefulWidget {
  final String title;
  final Color color;
  MorePlacesPage({Key? key, required this.title, required this.color})
      : super(key: key);

  @override
  _MorePlacesPageState createState() => _MorePlacesPageState();
}

class _MorePlacesPageState extends State<MorePlacesPage> {
  final String collectionName = 'places';
  ScrollController? _controller;
  bool? _lastVisible;
  bool? _isLoading;
  //List<Lugar> _data = [];
  //bool? _descending;
  //String? _orderBy;
  List<Lugar?> _lugares = [];
  PopularPlacesBloc pb = new PopularPlacesBloc();
  @override
  void initState() {
    // controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    //_getData();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) async {
      pb.init(context, refresh);
      _getAllLugaresPolulares();
    });
    //_getAllLugaresPolulares();
    refresh();
    // _getAllLugaresPolulares();
  }

  void _getAllLugaresPolulares() async {
    _lugares = (await pb.getData())!;
    //_isLoading = true;
    if (_lugares.length > 0) {
      _lastVisible = true;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
    refresh();
  }

  void refresh() {
    setState(() {});
  }

  onRefresh() {
    setState(() {
      // _snap.clear();
      _lugares.clear();
      _isLoading = true;
      _lastVisible = false;
    });
    _getAllLugaresPolulares();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading!) {
      if (_controller!.position.pixels ==
          _controller!.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getAllLugaresPolulares();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child: CustomScrollView(
          controller: _controller,
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              backgroundColor: widget.color,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                background: Container(
                  color: widget.color,
                  height: 120,
                  width: double.infinity,
                ),
                title: Text(
                  '${widget.title} places',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ).tr(),
                titlePadding: EdgeInsets.only(left: 20, bottom: 15),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(15),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _lugares.length) {
                      return _ListItem(
                        d: _lugares[index]!,
                        tag: '${widget.title}$index',
                      );
                    }
                    return Opacity(
                      opacity: _isLoading! ? 1.0 : 0.0,
                      child: _lastVisible == false
                          ? Column(
                              children: [
                                LoadingCard(
                                  height: 180,
                                ),
                                SizedBox(
                                  height: 15,
                                )
                              ],
                            )
                          : Center(
                              child: SizedBox(
                                  width: 32.0,
                                  height: 32.0,
                                  child: new CupertinoActivityIndicator()),
                            ),
                    );
                  },
                  childCount: _lugares.length == 0 ? 5 : _lugares.length + 1,
                ),
              ),
            )
          ],
        ),
        onRefresh: () async => onRefresh(),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final Lugar d;
  final tag;
  const _ListItem({Key? key, required this.d, required this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 10),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      color: Colors.white,
                    ),
                    //
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Hero(
                      tag: tag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5)),
                        child: (d.primeraimagen != null)
                            ? CachedNetworkImage(
                                imageUrl: d.primeraimagen!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
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
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                // height: height,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "assets/images/no-image.png",
                              ),
                      ),
                    )),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.nombre!,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.map,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Text(
                              d.direccion!,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            // height: 150,
                            // color: Colors.green,
                            padding: EdgeInsets.only(bottom: 4),
                            //margin: EdgeInsets.only(bottom: 60),
                            child: RatingBar.builder(
                              // ignoreGestures: true,
                              itemSize: 28,
                              initialRating: d.rating!,
                              ignoreGestures: true,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              // itemPadding:
                              //     EdgeInsets.symmetric(horizontal: 4.0),
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
                          Spacer(),
                          Icon(
                            FontAwesomeIcons.heart,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            d.love.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600]),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            FontAwesomeIcons.comments,
                            color: Colors.blue[300],
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            d.comentario.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600]),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
      onTap: () => nextScreen(context, PlaceDetails(data: d, tag: tag)),
    );
  }
}

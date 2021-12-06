import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:traveloaxaca/blocs/tour_bloc.dart';
import 'package:traveloaxaca/models/tour.dart';
import 'package:traveloaxaca/pages/tour/detalle_tour.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/list_card.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/snacbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
List<String> allNames = ["ahmed", "ali", "john", "user"];
var mainColor = Color(0xff1B3954);
var textColor = Color(0xff727272);
var accentColor = Color(0xff16ADE1);
var whiteText = Color(0xffF5F5F5);

class TodosToursPage extends StatefulWidget {
  @override
  State<TodosToursPage> createState() => TodosToursPageState();
}

class TodosToursPageState extends State<TodosToursPage> {
  String? _sortValue;

  String? _ascValue;
  List<Tour?> _listaTours = [];
  List<Tour?> _listaToursOriginal = [];
  TourBloc _tourBloc = new TourBloc();
  String _parametro = "";
  bool cargando = true;
  TextEditingController _textsearch = new TextEditingController();
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _tourBloc.init(context, refresh);
    });
     getAllTours();
    getAllToursOriginal();
    refresh();
  }

   Future getAllTours() async {
    _listaTours  = (await _tourBloc.todosLosTours(null));
    setState(() {
      cargando =false;
    });
   refresh();
  }

  Future getAllToursOriginal() async {
    _listaToursOriginal  = (await _tourBloc.todosLosTours(null));
    // _listaToursOriginal = (await _tourBloc.todosLosTours(null));
    // refresh();
  }
  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void filtrar() {}
  List<Map> _listaRating = [
    {"id": 1, "nombre": "1 start".tr()},
    {"id": 2, "nombre": "2 start".tr()},
    {"id": 3, "nombre": "3 start".tr()},
    {"id": 4, "nombre": "4 start".tr()},
    {"id": 5, "nombre": "5 start".tr()},
  ];
  List<Map> _listaComLove = [
    {"id": 1, "nombre": "more reviews".tr()},
    {"id": 2, "nombre": "more loves".tr()},
  ];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double  itemHeight = (size.height - kToolbarHeight-24);
    final double itemWidt = size.width/2;
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
            return <Widget>[
              SliverAppBar(
                forceElevated: true,
                elevation: 4,
                floating: true,
                snap: true,
                title: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    child: TextField(
                      controller: _textsearch,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: ()  {
                             btnCancelar();
                            },
                          ),
                          hintText: 'Search...',
                          border: InputBorder.none),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        setState(() {
                          _parametro = value;
                        });
                        btnBuscar();
                      },
                    ),
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                    ),
                    onPressed: () {
                      showFilterDialog(context);
                    },
                  ),
                ],
              ),
            ];
          },
          body: Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Column(
              children: [
                if(cargando)
            Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200.0,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        child: new CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          strokeWidth: 5,
                        ),
                      ),
                    ),
                    Center(child: Text("loading...",style: TextStyle(color: Colors
                        .black,
                        fontSize:
                        12,
                        fontWeight:
                        FontWeight
                            .w600),).tr(),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
if(!cargando)
  _cartas()
              ],
            ),
          )),
    );
  }

  Widget _cartas() {
    return GridView.builder(
      itemCount: _listaTours.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
        mainAxisExtent: 220,
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            nextScreen(context, DetalleTourPage(tour: _listaTours[index]));
          },
          child: Card(

            // semanticContainer: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              // margin: EdgeInsets.all(10),
              elevation: 10,
              child: ClipRRect(
                // borderRadius: BorderRadius.circular(10),

                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CachedNetworkImage(
                            imageUrl: (_listaTours[index]!
                                .imagenestour!
                                .toList()
                                .isNotEmpty)
                                ? _listaTours[index]!
                                .imagenestour!
                                .toList()
                                .first
                                .url
                                .toString()
                                : 'https://img.theculturetrip.com/1440x807/smart/wp-content/uploads/2020/03/mexico1.jpg',
                            placeholder: (context, url) => SizedBox(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.cyanAccent,
                                valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                              height: 100.0,
                              width: 100.0,
                            ),
                            width: 300,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            //color: Colors.greenAccent,
                            padding: EdgeInsets.only(left:5,top: 3),
                            height: 40,
                            child: Expanded(

                              //padding: EdgeInsets.only(left: 4, top: 16, right: 4),
                              child: Text(
                                _listaTours[index]!.nombre!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Container(
                            // height: 150,
                           // color: Colors.green,
                            padding: EdgeInsets.only(bottom: 4),
                            //margin: EdgeInsets.only(bottom: 60),
                            child: RatingBar.builder(
                              // ignoreGestures: true,
                              itemSize: 20,
                              initialRating: _listaTours[index]!.rating!,
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
                          Expanded(

                            child: RichText(
                              text: TextSpan(
                                  children: [

                                    WidgetSpan(
                                        child:  Container(
                                        padding:EdgeInsets.only(right: 5,left: 5),
                                            child: Icon( FontAwesomeIcons.solidHeart,size: 17,color: Colors.red,)
                                        )
                                    ),

                                    TextSpan(
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        text:  _listaTours[index]!.totalloves.toString()

                                    ),
                                    WidgetSpan(
                                        child:  Container(
                                            padding:EdgeInsets.only(right: 5,left: 5),
                                            child: Icon(  FontAwesomeIcons.comments,size: 17, color: Colors.blue[300],)
                                        )
                                    ),

                                    TextSpan(
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        text:  _listaTours[index]!.totalcomentarios.toString()

                                    ),
                                  ]
                              ),
                            ),
                          )

                        ],
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }

  void btnCancelar() async {
    _listaToursOriginal = [];
    if(_parametro.isNotEmpty){
      _listaToursOriginal = await _tourBloc.todosLosTours(_parametro);
    }else{
      _listaToursOriginal = await _tourBloc.todosLosTours(null);
    }
    setState(()   {
      _ascValue = null;
      _sortValue = null;
      _listaTours=_listaToursOriginal;
    });
  }

  void btnBuscar() async {
    List<Tour?> filteredStrings = [];
    _listaTours = [];
    int opcion = 0;
    if (_parametro.isNotEmpty) {
      opcion = 1;
      _listaToursOriginal = [];
      _listaToursOriginal = await _tourBloc.todosLosTours(_parametro);
    }
    if (_sortValue != null) {
      opcion = 0;
      filteredStrings = _listaToursOriginal
          .where((item) =>
              item!.rating == int.parse(_sortValue.toString()).toDouble())
          .toList();

    }
    if (_ascValue != null) {
      if (_ascValue!.toString() == "1") {
        if (_sortValue != null) {
          opcion = 0;
          filteredStrings.sort((a, b) =>
              a!.totalloves!.toInt().compareTo(b!.totalloves!.toInt()));
        } else {
          opcion = 1;
          _listaToursOriginal.sort((a, b) =>
              a!.totalloves!.toInt().compareTo(b!.totalloves!.toInt()));
        }
      }
      if (_ascValue!.toString() == "2") {
        if (_sortValue != null) {
          opcion = 0;
          filteredStrings.sort((a, b) => a!.totalcomentarios!
              .toInt()
              .compareTo(b!.totalcomentarios!.toInt()));
        } else {
          opcion = 1;
          _listaToursOriginal.sort((a, b) => a!.totalcomentarios!
              .toInt()
              .compareTo(b!.totalcomentarios!.toInt()));
        }
      }
    }

    setState(() {
      _listaTours = (opcion == 1)
          ? _listaToursOriginal
          : filteredStrings;
    });
  }

  Future<void> showFilterDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext build) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Center(
                  child: Text(
                "Filter",
                style: TextStyle(color: mainColor),
              )),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 12, right: 10),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.sort,
                              color: Color(0xff808080),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text("sort by").tr(),
                                isDense: true,
                                items: _listaRating.map((Map value) {
                                  return DropdownMenuItem(
                                    value: value["id"].toString(),
                                    child: Text(value["nombre"].toString(),
                                        style: TextStyle(
                                            color: textColor, fontSize: 16)),
                                  );
                                }).toList(),
                                value: _sortValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    _sortValue = newValue;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 8, right: 10),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.sort_by_alpha,
                              color: Color(0xff808080),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text("reactions").tr(),
                                items: _listaComLove.map((Map value) {
                                  return DropdownMenuItem(
                                    value: value["id"].toString(),
                                    child: Text(value["nombre"].toString(),
                                        style: TextStyle(
                                            color: textColor, fontSize: 16)),
                                  );
                                }).toList(),
                                value: _ascValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    _ascValue = newValue;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              child: Text("clean").tr(),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                onSurface: Colors.black,
                                //shadowColor: Colors.grey,
                                padding: EdgeInsets.all(10.0),
                                elevation: 2,

                                shape: RoundedRectangleBorder(
                                    side: BorderSide(),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onPressed: () {
                                Navigator.pop(context, true);
                                btnCancelar();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              child: Text("filter").tr(),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                onSurface: Colors.black,
                                //shadowColor: Colors.grey,
                                padding: EdgeInsets.all(10.0),
                                elevation: 2,

                                shape: RoundedRectangleBorder(
                                    side: BorderSide(),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onPressed: () {
                                btnBuscar();
                                Navigator.pop(context, true);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}

class Rating {
  int? id;
  String? nombre;
  Rating({
    this.id,
    this.nombre,
  });
}

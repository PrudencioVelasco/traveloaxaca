import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:traveloaxaca/blocs/search_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/list_card.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/snacbar.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  SearchBloc _con = new SearchBloc();
  String inputText = "";
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'PLACE'),
    Tab(text: 'MAP'),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(145),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: Column(
            children: [
              SizedBox(height: 50),
              _textFielSearch(),
              Container(
                child: Text('Maps'),
              )
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.green,
            controller: _tabController,
            isScrollable: true,
            unselectedLabelColor: Colors.black,
            tabs: myTabs,
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: Colors.red),
                insets: EdgeInsets.symmetric(horizontal: 0.0)),

//        /  indicatorPadding: EdgeInsets.all(0.0),
            indicatorWeight: 4.0,
            labelPadding: EdgeInsets.only(left: 30.0, right: 30.0),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          final String label = tab.text!.toLowerCase();
          if (label == "place") {
            if (_con.searchStarted == true) {
              return Expanded(
                child: FutureBuilder(
                  future: _con.getData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length == 0)
                        return EmptyPage(
                          icon: Icons.beach_access,
                          message: 'no places found',
                          message1: "try again",
                        );
                      else
                        return ListView.separated(
                          padding: EdgeInsets.all(10),
                          itemCount: snapshot.data.length,
                          separatorBuilder: (context, index) => SizedBox(
                            height: 5,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return ListCard(
                              d: snapshot.data[index],
                              tag: "search$index",
                              color: Colors.white,
                            );
                          },
                        );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.all(15),
                      itemCount: 5,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return LoadingCard(height: 120);
                      },
                    );
                  },
                ),
              );
            } else {
              return Text('LIMIP');
            }
          } else {
            return Text('data');
          }
        }).toList(),
      ),
    );
  }

  Widget _textFielSearch() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            controller: _con.textfieldCtrl,
            onSubmitted: (value) {
              _con.getData();
              inputText = value;
              if (value == '') {
                openSnacbar(scaffoldKey, 'Type something!');
              } else {
                _con.setSearchText(value);
                _con.addToSearchList(value);
              }
            },
            decoration: InputDecoration(
              hintText: 'Buscar..',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10, right: 15),
                child: IconButton(
                  icon: Icon(
                    Icons.keyboard_backspace,
                    color: Colors.grey[800],
                  ),
                  color: Colors.grey[800],
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.grey[800],
                  size: 25,
                ),
                onPressed: () {
                  _con.saerchInitialize();
                },
              ),
              hintStyle: TextStyle(fontSize: 17, color: Colors.grey[500]),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey),
              ),
              contentPadding: EdgeInsets.all(15),
            ),
            textInputAction: TextInputAction.search,
          ),
        ],
      ),
    );
  }

  Widget hidingIcon() {
    return IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.red,
        ),
        splashColor: Colors.redAccent,
        onPressed: () {
          setState(() {
            _con.textfieldCtrl.clear();
            inputText = "";
          });
        });
  }
}

class AfterSearchUI extends StatelessWidget {
  const AfterSearchUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SearchBloc sb = new SearchBloc();
    return Expanded(
      child: FutureBuilder(
        future: sb.getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0)
              return EmptyPage(
                icon: Icons.beach_access,
                message: 'no places found',
                message1: "try again",
              );
            else
              return ListView.separated(
                padding: EdgeInsets.all(10),
                itemCount: snapshot.data.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: 5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return ListCard(
                    d: snapshot.data[index],
                    tag: "search$index",
                    color: Colors.white,
                  );
                },
              );
          }
          return ListView.separated(
            padding: EdgeInsets.all(15),
            itemCount: 5,
            separatorBuilder: (BuildContext context, int index) => SizedBox(
              height: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              return LoadingCard(height: 120);
            },
          );
        },
      ),
    );
  }
}

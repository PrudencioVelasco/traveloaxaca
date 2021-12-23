import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/src/provider.dart';
import 'package:traveloaxaca/blocs/busqueda_next_bloc.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/list_card.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/snacbar.dart';
import 'package:easy_localization/easy_localization.dart';

class BuscarNextPage extends StatefulWidget {
  const BuscarNextPage({Key? key}) : super(key: key);

  @override
  _BuscarNextPageState createState() => _BuscarNextPageState();
}

class _BuscarNextPageState extends State<BuscarNextPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Future.delayed(Duration())
        .then((value) => context.read<BusquedaNextBloc>().saerchInitialize());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //search bar

            Container(
              alignment: Alignment.center,
              height: 56,
              width: w,
              // decoration: BoxDecoration(color: Colors.white),
              child: TextFormField(
                autofocus: true,
                controller: context.watch<BusquedaNextBloc>().textfieldCtrl,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "search & explore".tr(),
                  hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600]),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 15),
                    child: IconButton(
                      icon: Icon(
                        Icons.keyboard_backspace,
                        //   color: Colors.grey[800],
                      ),
                      color: Colors.grey[600],
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 25,
                    ),
                    onPressed: () {
                      context.read<BusquedaNextBloc>().saerchInitialize();
                    },
                  ),
                ),
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (value) {
                  if (value == '') {
                    openSnacbar(scaffoldKey, 'Type something!');
                  } else {
                    context.read<BusquedaNextBloc>().setSearchText(value);
                    context.read<BusquedaNextBloc>().addToSearchList(value);
                  }
                },
              ),
            ),

            Container(
              height: 1,
              child: Divider(
                color: Colors.grey[300],
              ),
            ),

            // suggestion text

            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
              child: Text(
                context.watch<BusquedaNextBloc>().searchStarted == false
                    ? 'recent searchs'
                    : 'we have found',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline6,
              ).tr(),
            ),
            context.watch<BusquedaNextBloc>().searchStarted == false
                ? SuggestionsUI()
                : AfterSearchUI()
          ],
        ),
      ),
    );
  }
}

class SuggestionsUI extends StatelessWidget {
  const SuggestionsUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<BusquedaNextBloc>();
    return Expanded(
      child: sb.recentSearchData.isEmpty
          ? EmptyPage(
              icon: Icons.search,
              message: 'search for places'.tr(),
              message1: "search-description".tr(),
            )
          : ListView.builder(
              itemCount: sb.recentSearchData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    sb.recentSearchData[index],
                    style: TextStyle(fontSize: 17),
                  ),
                  leading: Icon(CupertinoIcons.time_solid),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      context
                          .read<BusquedaNextBloc>()
                          .removeFromSearchList(sb.recentSearchData[index]);
                    },
                  ),
                  onTap: () {
                    context
                        .read<BusquedaNextBloc>()
                        .setSearchText(sb.recentSearchData[index]);
                  },
                );
              },
            ),
    );
  }
}

class AfterSearchUI extends StatelessWidget {
  const AfterSearchUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: context.watch<BusquedaNextBloc>().getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0)
              return EmptyPage(
                icon: FeatherIcons.clipboard,
                message: 'no places found'.tr(),
                message1: "try again".tr(),
              );
            else
              return ListView.separated(
                // padding: EdgeInsets.all(10),
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/src/provider.dart';
import 'package:translator/translator.dart';
import 'package:traveloaxaca/blocs/compania_bloc.dart';
import 'package:traveloaxaca/pages/buscar/mi_ubicacion.dart';
import 'package:traveloaxaca/pages/buscar/permisogps.dart';
import 'package:traveloaxaca/utils/empty.dart';
import 'package:traveloaxaca/utils/list_card_compania.dart';
import 'package:traveloaxaca/utils/loading_cards.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/utils/snacbar.dart';
import 'package:easy_localization/easy_localization.dart';

class BuscarLugarCategoriaPage extends StatefulWidget {
  final String? nombre;
  final int? idclasificacion;
  const BuscarLugarCategoriaPage(
      {Key? key, required this.nombre, required this.idclasificacion})
      : super(key: key);

  @override
  _BuscarLugarCategoriaPageState createState() =>
      _BuscarLugarCategoriaPageState();
}

class _BuscarLugarCategoriaPageState extends State<BuscarLugarCategoriaPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final translator = GoogleTranslator();
  String nombre = "";
  @override
  void initState() {
    Future.delayed(Duration())
        .then((value) => context.read<CompaniaBloc>().saerchInitialize());
    super.initState();
  }

  Future<String> someFutureStringFunction(
      BuildContext context, String texto) async {
    Locale myLocale = Localizations.localeOf(context);
    if (myLocale.languageCode == "en") {
      var translation = await translator.translate(texto, from: 'es', to: 'en');
      return translation.toString();
    } else {
      return texto.toString();
    }
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
              //  decoration: BoxDecoration(color: Colors.white),
              child: TextFormField(
                autofocus: true,
                controller: context.watch<CompaniaBloc>().textfieldCtrl,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "search".tr(),
                  hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600]),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 15),
                    child: IconButton(
                      icon: Icon(
                        Icons.keyboard_backspace,
                        color: Colors.grey[600],
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
                      color: Colors.grey[800],
                      size: 25,
                    ),
                    onPressed: () {
                      context.read<CompaniaBloc>().saerchInitialize();
                    },
                  ),
                ),
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (value) {
                  if (value == '') {
                    openSnacbar(scaffoldKey, 'Type something!');
                  } else {
                    context.read<CompaniaBloc>().setSearchText(value);

                    ///context.read<CompaniaBloc>().addToSearchList(value);
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
            Container(
              margin: EdgeInsets.only(top: 10),
              height: 55,
              child: Expanded(
                child: ListTile(
                  title: FutureBuilder(
                      future: someFutureStringFunction(context, widget.nombre!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data.toString().toUpperCase() +
                              " " +
                              "nearby".tr().toUpperCase());
                        } else if (snapshot.hasError) {
                          return Text("error");
                        }
                        return Text("loading...".tr());
                      }),
                  leading: CircleAvatar(
                    child: Icon(FeatherIcons.mapPin),
                    backgroundColor: Colors.white,
                  ),
                  onTap: () {
                    nextScreen(
                        context,
                        PermisoGpsPage(
                          idclasificacion: widget.idclasificacion,
                          nombre: widget.nombre,
                        ));
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
              child: Text(
                context.watch<CompaniaBloc>().searchStarted == false
                    ? ''
                    : 'we have found',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline6,
              ).tr(),
            ),
            context.watch<CompaniaBloc>().searchStarted == false
                ? SuggestionsUI(nombre: widget.nombre)
                : AfterSearchUI(idclasificacion: widget.idclasificacion)
          ],
        ),
      ),
    );
  }
}

class SuggestionsUI extends StatefulWidget {
  final String? nombre;
  const SuggestionsUI({Key? key, required this.nombre}) : super(key: key);

  @override
  State<SuggestionsUI> createState() => _SuggestionsUIState();
}

class _SuggestionsUIState extends State<SuggestionsUI> {
  @override
  Widget build(BuildContext context) {
    final sb = context.watch<CompaniaBloc>();
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: sb.recentSearchData.isEmpty
                ? Column(
                    children: [
                      Expanded(
                          child: EmptyPage(
                        icon: Icons.search,
                        message: 'search for places'.tr(),
                        message1: "search-description".tr(),
                      ))
                    ],
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
                            /* context
                                .read<CompaniaBloc>()
                                .removeFromSearchList(
                                    sb.recentSearchData[index]);*/
                          },
                        ),
                        onTap: () {
                          context
                              .read<CompaniaBloc>()
                              .setSearchText(sb.recentSearchData[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AfterSearchUI extends StatefulWidget {
  final int? idclasificacion;
  const AfterSearchUI({Key? key, required this.idclasificacion})
      : super(key: key);

  @override
  State<AfterSearchUI> createState() => _AfterSearchUIState();
}

class _AfterSearchUIState extends State<AfterSearchUI> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: context.watch<CompaniaBloc>().getData(widget.idclasificacion!),
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
                //padding: EdgeInsets.all(10),
                itemCount: snapshot.data.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: 5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return ListCardCompaniaCerca(
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

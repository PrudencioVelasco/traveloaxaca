import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:traveloaxaca/pages/categoria_principal.dart';
import 'package:traveloaxaca/pages/perfil.dart';
import 'package:traveloaxaca/blocs/featured_bloc.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/featured_places.dart';
import 'package:traveloaxaca/widgets/popular_places.dart';
import 'package:easy_localization/easy_localization.dart';

class Explorar extends StatefulWidget {
  Explorar({Key? key}) : super(key: key);

  @override
  _ExplorarState createState() => _ExplorarState();
}

class _ExplorarState extends State<Explorar> {
  FeaturedBloc _featuredBloc = new FeaturedBloc();
  PopularPlacesBloc _popularPlacesBloc = new PopularPlacesBloc();
  CategoriaBloc _categoriaBloc = new CategoriaBloc();
  RutasBloc _rutasBloc = new RutasBloc();
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _featuredBloc.init(context, refresh);
      _popularPlacesBloc.init(context, refresh);
      _rutasBloc.init(context, refresh);
      _categoriaBloc.init(context, refresh);
    });
    Future.delayed(Duration(milliseconds: 0)).then((_) {
      _featuredBloc.getData();
      _popularPlacesBloc.getData();
      _rutasBloc.getData();
      _categoriaBloc.obtenerTodascategorias();
      //context.read<RecentPlacesBloc>().getData();
      //context.read<SpecialStateOneBloc>().getData();
      //context.read<SpecialStateTwoBloc>().getData();
      //context.read<RecommandedPlacesBloc>().getData();
    });
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black,
      ),
    );
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _featuredBloc.onRefresh();
              _popularPlacesBloc.onRefresh();
              _rutasBloc.onRefresh();
              _categoriaBloc.onRefresh();
              //context.read<RecentPlacesBloc>().onRefresh(mounted);
              //context.read<SpecialStateOneBloc>().onRefresh(mounted);
              //context.read<SpecialStateTwoBloc>().onRefresh(mounted);
              //context.read<RecommandedPlacesBloc>().onRefresh(mounted);
            },
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Header(),
                  Featured(),
                  PopularPlaces(),
                  //RutaPage(),
                  CategoriaPrincipalPage(),
                  // CategoriaPage(),
                  //RecentPlaces(),
                  //SpecialStateOne(),
                  //SpecialStateTwo(),
                  //RecommendedPlaces()
                ],
              ),
            ),
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;

  void refresh() {
    setState(() {});
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = Provider.of<SignInBloc>(context, listen: true);

    //  bool sb = true;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Config().appName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[800]),
                  ),
                  Text(
                    'explore country',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600]),
                  ).tr()
                ],
              ),
              Spacer(),
              InkWell(
                child: (sb.autenticando == false)
                    ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, size: 28),
                      )
                    : Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    sb.usuario!.imageUrl!),
                                fit: BoxFit.cover)),
                      ),
                onTap: () {
                  nextScreen(context, PerfilPage());
                },
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          /*InkWell(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 5, right: 5),
              padding: EdgeInsets.only(left: 15, right: 15),
              height: 40,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'search places',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ).tr(),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          )*/
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.green,
      padding: EdgeInsets.only(top: 10, bottom: 5, left: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Config().appName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700]),
              ),
              Text(
                'Explore ${Config().countryName}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600]),
              )
            ],
          ),
          Spacer(),
          IconButton(
              icon: Icon(
                Icons.home,
                size: 20,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.search,
                size: 20,
              ),
              onPressed: () {})
        ],
      ),
    );
  }
}

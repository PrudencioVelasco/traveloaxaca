import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/categoria_bloc.dart';
import 'package:traveloaxaca/blocs/lugar_bloc.dart';
import 'package:traveloaxaca/blocs/ruta_bloc.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:traveloaxaca/models/lugar.dart';
import 'package:traveloaxaca/pages/aventuras.dart';
import 'package:traveloaxaca/pages/mapa_lugares_cercanos.dart';
import 'package:traveloaxaca/pages/tours.dart';
import 'package:traveloaxaca/pages/perfil.dart';
import 'package:traveloaxaca/blocs/featured_bloc.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/pages/recien_visitado.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/featured_places.dart';
import 'package:traveloaxaca/widgets/popular_places.dart';
import 'package:easy_localization/easy_localization.dart';

class Explore extends StatefulWidget {
  Explore({Key? key}) : super(key: key);

  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with AutomaticKeepAliveClientMixin {
  FeaturedBloc _featuredBloc = new FeaturedBloc();
  PopularPlacesBloc _popularPlacesBloc = new PopularPlacesBloc();
  CategoriaBloc _categoriaBloc = new CategoriaBloc();
  RutasBloc _rutasBloc = new RutasBloc();
  LugarBloc _lugarBloc = new LugarBloc();
  List<Lugar?> _listLugares = [];
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _featuredBloc.init(context, refresh);
      _popularPlacesBloc.init(context, refresh);
      _rutasBloc.init(context, refresh);
      _categoriaBloc.init(context, refresh);
      _lugarBloc.init(context, refresh);
    });
    Future.delayed(Duration(milliseconds: 0)).then((_) {
      _featuredBloc.getData();
      _popularPlacesBloc.getData();
      _rutasBloc.getData();
      //context.read<RecentPlacesBloc>().getData();
      //context.read<SpecialStateOneBloc>().getData();
      //context.read<SpecialStateTwoBloc>().getData();
      //context.read<RecommandedPlacesBloc>().getData();
    });
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //  backgroundColor: Colors.white,
        body: SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _featuredBloc.onRefresh();
          _popularPlacesBloc.onRefresh();
          _rutasBloc.onRefresh();
          _categoriaBloc.onRefresh();
          context.read<LugarBloc>().onRefresh();
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
              ToursPage(),
              RecienVisitadoPage(),
              MapaLugaresCercanosPage(),
              AventurasPage()
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/header.png"),
          fit: BoxFit.cover,
        ),
      ),
      // color: Colors.green,
      // margin: EdgeInsets.only(bottom: 2),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        "explore oaxaca".tr(),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      'explore mexico'.tr(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    )
                  ],
                ),
                Spacer(),
                InkWell(
                  child: (sb.autenticando == false)
                      ? Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 28,
                            color: Colors.grey[800],
                          ),
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
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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

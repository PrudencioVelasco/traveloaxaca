import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';
import 'package:traveloaxaca/blocs/popular_places_bloc.dart';
import 'package:traveloaxaca/models/icon_data.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/models/lugar.dart';

class BuildLoveIcon extends StatefulWidget {
  final int idlugar;

  const BuildLoveIcon({Key? key, required this.idlugar}) : super(key: key);

  @override
  _BuildLoveIconState createState() => _BuildLoveIconState();
}

class _BuildLoveIconState extends State<BuildLoveIcon> {
  LoveBloc _loveBloc = new LoveBloc();
  late Future<Lugar?> _detalleLugar;
  int _totalLove = 0;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
      getData(widget.idlugar);
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _loveBloc.init(context, refresh);
    });
  }

  void refresh() {
    setState(() {});
  }

  void getData(int idlugar) async {
    _totalLove = await _loveBloc.obtenerLovePorUsuario(idlugar, 1);
    /*_detalleLugar.then((row) {
      if (row!.love != null) {
        _totalLove = row.love!;
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    bool isSignedIn = true;
    if (isSignedIn == false) return LoveIcon().normal;

    if (_totalLove == 1) {
      return LoveIcon().bold;
    } else {
      return LoveIcon().normal;
    }
  }
}

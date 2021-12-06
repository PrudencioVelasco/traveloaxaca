import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';

class LoveCountNuevo extends StatefulWidget {
  final int id;
  final int opcion;
  LoveCountNuevo({Key? key, required this.id, required this.opcion})
      : super(key: key);

  @override
  _LoveCountNuevoState createState() => _LoveCountNuevoState();
}

class _LoveCountNuevoState extends State<LoveCountNuevo> {
  LoveBloc _loveBloc = new LoveBloc();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _loveBloc.init(context, refresh);
    });
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

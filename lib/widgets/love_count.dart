import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/love_bloc.dart';

class LoveCount extends StatelessWidget {
  final int idlugar;
  const LoveCount({Key? key, required this.idlugar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _providerLovesBloc = Provider.of<LoveBloc>(context, listen: true);

    if (_providerLovesBloc.totalLoves == 0)
      return Text(
        0.toString(),
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
      );
    return Text(
      _providerLovesBloc.totalLoves.toString(),
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class CommentCount extends StatelessWidget {
  final int idLugar;
  final int parametro;
  const CommentCount({Key? key, required this.idLugar, required this.parametro})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //return
    String _textcomentario = "view reviews".tr();
    final _providerCommentsBloc =
        Provider.of<CommentsBloc>(context, listen: true);
    if (parametro == 0) {
      if (_providerCommentsBloc.totalComentarios == 0)
        return Text(
          0.toString(),
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600]),
        );
      return Text(
        _providerCommentsBloc.totalComentarios.toString(),
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
      );
    } else {
      if (_providerCommentsBloc.totalComentarios == 0)
        return Text(
          0.toString() + " " + _textcomentario,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600]),
        );
      return Text(
        _providerCommentsBloc.totalComentarios.toString() +
            " " +
            _textcomentario,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
      );
    }
  }
}

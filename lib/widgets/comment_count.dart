import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/comments_bloc.dart';

class CommentCount extends StatelessWidget {
  final int idLugar;
  const CommentCount({Key? key, required this.idLugar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //return
    final _providerCommentsBloc =
        Provider.of<CommentsBloc>(context, listen: true);

    if (_providerCommentsBloc.totalComentarios == 0)
      return Text(
        0.toString(),
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
      );
    return Text(
      _providerCommentsBloc.totalComentarios.toString(),
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
    );
  }
}

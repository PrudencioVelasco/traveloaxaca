import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/blocs/tour_bloc.dart';
import 'package:traveloaxaca/models/comentario_tour.dart';
import 'package:traveloaxaca/models/love_tour.dart';

class CommentCountNuevo extends StatefulWidget {
  final int id;
  final int opcion;
  const CommentCountNuevo({Key? key, required this.id, required this.opcion})
      : super(key: key);

  @override
  State<CommentCountNuevo> createState() => _CommentCountNuevoState();
}

class _CommentCountNuevoState extends State<CommentCountNuevo> {
  TourBloc _tourBloc = new TourBloc();
  List<ComentarioTour?> _listCommentarioTour = [];
  List<LoveTour?> _listLoveTour = [];
  int _total = 0;
  String _textcomentario = "view reviews".tr();
  String _textlove = "love".tr();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
      conteo(widget.id, widget.opcion);
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _tourBloc.init(context, refresh);
    });
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void conteo(int id, int opcion) async {
    if (opcion == 1) {
      _listLoveTour = await _tourBloc.lovesLovesTours(id);
      setState(() {
        _total = _listLoveTour.toList().length;
      });
    }
    if (opcion == 2) {
      _listCommentarioTour = await _tourBloc.commentsTours(id);
      setState(() {
        _total = _listCommentarioTour.toList().length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.opcion == 1) {
      return Text(
        _total.toString() + " " + _textlove,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
      );
    } else if (widget.opcion == 2) {
      return Text(
        _total.toString() + " " + _textcomentario,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
      );
    } else {
      return Text(
        _total.toString() + " " + _textlove,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/pages/home.dart';

class LoadingPage extends StatefulWidget {
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller!.forward();
    //afterSplash();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkLoginState(context),
        builder: (context, snapshot) {
          return Center(
            child: Image(
              image: AssetImage(Config().logotipo),
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }

  Future checkLoginState(BuildContext context) async {
    final _signInBlocProvider = Provider.of<SignInBloc>(context);

    final autenticado = await _signInBlocProvider.isLoggedIn();

    if (autenticado) {
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => Home(),
              transitionDuration: Duration(milliseconds: 0)));
    } else {
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => Home(),
              transitionDuration: Duration(milliseconds: 0)));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/models/imagen.dart';
import 'package:traveloaxaca/pages/home.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:traveloaxaca/setting/res/resources.dart';

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
    var brishtness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brishtness == Brightness.dark;
    return Scaffold(
        body: EasySplashScreen(
      backgroundColor: (!isDarkMode) ? Colors.white : Colors.black,
      logoSize: 120,
      logo: Image.asset(
        Config().logotipo,
        fit: BoxFit.contain,
      ),
      title: Text(
        "explore oaxaca".tr(),
        style: Theme.of(context).textTheme.headline6,
      ),
      showLoader: true,
      loadingText: Text("loading...".tr()),
      loaderColor: (isDarkMode) ? Colors.white : Colors.black,
      futureNavigator: checkLoginState(context),
    )
        /*FutureBuilder(
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
      ),*/
        );
  }

  Future<Widget> checkLoginState(BuildContext context) async {
    final _signInBlocProvider = Provider.of<SignInBloc>(context);

    final autenticado = await _signInBlocProvider.isLoggedIn();

    if (autenticado) {
      return Future.value(new Home());
    } else {
      return Future.value(new Home());
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/pages/home.dart';
import 'package:traveloaxaca/pages/intro.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/widgets/language.dart';
import 'package:traveloaxaca/utils/mostrar_alerta.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInInicio extends StatefulWidget {
  SignInInicio({Key? key}) : super(key: key);

  @override
  State<SignInInicio> createState() => _SignInInicioState();
}

class _SignInInicioState extends State<SignInInicio> {
  bool googleSignInStarted = false;
  bool facebookSignInStarted = false;
  bool appleSignInStarted = false;
  SignInBloc _signInBloc = new SignInBloc();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // _isLoading = true;
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {});
  }

  afterSignIn() {
    Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (context) => new IntroPage()));
  }

  handleSkip() {
    final sb = context.read<SignInBloc>();
    nextScreen(context, Home());
  }

  handleFacebookSignIn() async {
    // final ib = Provider.of<InternetBloc>(context, listen: false);
    // await ib.checkInternet();
    // if (ib.hasInternet == false) {
    //   Navigator.pop(context);
    //   openToast(context, 'no internet'.tr());
    // } else {
    setState(() => facebookSignInStarted = true);
    final sb = context.read<SignInBloc>();
    FocusScope.of(context).unfocus();
    final loginOk = await sb.signInwithFacebook();
    if (loginOk) {
      //Regresa a la ventana anterior
      afterSignIn();
      setState(() => facebookSignInStarted = false);
    } else {
      mostrarAlerta(context, 'sign in'.tr(),
          'something is wrong. please try again.'.tr());
      setState(
        () => facebookSignInStarted = false,
      );
    }
    //  }
  }

  @override
  Widget build(BuildContext context) {
    // final _signInBlocProvider = Provider.of<SignInBloc>(context, listen: true);
    final _signInBlocProvider = Provider.of<SignInBloc>(context);

    return Scaffold(
      //backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => handleSkip(),
            icon: Icon(
              Icons.close,
            )),
        actions: [
          IconButton(
            alignment: Alignment.center,
            padding: EdgeInsets.all(0),
            iconSize: 22,
            icon: Icon(
              Icons.language,
            ),
            onPressed: () {
              nextScreenPopup(context, LanguagePopup());
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'welcome to',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700]),
                  ).tr(),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${Config().appName}',
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[700]),
                  ),
                ],
              )),
          Container(
            width: 100,
            height: 100,
            child: Image.asset('assets/images/exploraoaxaca.png'),
          ),
          Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Text(
                      'welcome message',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[700]),
                    ).tr(),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 3,
                    width: MediaQuery.of(context).size.width * 0.50,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                ],
              )),
          Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: TextButton(
                        onPressed: () {
                          handleFacebookSignIn();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        // color: Colors.indigo,
                        // shape: RoundedRectangleBorder(
                        //    borderRadius: BorderRadius.circular(5)),
                        child: facebookSignInStarted == false
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.facebook,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'sign in with facebook'.tr(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  )
                                ],
                              )
                            : Center(
                                child: CircularProgressIndicator(
                                    backgroundColor: Colors.white),
                              )),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Platform.isAndroid
                      ? Container()
                      : Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.80,
                          child: TextButton(
                              onPressed: () {
                                //handleAppleSignIn();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              // style: Text,
                              //color: Colors.grey[900],
                              //shape: RoundedRectangleBorder(
                              //      borderRadius: BorderRadius.circular(5)),
                              child: appleSignInStarted == false
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.apple,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Sign In with Apple',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white),
                                        )
                                      ],
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(
                                          backgroundColor: Colors.white),
                                    )),
                        ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  TextButton(
                      onPressed: () => handleSkip(),
                      child: Text('skip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )).tr()),
                  TextButton(
                      onPressed: () {
                        _launchURL();
                      },
                      child: Text('privacy policy'.tr(),
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline)))
                ],
              )),
        ],
      ),
    );
  }

  _launchURL() async {
    const url = 'https://oaxacaexplora.com/avisoprivacidad.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
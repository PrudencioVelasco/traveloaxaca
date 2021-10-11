import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:traveloaxaca/blocs/sign_in_bloc.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/pages/sign_in.dart';
import 'package:traveloaxaca/utils/next_screen.dart';
import 'package:traveloaxaca/widgets/language.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      // _con.init(context);
    });
  }

  openAboutDialog() {
    final sb = context.read<SignInBloc>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AboutDialog(
            applicationName: Config().appName,
            applicationIcon: Image(
              image: AssetImage(Config().splashIcon),
              height: 30,
              width: 30,
            ),
            applicationVersion: sb.appVersion,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final sb = context.watch<SignInBloc>();
    //  final sb = context.watch<SignInBloc>()
    final sb = Provider.of<SignInBloc>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.grey[600],
        title: Text('profile').tr(),
        centerTitle: false,
        actions: [],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
        children: [
          sb.autenticando == false ? GuestUserUI() : UserUI(),
          Text(
            "general setting",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ).tr(),
          SizedBox(
            height: 15,
          ),
          Divider(
            height: 5,
          ),
          ListTile(
            title: Text('contact us').tr(),
            leading: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(5)),
              child: Icon(FontAwesomeIcons.mailBulk,
                  size: 20, color: Colors.white),
            ),
            trailing: Icon(
              FontAwesomeIcons.chevronRight,
              size: 20,
            ),
            onTap: () async => await launch(
                'mailto:${Config().supportEmail}?subject=About ${Config().appName} App&body='),
          ),
          Divider(
            height: 5,
          ),
          ListTile(
            title: Text('language').tr(),
            leading: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(5)),
              child:
                  Icon(FontAwesomeIcons.globe, size: 20, color: Colors.white),
            ),
            trailing: Icon(
              FontAwesomeIcons.chevronRight,
              size: 20,
            ),
            onTap: () => nextScreenPopup(context, LanguagePopup()),
          ),
          Divider(
            height: 5,
          ),
          ListTile(
            title: Text('rate this app').tr(),
            leading: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(5)),
              child: Icon(FontAwesomeIcons.star, size: 20, color: Colors.white),
            ),
            trailing: Icon(
              FontAwesomeIcons.chevronRight,
              size: 20,
            ),
            onTap: () async => LaunchReview.launch(
                androidAppId: sb.packageName, iOSAppId: Config().iOSAppId),
          ),
          Divider(
            height: 5,
          ),
          ListTile(
            title: Text('about us').tr(),
            leading: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(5)),
              child: Icon(FontAwesomeIcons.info, size: 20, color: Colors.white),
            ),
            trailing: Icon(
              FontAwesomeIcons.chevronRight,
              size: 20,
            ),
            onTap: () => abrirVentanaQuienesSomos(context),
          ),
          Divider(
            height: 5,
          ),
        ],
      ),
    );
  }

  void abrirVentanaQuienesSomos(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('about us').tr(),
            content: Text(
              'Somos un grupo de jóvenes Oaxaqueños que nos dimos a la tarea de crear esta aplicación para impulsas a nuestro Estado en el sector turístico.',
              textAlign: TextAlign.justify,
            ),
            actions: [
              TextButton(
                child: Text('close').tr(),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  void openLogoutDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('logout title').tr(),
            actions: [
              TextButton(
                child: Text('no').tr(),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('yes').tr(),
                onPressed: () async {
                  Navigator.pop(context);
                  await context
                      .read<SignInBloc>()
                      .logout()
                      .then((value) => nextScreenCloseOthers(
                          context,
                          SignInPage(
                            tag: 'poput',
                          )));
                },
              )
            ],
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class GuestUserUI extends StatelessWidget {
  const GuestUserUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('login').tr(),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(FontAwesomeIcons.user, size: 20, color: Colors.white),
          ),
          trailing: Icon(
            FontAwesomeIcons.chevronRight,
            size: 20,
          ),
          onTap: () => nextScreenPopup(
              context,
              SignInPage(
                tag: 'popup',
              )),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class UserUI extends StatelessWidget {
  const UserUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    return Column(
      children: [
        Container(
          height: 200,
          child: Column(
            children: [
              CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      CachedNetworkImageProvider(sb.usuario!.imageUrl!)),
              SizedBox(
                height: 10,
              ),
              Text(
                sb.usuario!.userName!,
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
        ListTile(
          title: Text(sb.usuario!.userEmail!),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(Icons.email, size: 20, color: Colors.white),
          ),
        ),
        Divider(
          height: 5,
        ),
        ListTile(
          title: Text('logout').tr(),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(FeatherIcons.logOut, size: 20, color: Colors.white),
          ),
          trailing: Icon(
            FeatherIcons.chevronLeft,
            size: 20,
          ),
          onTap: () => openLogoutDialog(context),
        ),
        SizedBox(
          height: 15,
        )
      ],
    );
  }

  void openLogoutDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('logout title').tr(),
            actions: [
              TextButton(
                child: Text('no').tr(),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('yes').tr(),
                onPressed: () async {
                  Navigator.pop(context);
                  await context.read<SignInBloc>().logout();
                },
              )
            ],
          );
        });
  }
}

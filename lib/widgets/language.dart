import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:traveloaxaca/config/config.dart';
import 'package:traveloaxaca/pages/home.dart';

class LanguagePopup extends StatefulWidget {
  const LanguagePopup({Key? key}) : super(key: key);

  @override
  _LanguagePopupState createState() => _LanguagePopupState();
}

class _LanguagePopupState extends State<LanguagePopup> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> cambiarLenguaje(int index) async {
    if (index == 0) {
      // context.resetLocale();
      context.setLocale(Locale('en'));
    } else {
      //context.resetLocale();
      context.setLocale(Locale('es'));
    }
    return true;
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'select language',
          style: Theme.of(context).textTheme.headline6,
        ).tr(),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: Config().languages.length,
        itemBuilder: (BuildContext context, int index) {
          return _itemList(Config().languages[index], index);
        },
      ),
    );
  }

  Widget _itemList(d, index) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.language),
          title: Text(d),
          onTap: () async {
            if (index == 0) {
              // context.resetLocale();
              context.setLocale(Locale('en'));
            } else {
              //context.resetLocale();
              context.setLocale(Locale('es'));
            }
            //Navigator.of(context, rootNavigator: true).pop();
            await Navigator.push(
                context, new MaterialPageRoute(builder: (context) => Home()));
          },
        ),
        Divider()
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traveloaxaca/setting/res/constant.dart';
import 'package:traveloaxaca/setting/res/resources.dart';
import 'package:traveloaxaca/setting/res/web_page_transitions.dart';
import 'package:sp_util/sp_util.dart';

extension ThemeModeExtension on ThemeMode {
  String get value => <String>['System', 'Light', 'Dark'][index];
}

class ThemeProvider extends ChangeNotifier {
  void syncTheme() {
    final String theme = SpUtil.getString(Constant.theme) ?? '';
    if (theme.isNotEmpty && theme != ThemeMode.system.value) {
      notifyListeners();
    }
  }

  void setTheme(ThemeMode themeMode) {
    SpUtil.putString(Constant.theme, themeMode.value);
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    final String theme = SpUtil.getString(Constant.theme) ?? '';
    switch (theme) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData getTheme({bool isDarkMode = false}) {
    return ThemeData(
      errorColor: isDarkMode ? Colours.dark_red : Colours.red,
      primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        secondary: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      ),
        primaryColorBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        primaryColorLight: isDarkMode ? Colors.redAccent : Colors.white,

      indicatorColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      scaffoldBackgroundColor:
          isDarkMode ? Colours.dark_bg_color : Colors.white,
      canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colours.app_main.withAlpha(70),
        selectionHandleColor: Colours.app_main,
        cursorColor: Colours.app_main,
      ),
      fontFamily: 'Muli',
      textTheme: TextTheme(
        headline1: isDarkMode
            ? TextStyles.textDarkTituloLugar
            : TextStyles.textTituloLugar,
        subtitle1: isDarkMode ? TextStyles.textDark : TextStyles.text,
        // Text文字样式
        bodyText2: isDarkMode ? TextStyles.textDark : TextStyles.text,

        subtitle2:
            isDarkMode ? TextStyles.textDarkGray12 : TextStyles.textGray12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle:
            isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
      ),
      appBarTheme: AppBarTheme(
        elevation: 1.0,
        color: isDarkMode ? Colours.dark_bg_color : Colors.white,
        systemOverlayStyle:
            isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colours.dark_bg_color),
      ),
      dividerTheme: DividerThemeData(
          color: isDarkMode ? Colours.dark_line : Colours.line,
          space: 0.6,
          thickness: 0.6),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      pageTransitionsTheme: NoTransitionsOnWeb(),
      visualDensity: VisualDensity
          .standard
    );
  }
}

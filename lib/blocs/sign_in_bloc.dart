import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:traveloaxaca/api/environment.dart';
import 'package:traveloaxaca/models/response_api.dart';
import 'package:traveloaxaca/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignInBloc extends ChangeNotifier {
  final _storage = new FlutterSecureStorage();
  bool _autenticando = false;
  User? usuario;
  bool get autenticando => this._autenticando;
  set autenticando(bool valor) {
    this._autenticando = valor;
    notifyListeners();
  }

  String _appVersion = '0.0';
  String get appVersion => _appVersion;

  String _packageName = '';
  String get packageName => _packageName;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorCode = "";
  String get errorCode => _errorCode;
  int _idusuario = 0;
  int get idusuario => _idusuario;
  void initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    _packageName = packageInfo.packageName;
    notifyListeners();
  }

  // Getters del token de forma estática
  Future<String?> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future _guardarToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token');
    await FacebookAuth.instance.logOut();
    this.autenticando = false;
    notifyListeners();
  }

  Future signInwithFacebook() async {
    await FacebookAuth.instance.logOut();
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['public_profile', 'email'],
    );
    if (result.status == LoginStatus.cancelled) {
      _hasError = true;
      _errorCode = 'cancel';
      return false;
      //  notifyListeners();
    } else if (result.status == LoginStatus.failed) {
      _hasError = true;
      return false;
      // notifyListeners();
    } else {
      try {
        if (result.status == LoginStatus.success) {
          final AccessToken accessToken = result.accessToken!;
          String _url = Environment.API_DELIVERY;
          String _api = '/monarca/usuario';
          try {
            Uri url = Uri.http(_url, '$_api/singInFacebook');
            String bodyParams = json.encode({'authToken': accessToken.token});
            Map<String, String> headers = {
              'Content-Type': 'application/json;charset=UTF-8',
              'Charset': 'utf-8'
            };
            final res =
                await http.post(url, headers: headers, body: bodyParams);
            final dataresponse = json.decode(res.body);
            ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
            if (responseApi.success == true) {
              await this._guardarToken(responseApi.token!);
              this.autenticando = true;

              this.usuario = User.fromJson(responseApi.data);
              this._idusuario = usuario!.idusuario!;
              return true;
            } else {
              this.autenticando = false;
              return false;
            }
          } catch (error) {
            print('Error: $error');
            return false;
          }
        }
      } catch (e) {
        _hasError = true;
        _errorCode = e.toString();
        return false;
      }
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await this._storage.read(key: 'token') ?? '';
    String _url = Environment.API_DELIVERY;
    String _api = '/monarca/usuario';
    try {
      Uri url = Uri.http(_url, '$_api/renewtoken');
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'x-token': token
      };
      final res = await http.get(url, headers: headers);
      final dataresponse = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(dataresponse);
      if (responseApi.success == true) {
        await this._guardarToken(responseApi.token!);
        this.autenticando = true;
        this.usuario = User.fromJson(responseApi.data);
        this._idusuario = usuario!.idusuario!;
        return true;
      } else {
        this.autenticando = false;
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }
}

// To parse this JSON data, do
//
//     final responseApi = responseApiFromJson(jsonString);

import 'dart:convert';

ResponseApi responseApiFromJson(String str) =>
    ResponseApi.fromJson(json.decode(str));

String responseApiToJson(ResponseApi data) => json.encode(data.toJson());

class ResponseApi {
  bool? success;
  String? message;
  String? error;
  dynamic data;

  ResponseApi({
    this.success,
    this.message,
    this.error,
  });

  ResponseApi.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    message = json["message"];
    error = json["error"];
    try {
      data = json["data"];
    } catch (error) {}
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message!,
        "error": error,
      };
}

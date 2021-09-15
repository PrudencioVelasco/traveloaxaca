import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  int? idusuario;
  String? userName;
  String? userEmail;
  String? imageUrl;
  String? uid;
  String? joiningDate;
  String? timestamp;
  List<User> toList = [];
  User({
    this.idusuario,
    this.userName,
    this.userEmail,
    this.imageUrl,
    this.uid,
    this.joiningDate,
    this.timestamp,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        idusuario: json["idusuario"],
        userName: json["userName"],
        userEmail: json["userEmail"],
        imageUrl: json['imageUrl'] ??
            'https://www.seekpng.com/png/detail/115-1150053_avatar-png-transparent-png-royalty-free-default-user.png',
        uid: json["uid"],
        joiningDate: json["joiningDate"],
        timestamp: json["timestamp"],
      );
  User.fromJsonToList(List<dynamic> jsonList) {
    //if (jsonList == null) return;
    jsonList.forEach((element) {
      User imagen = User.fromJson(element);
      toList.add(imagen);
    });
  }
  Map<String, dynamic> toJson() => {
        "idusuario": idusuario,
        "userName": userName,
        "userEmail": userEmail,
        "imageUrl": imageUrl,
        "uid": uid,
        "joiningDate": joiningDate,
        "timestamp": timestamp,
      };
}

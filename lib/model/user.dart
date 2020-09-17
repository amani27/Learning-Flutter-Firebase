import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());


class User {
  String id, nickname, photoUrl;

  User({this.id, this.nickname, this.photoUrl});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        nickname: json["nickname"],
        photoUrl: json["photoUrl"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nickname": nickname,
        "photoUrl": photoUrl,
    };
}

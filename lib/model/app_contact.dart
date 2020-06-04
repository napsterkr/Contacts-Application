import 'package:contactapp/model/app_phone.dart';

class AppContact {
  int id;
  String name;
  String avatar;
  bool favorite;
  List<AppPhone> phoneList;

  AppContact(
      {this.name = "", this.avatar, this.favorite = false, this.phoneList}) {
    if (phoneList != null) phoneList.add(AppPhone());
  }

  AppContact.withId(
      {this.id, this.name, this.avatar, this.favorite = false, this.phoneList});

  factory AppContact.fromMap(Map<String, dynamic> map) {
    return AppContact.withId(
        id: map["id"],
        name: map["name"],
        avatar: map["avatar"],
        favorite: map["favorite"] == 1 ? true : false);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "avatar": avatar,
      "favorite": favorite ? 1 : 0,
    };
  }
}

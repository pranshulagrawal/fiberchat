//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:flutter/widgets.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get getUser => _user;

  getUserDetails(String? phone) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(phone)
        .get();

    _user = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }
}

class UserModel {
  String? uid;
  String? name;
  String? phone;
  String? username;
  String? status;
  int? state;
  String? profilePhoto;

  UserModel({
    this.uid,
    this.name,
    this.phone,
    this.username,
    this.status,
    this.state,
    this.profilePhoto,
  });

  Map toMap(UserModel user) {
    var data = Map<String, dynamic>();
    data['id'] = user.uid;
    data['nickname'] = user.name;
    data['phone'] = user.phone;
    data["photoUrl"] = user.profilePhoto;
    return data;
  }

  // Named constructor
  UserModel.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['id'];
    this.name = mapData['nickname'];
    this.phone = mapData['phone'];
    this.profilePhoto = mapData['photoUrl'];
  }
}

//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:core';
import 'dart:async';
import 'dart:io';
import 'package:async/async.dart' show StreamGroup;
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';

class DataModel extends Model {
  Map<String?, Map<String, dynamic>?> userData =
      new Map<String?, Map<String, dynamic>?>();

  Map<String, Future> _messageStatus = new Map<String, Future>();

  _getMessageKey(String? peerNo, int? timestamp) => '$peerNo$timestamp';

  getMessageStatus(String? peerNo, int? timestamp) {
    final key = _getMessageKey(peerNo, timestamp);
    return _messageStatus[key] ?? true;
  }

  bool _loaded = false;

  LocalStorage _storage = LocalStorage('model');

  addMessage(String? peerNo, int? timestamp, Future future) {
    final key = _getMessageKey(peerNo, timestamp);
    future.then((_) {
      _messageStatus.remove(key);
    });
    _messageStatus[key] = future;
  }

  addUser(DocumentSnapshot<Map<String, dynamic>> user) {
    userData[user.data()![Dbkeys.phone]] = user.data();
    notifyListeners();
  }

  setWallpaper(String? phone, File image) async {
    final dir = await getDir();
    int now = DateTime.now().millisecondsSinceEpoch;
    String path = '${dir.path}/WALLPAPER-$phone-$now';
    await image.copy(path);
    userData[phone]![Dbkeys.wallpaper] = path;
    updateItem(phone!, {Dbkeys.wallpaper: path});
    notifyListeners();
  }

  removeWallpaper(String phone) {
    userData[phone]![Dbkeys.wallpaper] = null;
    String? path = userData[phone]![Dbkeys.aliasAvatar];
    if (path != null) {
      File(path).delete();
      userData[phone]![Dbkeys.wallpaper] = null;
    }
    updateItem(phone, {Dbkeys.wallpaper: null});
    notifyListeners();
  }

  getDir() async {
    return await getApplicationDocumentsDirectory();
  }

  updateItem(String key, Map<String, dynamic> value) {
    Map<String, dynamic> old = _storage.getItem(key) ?? Map<String, dynamic>();

    old.addAll(value);
    _storage.setItem(key, old);
  }

  setAlias(String aliasName, File? image, String phone) async {
    userData[phone]![Dbkeys.aliasName] = aliasName;
    if (image != null) {
      final dir = await getDir();
      int now = DateTime.now().millisecondsSinceEpoch;
      String path = '${dir.path}/$phone-$now';
      await image.copy(path);
      userData[phone]![Dbkeys.aliasAvatar] = path;
    }
    updateItem(phone, {
      Dbkeys.aliasName: userData[phone]![Dbkeys.aliasName],
      Dbkeys.aliasAvatar: userData[phone]![Dbkeys.aliasAvatar],
    });
    notifyListeners();
  }

  removeAlias(String phone) {
    userData[phone]![Dbkeys.aliasName] = null;
    String? path = userData[phone]![Dbkeys.aliasAvatar];
    if (path != null) {
      File(path).delete();
      userData[phone]![Dbkeys.aliasAvatar] = null;
    }
    updateItem(phone, {Dbkeys.aliasName: null, Dbkeys.aliasAvatar: null});
    notifyListeners();
  }

  bool get loaded => _loaded;

  Map<String, dynamic>? get currentUser => _currentUser;

  Map<String, dynamic>? _currentUser;

  Map<String?, int?> get lastSpokenAt => _lastSpokenAt;

  Map<String?, int?> _lastSpokenAt = {};

  getChatOrder(List<String> chatsWith, String? currentUserNo) {
    List<Stream<QuerySnapshot>> messages = [];
    chatsWith.forEach((otherNo) {
      String chatId = Fiberchat.getChatId(currentUserNo, otherNo);
      messages.add(FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .collection(chatId)
          .snapshots());
    });
    StreamGroup.merge(messages).listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot message = snapshot.docs.last;
        _lastSpokenAt[message[Dbkeys.from] == currentUserNo
            ? message[Dbkeys.to]
            : message[Dbkeys.from]] = message[Dbkeys.timestamp];
        notifyListeners();
      }
    });
  }

  DataModel(String? currentUserNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .snapshots()
        .listen((user) {
      _currentUser = user.data();
      notifyListeners();
    });
    _storage.ready.then((ready) {
      if (ready) {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(currentUserNo)
            .collection(Dbkeys.chatsWith)
            .doc(Dbkeys.chatsWith)
            .snapshots()
            .listen((_chatsWith) {
          if (_chatsWith.exists) {
            List<Stream<DocumentSnapshot>> users = [];
            List<String> peers = [];
            _chatsWith.data()!.entries.forEach((_data) {
              peers.add(_data.key);
              users.add(FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(_data.key)
                  .snapshots());
              if (userData[_data.key] != null) {
                userData[_data.key]![Dbkeys.chatStatus] = _chatsWith[_data.key];
              }
            });
            getChatOrder(peers, currentUserNo);
            notifyListeners();
            Map<String?, Map<String, dynamic>?> newData =
                Map<String?, Map<String, dynamic>?>();
            StreamGroup.merge(users).listen((user) {
              if (user.exists) {
                newData[user[Dbkeys.phone]] =
                    user.data() as Map<String, dynamic>?;
                newData[user[Dbkeys.phone]]![Dbkeys.chatStatus] =
                    _chatsWith[user[Dbkeys.phone]];
                Map<String, dynamic>? _stored =
                    _storage.getItem(user[Dbkeys.phone]);
                if (_stored != null) {
                  newData[user[Dbkeys.phone]]!.addAll(_stored);
                }
              }
              userData = Map.from(newData);
              notifyListeners();
            });
          }
          if (!_loaded) {
            _loaded = true;
            notifyListeners();
          }
        });
      }
    });
  }
}

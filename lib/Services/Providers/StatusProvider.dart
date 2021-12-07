//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StatusProvider with ChangeNotifier {
  List<JoinedUserModel> joinedUserPhoneStringAsInServer = [];
  bool isLoading = false;
  bool searchingcontactsstatus = true;
  List<DocumentSnapshot<dynamic>> contactsStatus = [];

  setIsLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  searchContactStatus(String currentuserphone,
      List<JoinedUserModel> alljoinedUserPhoneStringAsInServer) async {
    joinedUserPhoneStringAsInServer = alljoinedUserPhoneStringAsInServer;
    notifyListeners();
    print(
        'SEARCHING STATUS FOR ${joinedUserPhoneStringAsInServer.length} AVAILABLE CONTACTS');
    if (joinedUserPhoneStringAsInServer.length == 0) {
      searchingcontactsstatus = false;
      notifyListeners();
    } else {
      joinedUserPhoneStringAsInServer.forEach((user) async {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionnstatus)
            .where(Dbkeys.statusPUBLISHERPHONEVARIANTS,
                arrayContains: user.phone.toString())
            .get()
            .then((docs) {
          if (docs.docs.length > 0) {
            if (docs.docs.length > 0 &&
                DateTime.now().isBefore(
                    docs.docs[0].data()[Dbkeys.statusEXPIRININGON].toDate()) &&
                docs.docs[0].data()[Dbkeys.statusPUBLISHERPHONE] !=
                    currentuserphone &&
                contactsStatus.indexWhere((element) =>
                        element.data()[Dbkeys.statusPUBLISHERPHONE] ==
                        docs.docs[0].data()[Dbkeys.statusPUBLISHERPHONE]) <
                    0) {
              contactsStatus.add(docs.docs[0]);

              if (user.phone == joinedUserPhoneStringAsInServer.last.phone) {
                searchingcontactsstatus = false;
                if (contactsStatus.length > 8 && contactsStatus.length < 10) {
                  isLoading = false;
                }
              }
              notifyListeners();
            } else {
              if (user.phone == joinedUserPhoneStringAsInServer.last.phone) {
                searchingcontactsstatus = false;
                notifyListeners();
              }
              // if (docs.docs.length == 0) {
              //   if (contactsStatus.contains(docs.docs[0])) {
              //     contactsStatus.remove(docs.docs[0]);
              //     notifyListeners();
              //   }
              // }
            }
          } else {
            if (user.phone == joinedUserPhoneStringAsInServer.last.phone) {
              searchingcontactsstatus = false;
              notifyListeners();
            }
            if (docs.docs.length == 0) {
              int i = contactsStatus.indexWhere((status) =>
                  status[Dbkeys.statusPUBLISHERPHONEVARIANTS]
                      .contains(user.phone.toString()));
              if (i >= 0) {
                contactsStatus.removeAt(i);
                notifyListeners();
              }
            }
          }
        });
        if (user.phone == joinedUserPhoneStringAsInServer.last.phone) {
          searchingcontactsstatus = false;
          notifyListeners();
        }
      });
    }
  }

  triggerDeleteMyExpiredStatus(String myphone) async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionnstatus)
        .doc(myphone)
        .get()
        .then((myStatus) async {
      if (myStatus.exists &&
          (DateTime.now()
              .isAfter(myStatus[Dbkeys.statusEXPIRININGON].toDate()))) {
        myStatus.reference.delete();
        //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
      }
    });
  }

  triggerDeleteOtherUsersExpiredStatus(String myphone) async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionnstatus)
        .where(Dbkeys.statusEXPIRININGON, isLessThan: DateTime.now())
        .limit(2)
        .get()
        .then((allstatus) async {
      if (allstatus.docs.length > 0) {
        allstatus.docs.forEach((eachStatus) async {
          await eachStatus.reference.delete();
          //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
        });
      }
    });

    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .where(Dbkeys.lastSeen, isEqualTo: true)
        .where(Dbkeys.lastOnline,
            isLessThan: DateTime.now()
                .subtract(Duration(minutes: 10))
                .millisecondsSinceEpoch)
        // .where(Dbkeys.phone, isEqualTo: '+919859543919')
        .limit(10)
        .get()
        .then((allusers) async {
      if (allusers.docs.length > 0) {
        allusers.docs.forEach((eachUser) async {
          if (eachUser[Dbkeys.phone] != myphone) {
            if (eachUser.data().containsKey(Dbkeys.lastOnline)) {
              if (DateTime.now()
                      .difference(DateTime.fromMillisecondsSinceEpoch(
                          eachUser[Dbkeys.lastOnline]))
                      .inMinutes >=
                  10) {
                eachUser.reference.update(
                    {Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch});
              }
            } else {
              eachUser.reference.update(
                  {Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch});
            }
          }
        });
      }
    });
  }
}

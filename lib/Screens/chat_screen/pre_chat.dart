//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:core';
import 'package:fiberchat/widgets/CountryPicker/CountryCode.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreChat extends StatefulWidget {
  final String? name, phone, currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  const PreChat(
      {required this.name,
      required this.prefs,
      required this.phone,
      required this.currentUserNo,
      required this.model});

  @override
  _PreChatState createState() => _PreChatState();
}

class _PreChatState extends State<PreChat> {
  bool? isLoading, isUser = false;
  bool issearching = true;
  String? peerphone;
  bool issearchraw = false;
  String? formattedphone;

  @override
  initState() {
    super.initState();

    isLoading = true;
    String? peer = widget.phone;
    // String peer = '+213-0791809113';
    setState(() {
      peerphone = peer!.replaceAll(new RegExp(r'-'), '');
      peerphone!.trim();
    });

    formattedphone = peerphone;

    if (!peerphone!.startsWith('+')) {
      if ((peerphone!.length > 11)) {
        CountryCodes.forEach((code) {
          if (peerphone!.startsWith(code) && issearching == true) {
            setState(() {
              formattedphone =
                  peerphone!.substring(code.length, peerphone!.length);
              issearchraw = true;
              issearching = false;
            });
          }
        });
      } else {
        setState(() {
          setState(() {
            issearchraw = true;
            formattedphone = peerphone;
          });
        });
      }
    } else {
      setState(() {
        issearchraw = false;
        formattedphone = peerphone;
      });
    }

    getUser();
  }

  getUser() {
    Query<Map<String, dynamic>> query = issearchraw == true
        ? FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.phoneRaw, isEqualTo: formattedphone ?? peerphone)
            .limit(1)
        : FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.phone, isEqualTo: formattedphone ?? peerphone)
            .limit(1);

    query.get().then((user) {
      setState(() {
        isUser = user.docs.length == 0 ? false : true;
      });
      if (isUser!) {
        Map<String, dynamic> peer = user.docs[0].data();
        widget.model!.addUser(user.docs[0]);
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => new ChatScreen(
                    isSharingIntentForwarded: false,
                    prefs: widget.prefs,
                    unread: 0,
                    currentUserNo: widget.currentUserNo,
                    model: widget.model!,
                    peerNo: peer[Dbkeys.phone])));
      } else {
        Query<Map<String, dynamic>> queryretrywithoutzero = issearchraw == true
            ? FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .where(Dbkeys.phoneRaw,
                    isEqualTo: formattedphone == null
                        ? peerphone!.substring(1, peerphone!.length)
                        : formattedphone!.substring(1, formattedphone!.length))
                .limit(1)
            : FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .where(Dbkeys.phoneRaw,
                    isEqualTo: formattedphone == null
                        ? peerphone!.substring(1, peerphone!.length)
                        : formattedphone!.substring(1, formattedphone!.length))
                .limit(1);
        queryretrywithoutzero.get().then((user) {
          setState(() {
            isLoading = false;
            isUser = user.docs.length == 0 ? false : true;
          });
          if (isUser!) {
            Map<String, dynamic> peer = user.docs[0].data();
            widget.model!.addUser(user.docs[0]);
            Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ChatScreen(
                        isSharingIntentForwarded: false,
                        prefs: widget.prefs,
                        unread: 0,
                        currentUserNo: widget.currentUserNo,
                        model: widget.model!,
                        peerNo: peer[Dbkeys.phone])));
          }
        });
      }
    });
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading!
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue)),
              ),
              color: fiberchatBlack.withOpacity(0.8),
            )
          : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Fiberchat.getNTPWrappedWidget(Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.keyboard_arrow_left_rounded,
              size: 30,
              color: DESIGN_TYPE == Themetype.whatsapp
                  ? fiberchatWhite
                  : fiberchatBlack,
            ),
          ),
          backgroundColor: DESIGN_TYPE == Themetype.whatsapp
              ? fiberchatDeepGreen
              : fiberchatWhite,
          title: Text(
            widget.name!,
            style: TextStyle(
              color: DESIGN_TYPE == Themetype.whatsapp
                  ? fiberchatWhite
                  : fiberchatBlack,
            ),
          )),
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
            ))
          : Stack(children: <Widget>[
              Container(
                  child: Center(
                child: !isUser!
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Text(
                                  widget.name! +
                                      ' ' +
                                      getTranslated(context, 'notexist') +
                                      "$Appname",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: fiberchatBlack,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20.0)),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            myElevatedButton(
                              color: fiberchatBlue,
                              child: Text(
                                getTranslated(context, 'invite') +
                                    ' ${widget.name}',
                                style: TextStyle(color: fiberchatWhite),
                              ),
                              onPressed: () {
                                Fiberchat.invite(context);
                              },
                            )
                          ])
                    : Container(),
              )),
              // Loading
              buildLoading()
            ]),
      backgroundColor: fiberchatWhite,
    ));
  }
}

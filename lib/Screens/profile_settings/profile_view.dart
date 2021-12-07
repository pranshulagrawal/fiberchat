//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Screens/status/components/formatStatusTime.dart';
import 'package:fiberchat/Services/Admob/admob.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/call_utilities.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/permissions.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  final Map<String, dynamic> user;
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final DocumentSnapshot<Map<String, dynamic>>? firestoreUserDoc;
  ProfileView(this.user, this.currentUserNo, this.model, this.prefs,
      {this.firestoreUserDoc});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  call(BuildContext context, bool isvideocall) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
        currentuseruid: widget.currentUserNo,
        fromDp: myphotoUrl,
        toDp: widget.user[Dbkeys.photoUrl],
        fromUID: widget.currentUserNo,
        fromFullname: mynickname,
        toUID: widget.user[Dbkeys.phone],
        toFullname: widget.user[Dbkeys.nickname],
        context: context,
        isvideocall: isvideocall);
  }

  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  AdWidget? adWidget;
  StreamSubscription? chatStatusSubscriptionForPeer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      listenToBlock();
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  bool hasPeerBlockedMe = false;
  listenToBlock() {
    chatStatusSubscriptionForPeer = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.user[Dbkeys.phone])
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .snapshots()
        .listen((doc) {
      if (doc.data()!.containsKey(widget.currentUserNo)) {
        print('CHANGED');
        if (doc.data()![widget.currentUserNo] == 0) {
          hasPeerBlockedMe = true;
          setState(() {});
        } else if (doc.data()![widget.currentUserNo] == 3) {
          hasPeerBlockedMe = false;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    chatStatusSubscriptionForPeer?.cancel();
    if (IsBannerAdShow == true) {
      myBanner.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: false);

    var w = MediaQuery.of(context).size.width;
    return PickupLayout(
        scaffold: Fiberchat.getNTPWrappedWidget(Scaffold(
      bottomSheet: IsBannerAdShow == true &&
              observer.isadmobshow == true &&
              adWidget != null
          ? Container(
              height: 60,
              margin: EdgeInsets.only(
                  bottom: Platform.isIOS == true ? 25.0 : 5, top: 0),
              child: Center(child: adWidget),
            )
          : SizedBox(
              height: 0,
            ),
      backgroundColor: DESIGN_TYPE == Themetype.whatsapp
          ? Color(0xfff2f2f2)
          : fiberchatWhite,
      body: ListView(
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: widget.user[Dbkeys.photoUrl] ?? '',
                imageBuilder: (context, imageProvider) => Container(
                  width: w,
                  height: w / 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Container(
                  width: w,
                  height: w / 1.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(Icons.person,
                      color: fiberchatGrey.withOpacity(0.5), size: 95),
                ),
                errorWidget: (context, url, error) => Container(
                  width: w,
                  height: w / 1.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(Icons.person,
                      color: fiberchatGrey.withOpacity(0.5), size: 95),
                ),
              ),
              Container(
                width: w,
                height: w / 1.2,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.29),
                    Colors.black.withOpacity(0.48),
                  ],
                )),
              ),
              Positioned(
                  bottom: 19,
                  left: 19,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Text(
                      widget.user[Dbkeys.nickname],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              Positioned(
                top: 11,
                left: 7,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_sharp,
                    size: 25,
                    color: fiberchatWhite,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated(context, 'about'),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: fiberchatgreen,
                          fontSize: 16),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(
                  height: 7,
                ),
                Text(
                  widget.user[Dbkeys.aboutMe] == null ||
                          widget.user[Dbkeys.aboutMe] == ''
                      ? '${getTranslated(context, 'heyim')} $Appname'
                      : widget.user[Dbkeys.aboutMe],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: fiberchatBlack,
                      fontSize: 15.9),
                ),
                SizedBox(
                  height: 14,
                ),
                Text(
                  getJoinTime(widget.user[Dbkeys.joinedOn], context),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: fiberchatGrey,
                      fontSize: 13.3),
                ),
                SizedBox(
                  height: 7,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated(context, 'enter_mobilenumber'),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: fiberchatgreen,
                          fontSize: 16),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(
                  height: 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.user[Dbkeys.phone],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: fiberchatBlack,
                          fontSize: 15.3),
                    ),
                    Container(
                      child: Row(
                        children: [
                          observer.isCallFeatureTotallyHide == true
                              ? SizedBox()
                              : IconButton(
                                  onPressed: observer.iscallsallowed == false
                                      ? () {
                                          Fiberchat.showRationale(getTranslated(
                                              context, 'callnotallowed'));
                                        }
                                      : hasPeerBlockedMe == true
                                          ? () {
                                              Fiberchat.toast(
                                                getTranslated(
                                                    context, 'userhasblocked'),
                                              );
                                            }
                                          : () async {
                                              await Permissions
                                                      .cameraAndMicrophonePermissionsGranted()
                                                  .then((isgranted) {
                                                if (isgranted == true) {
                                                  call(context, false);
                                                } else {
                                                  Fiberchat.showRationale(
                                                      getTranslated(
                                                          context, 'pmc'));
                                                  Navigator.push(
                                                      context,
                                                      new MaterialPageRoute(
                                                          builder: (context) =>
                                                              OpenSettings()));
                                                }
                                              }).catchError((onError) {
                                                Fiberchat.showRationale(
                                                    getTranslated(
                                                        context, 'pmc'));
                                                Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            OpenSettings()));
                                              });
                                            },
                                  icon: Icon(
                                    Icons.phone,
                                    color: fiberchatgreen,
                                  )),
                          observer.isCallFeatureTotallyHide == true
                              ? SizedBox()
                              : IconButton(
                                  onPressed: observer.iscallsallowed == false
                                      ? () {
                                          Fiberchat.showRationale(getTranslated(
                                              context, 'callnotallowed'));
                                        }
                                      : hasPeerBlockedMe == true
                                          ? () {
                                              Fiberchat.toast(
                                                getTranslated(
                                                    context, 'userhasblocked'),
                                              );
                                            }
                                          : () async {
                                              await Permissions
                                                      .cameraAndMicrophonePermissionsGranted()
                                                  .then((isgranted) {
                                                if (isgranted == true) {
                                                  call(context, true);
                                                } else {
                                                  Fiberchat.showRationale(
                                                      getTranslated(
                                                          context, 'pmc'));
                                                  Navigator.push(
                                                      context,
                                                      new MaterialPageRoute(
                                                          builder: (context) =>
                                                              OpenSettings()));
                                                }
                                              }).catchError((onError) {
                                                Fiberchat.showRationale(
                                                    getTranslated(
                                                        context, 'pmc'));
                                                Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            OpenSettings()));
                                              });
                                            },
                                  icon: Icon(
                                    Icons.videocam_rounded,
                                    size: 26,
                                    color: fiberchatgreen,
                                  )),
                          IconButton(
                              onPressed: () {
                                if (widget.firestoreUserDoc != null) {
                                  widget.model!
                                      .addUser(widget.firestoreUserDoc!);
                                }

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => new ChatScreen(
                                            isSharingIntentForwarded: false,
                                            prefs: widget.prefs,
                                            model: widget.model!,
                                            currentUserNo: widget.currentUserNo,
                                            peerNo: widget.user[Dbkeys.phone],
                                            unread: 0)),
                                    (Route r) => r.isFirst);
                              },
                              icon: Icon(
                                Icons.message,
                                color: fiberchatgreen,
                              )),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 0,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.only(bottom: 18, top: 8),
            color: Colors.white,
            // height: 30,
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text(
                  getTranslated(context, 'encryption'),
                  style: TextStyle(fontWeight: FontWeight.w600, height: 2),
                ),
              ),
              dense: false,
              subtitle: Text(
                getTranslated(context, 'encryptionshort'),
                style:
                    TextStyle(color: fiberchatGrey, height: 1.3, fontSize: 15),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Icon(
                  Icons.lock,
                  color: fiberchatgreen,
                ),
              ),
            ),
          ),
          SizedBox(
            height: IsBannerAdShow == true &&
                    observer.isadmobshow == true &&
                    adWidget != null
                ? 90
                : 20,
          ),
        ],
      ),
    )));
  }
}
